extends Node

onready var Correct := $CorrectLetter
onready var Incorrect := $IncorrectLetter
onready var WordComplete := $WordComplete
onready var DevilDeath := $DevilDeath
onready var DevilSpawn := $DevilSpawn
onready var ButtonPress := $ButtonPress
onready var Background: AudioStreamPlayer = $Background

onready var music_bus := AudioServer.get_bus_index("Music")
onready var sound_bus := AudioServer.get_bus_index("Sounds")

var music_pos := 0.0



func _ready() -> void:
  if not AudioServer.is_bus_mute(music_bus):
    Background.play()


func play_correct_letter() -> void:
  Correct.play()


func play_incorrect_letter() -> void:
  Incorrect.play()


func play_word_complete() -> void:
  WordComplete.play()


func play_devil_death() -> void:
  WordComplete.stop()
  DevilDeath.play()


func play_devil_spawn() -> void:
  DevilSpawn.play()


func play_button_press() -> void:
  ButtonPress.play()


func change_music_bus(value: int) -> void:
  # if mute status is changing, pause the tracks
  if AudioServer.is_bus_mute(music_bus) and value > 0:
    Background.play(music_pos)
  elif not AudioServer.is_bus_mute(music_bus) and value == 0:
    music_pos = Background.get_playback_position()
    Background.stop()

  if value == 0:
    AudioServer.set_bus_mute(music_bus, true)
  else:
    value = -pow(2, 5 - value)
    AudioServer.set_bus_mute(music_bus, false)
    AudioServer.set_bus_volume_db(music_bus, value)


func change_sound_bus(value: int) -> void:
  if value == 0:
    AudioServer.set_bus_mute(sound_bus, true)
  else:
    value = 4 * (value - 2)
    AudioServer.set_bus_mute(sound_bus, false)
    AudioServer.set_bus_volume_db(sound_bus, value)
