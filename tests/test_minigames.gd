extends TestSuite


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func test_unlock_follows_rank() -> void:
	var s := PlayerState.new()
	assert_true(MinigameRules.is_unlocked(s, 0))
	assert_true(not MinigameRules.is_unlocked(s, 1))
	s.rank = 4
	assert_true(MinigameRules.is_unlocked(s, 4))


func test_founders_keep_every_game_unlocked() -> void:
	var s := PlayerState.new()
	s.careers = 1
	assert_true(MinigameRules.is_unlocked(s, 4))


func test_reward_scales_with_difficulty_and_score() -> void:
	var s := PlayerState.new()
	var easy: float = MinigameRules.reward(s, 0, MinigameData.Difficulty.EASY, 1.0)
	var hard: float = MinigameRules.reward(s, 0, MinigameData.Difficulty.HARD, 1.0)
	assert_near(easy, 3.0 * 30.0)  # basis = 3 taps of 1 yen, 30 s, x1
	assert_near(hard, easy * 4.0)
	assert_near(MinigameRules.reward(s, 0, MinigameData.Difficulty.HARD, 0.5), hard * 0.5)
	assert_near(MinigameRules.reward(s, 0, MinigameData.Difficulty.HARD, 7.0), hard)


func test_finish_pays_and_starts_cooldown() -> void:
	var s := PlayerState.new()
	var paid: float = MinigameRules.finish(s, 0, MinigameData.Difficulty.NORMAL, 1.0, 1000.0)
	assert_near(paid, 3.0 * 30.0 * 2.0)
	assert_near(s.yen, paid)
	assert_near(MinigameRules.cooldown_left(s, 0, 1100.0), 200.0)
	assert_near(MinigameRules.finish(s, 0, 0, 1.0, 1100.0), -1.0)
	assert_true(MinigameRules.finish(s, 0, 0, 1.0, 1300.0) > 0.0)


func test_locked_game_cannot_be_finished() -> void:
	var s := PlayerState.new()
	assert_near(MinigameRules.finish(s, 3, 0, 1.0, 1000.0), -1.0)
	assert_near(s.yen, 0.0)


func test_clock_going_backwards_does_not_lock_games() -> void:
	var s := PlayerState.new()
	s.minigame_last_play[0] = 5000.0
	assert_near(MinigameRules.cooldown_left(s, 0, 100.0), 0.0)


func test_cooldowns_survive_save_roundtrip() -> void:
	var s := PlayerState.new()
	s.minigame_last_play[2] = 1234.0
	var back: PlayerState = SaveCodec.decode(SaveCodec.encode(s))
	assert_near(back.minigame_last_play[2], 1234.0)


func test_hanko_score_penalises_wrong_stamps() -> void:
	assert_near(HankoLogic.score(10, 0, 10), 1.0)
	assert_near(HankoLogic.score(10, 4, 10), 0.6)
	assert_near(HankoLogic.score(1, 5, 10), 0.0)
	assert_near(HankoLogic.score(0, 0, 0), 0.0)


func test_inbox_emails_match_their_pool() -> void:
	var emails: Array[Dictionary] = InboxLogic.make_emails(_rng(3))
	assert_eq(emails.size(), InboxLogic.EMAIL_COUNT)
	for e: Dictionary in emails:
		var pool: Array[String] = InboxLogic.WORK_KEYS if e["is_work"] else InboxLogic.SPAM_KEYS
		assert_true(pool.has(e["key"]))


func test_expense_question_has_one_right_answer() -> void:
	var rng := _rng(11)
	for diff: int in 3:
		for i: int in 50:
			var q: Dictionary = ExpenseLogic.make_question(rng, diff)
			var terms: Array = q["terms"]
			var total: int = 0
			for t: int in terms:
				total += t
			assert_eq(q["answer"], total)
			var choices: Array = q["choices"]
			assert_eq(choices.size(), 3)
			assert_eq(choices.count(total), 1)
			assert_true(choices[0] != choices[1] and choices[1] != choices[2])
			assert_eq(terms.size(), ExpenseLogic.TERMS[diff])


func test_pitch_needle_bounces_between_ends() -> void:
	assert_near(PitchLogic.needle_at(0.0, 1.0), 0.0)
	assert_near(PitchLogic.needle_at(0.5, 1.0), 0.5)
	assert_near(PitchLogic.needle_at(1.5, 1.0), 0.5)
	assert_near(PitchLogic.needle_at(2.0, 1.0), 0.0)


func test_pitch_hit_zone_shrinks_with_difficulty() -> void:
	assert_true(PitchLogic.is_hit(0.6, 0.5, MinigameData.Difficulty.EASY))
	assert_true(not PitchLogic.is_hit(0.6, 0.5, MinigameData.Difficulty.HARD))


func test_board_sequence_grows_each_round() -> void:
	assert_eq(BoardLogic.sequence_length(0, 0), 3)
	assert_eq(BoardLogic.sequence_length(2, 3), 8)
	var seq: Array[int] = BoardLogic.make_sequence(_rng(5), 6)
	assert_eq(seq.size(), 6)
	for d: int in seq:
		assert_true(d >= 0 and d < BoardLogic.DEPARTMENTS)
