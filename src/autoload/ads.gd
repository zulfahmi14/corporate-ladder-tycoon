extends Node
## Ad facade. Game code only talks to this node, never to the AdMob plugin.
## Until step 5.11 this is a stub: no ads are available, the game is fully playable.

signal rewarded_earned(placement: String)
signal rewarded_failed(placement: String)


func is_rewarded_available(_placement: String) -> bool:
	return false


func show_rewarded(placement: String) -> void:
	rewarded_failed.emit(placement)


func maybe_show_interstitial() -> void:
	pass
