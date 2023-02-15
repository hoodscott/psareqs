extends Node

onready var Correct := $CorrectLetter
onready var Incorrect := $IncorrectLetter
onready var WordComplete := $WordComplete
onready var DevilDeath := $DevilDeath
onready var DevilSpawn := $DevilSpawn
onready var ButtonPress := $ButtonPress

var muted := false
const _MUTE_LABEL := "Mute"
const _UNMUTE_LABEL := "Unmute"



func _ready() -> void:
  _set_button_label()


func play_correct_letter() -> void:
  if not muted:
    Correct.play()


func play_incorrect_letter() -> void:
  if not muted:
    Incorrect.play()


func play_word_complete() -> void:
  if not muted:
    WordComplete.play()


func play_devil_death() -> void:
  if not muted:
    WordComplete.stop()
    DevilDeath.play()


func play_devil_spawn() -> void:
  if not muted:
    DevilSpawn.play()


func play_button_press() -> void:
  if not muted:
    ButtonPress.play()


func _on_AudioManager_pressed() -> void:
  muted = not muted
  _set_button_label()


func _set_button_label() -> void:
  if muted:
    self.text = _UNMUTE_LABEL
  else:
    self.text = _MUTE_LABEL
