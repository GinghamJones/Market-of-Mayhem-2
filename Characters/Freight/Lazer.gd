extends Node3D

@onready var damage_detector : RayCast3D = $LazerHitDetect
@onready var mesh_l : MeshInstance3D = $LazerBeamLeft
@onready var mesh_r : MeshInstance3D = $LazerBeamRight
@onready var timer : Timer = $LazerTimer
@onready var particles : GPUParticles3D = $HitParticles
@onready var raycast : RayCast3D = $Raycast
@onready var dam_freq_limit : Timer = $DamFrequencyLimit

var is_active : bool = false : set = set_is_active
var tween : Tween
var beam_radius : float = 0.03

signal colliding

func _process(delta):
	if is_active:
		var cast_point : Vector3
		raycast.force_raycast_update()
		
		if raycast.is_colliding():
	
			cast_point = to_local(raycast.get_collision_point())
			particles.emitting = true
			
			mesh_l.mesh.height = -(cast_point.z)
			mesh_r.mesh.height = -(cast_point.z)
			mesh_l.mesh.radius = beam_radius
			mesh_r.mesh.radius = beam_radius
			mesh_l.position.z = (cast_point.z / 2) - 0.2
			mesh_r.position.z = (cast_point.z / 2) - 0.2
			
#			particles.position.y = cast_point.y / 2
			particles.position = cast_point
			var particle_amount = snapped(abs(cast_point.y) * 50, 1)
			if particle_amount > 1:
				particles.amount = particle_amount
			else:
				particles.amount = 1
			
			particles.process_material.set_emission_box_extents(
				Vector3(mesh_l.mesh.radius, abs(cast_point.y) / 2, mesh_l.mesh.radius)
			)
		else:
			print("not colliding")
			particles.emitting = false
			
			mesh_l.mesh.height = 10
			mesh_l.position.z = -5
			mesh_r.mesh.height = 10
			mesh_r.position.z = -5
			particles.position = Vector3(200, 200, 200)
			


func check_raycast():
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target is Character:
			colliding.emit(target)


func set_is_active(value : bool):
	is_active = value
	if value == true:
		mesh_l.show()
		mesh_r.show()
		damage_detector.enabled = true
		raycast.enabled = true
		timer.start()
		dam_freq_limit.start()
	else:
		mesh_l.hide()
		mesh_r.hide()
		particles.emitting = false
		raycast.enabled = false
		damage_detector.enabled = false


func activate(time : float):
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(mesh_l.mesh, "radius", beam_radius, time)
	tween.tween_property(mesh_r.mesh, "radius", beam_radius, time)
	tween.tween_property(particles.process_material, "scale_min", 1, time)
	await tween.finished
	set_is_active(true)


func deactivate(time : float):
	set_is_active(false)
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(mesh_l.mesh, "radius", 0.0, time)
	tween.tween_property(mesh_r.mesh, "radius", 0.0, time)
	tween.tween_property(particles.process_material, "scale_min", 0.0, time)
	await tween.finished

