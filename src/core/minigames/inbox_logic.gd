class_name InboxLogic
extends RefCounted
## Inbox Sort: decide if each email is work or spam before time runs out.

const EMAIL_COUNT: int = 12
const TIME_PER_EMAIL_S: Array[float] = [3.0, 2.0, 1.3]
const WORK_KEYS: Array[String] = [
	"INBOX_WORK_1",
	"INBOX_WORK_2",
	"INBOX_WORK_3",
	"INBOX_WORK_4",
	"INBOX_WORK_5",
	"INBOX_WORK_6",
]
const SPAM_KEYS: Array[String] = [
	"INBOX_SPAM_1",
	"INBOX_SPAM_2",
	"INBOX_SPAM_3",
	"INBOX_SPAM_4",
	"INBOX_SPAM_5",
	"INBOX_SPAM_6",
]


## Returns EMAIL_COUNT dictionaries: {"key": String, "is_work": bool}.
static func make_emails(rng: RandomNumberGenerator) -> Array[Dictionary]:
	var emails: Array[Dictionary] = []
	for i: int in EMAIL_COUNT:
		var is_work: bool = rng.randf() < 0.5
		var pool: Array[String] = WORK_KEYS if is_work else SPAM_KEYS
		emails.append({"key": pool[rng.randi_range(0, pool.size() - 1)], "is_work": is_work})
	return emails


static func score(correct: int) -> float:
	return clampf(float(correct) / EMAIL_COUNT, 0.0, 1.0)
