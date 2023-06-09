extends AnimationTree


func set_oneshot(anim : String) -> bool:
	# This checks if a oneshot is already playing and returns false if so. A false return stops the requested action from taking place.
	var oneshot_anims : Array = [self["parameters/BlockShot/active"], self["parameters/LeftAttackShot/active"], self["parameters/RightAttackShot/active"], self["parameters/ProjectileShot/active"], self["parameters/SpecialShot/active"]]
	if anim == "parameters/RightAttackShot/request":
		set(anim, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		return true
	for oneshot in oneshot_anims:
		if oneshot == true:
			return false
	
	set(anim, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	return true
