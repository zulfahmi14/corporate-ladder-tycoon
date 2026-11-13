class_name ExpenseLogic
extends RefCounted
## Expense Report: add up receipts and pick the right total.

const QUESTION_COUNT: int = 8
const TIME_PER_QUESTION_S: Array[float] = [7.0, 6.0, 5.0]
const TERMS: Array[int] = [2, 2, 3]
const MAX_VALUE: Array[int] = [99, 999, 999]


## Returns {"terms": Array[int], "answer": int, "choices": Array[int]} with 3 distinct choices.
static func make_question(rng: RandomNumberGenerator, difficulty: int) -> Dictionary:
	var terms: Array[int] = []
	var answer: int = 0
	for i: int in TERMS[difficulty]:
		var value: int = rng.randi_range(10, MAX_VALUE[difficulty])
		terms.append(value)
		answer += value
	var choices: Array[int] = [answer]
	# Wrong answers are close (off by 10 or 100) so a glance is not enough.
	var offsets: Array[int] = [-100, -10, 10, 100]
	while choices.size() < 3:
		var wrong: int = answer + offsets[rng.randi_range(0, offsets.size() - 1)]
		if wrong > 0 and not choices.has(wrong):
			choices.append(wrong)
	# Fisher-Yates with the injected rng so tests are deterministic.
	for i: int in range(choices.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: int = choices[i]
		choices[i] = choices[j]
		choices[j] = tmp
	return {"terms": terms, "answer": answer, "choices": choices}


static func score(correct: int) -> float:
	return clampf(float(correct) / QUESTION_COUNT, 0.0, 1.0)
