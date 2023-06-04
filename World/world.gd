extends Node3D

@onready var song1 : AudioStreamPlayer = $AudioStreamPlayer
@onready var song2 : AudioStreamPlayer = $AudioStreamPlayer2
@onready var song3 : AudioStreamPlayer = $AudioStreamPlayer3
@onready var song4 : AudioStreamPlayer = $AudioStreamPlayer4
@onready var song5 : AudioStreamPlayer = $AudioStreamPlayer5
@onready var song6 : AudioStreamPlayer = $AudioStreamPlayer6
@onready var song7 : AudioStreamPlayer = $AudioStreamPlayer7

var current_song : AudioStreamPlayer = null

func _ready():
	SpawnManager.populate_spawn_points()


func play_song() -> void:
	var song_to_play : int = randi() % 7
	print(song_to_play)
	match song_to_play:
		0:
			song1.play()
			current_song = song1
		1:
			song2.play()
			current_song = song2
		2:
			song3.play()
			current_song = song3
		3:
			song4.play()
			current_song = song4
		4:
			song5.play()
			current_song = song5
		5:
			song6.play()
			current_song = song6
		6:
			song7.play()
			current_song = song7


func stop_song() -> void:
	if current_song:
		current_song.stop()
	

func play_new_song() -> void:
	current_song.stop()
	play_song()
