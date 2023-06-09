extends Camera3D

var speed : float = 25.0

func _physics_process(delta):
	if current:
		var input_dir : Vector2 = Input.get_vector("MoveLeft", "MoveRight", "MoveBack", "MoveForward")
		var direction : Vector3 = Vector3.ZERO

		direction = (transform.basis * Vector3(input_dir.x, input_dir.y, 0)).normalized()
		position += direction * speed * delta
