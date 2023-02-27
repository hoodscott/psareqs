extends CanvasLayer
class_name UI


const _DEFAULT_TYPED := "type an insult to deal with the devil"
var GAME_LENGTH:int # set in Game.gd
var _time_remaining := 0


signal game_started()
signal game_ended()
signal curse_chosen(index)


onready var AudioManager := $GameMargin/AudioContainer/AudioManager
onready var _GameMargin = $GameMargin
onready var _GameContainer := $GameMargin/GameContainer
onready var _StartContainer := $GameMargin/StartContainer
onready var _CurseChooser := $GameMargin/ChooserContainer
onready var _CurseChoices := [
  $GameMargin/ChooserContainer/CurseChooser/Choice,
  $GameMargin/ChooserContainer/CurseChooser/Choice2,
  $GameMargin/ChooserContainer/CurseChooser/Choice3
 ]
onready var _GameOver := $GameMargin/StartContainer/VBoxContainer/PanelContainer/MarginContainer/GameOver
onready var _StartButton := $GameMargin/StartContainer/VBoxContainer/StartButton
onready var _GameTimer := $Timer
onready var _Clock := $GameMargin/GameContainer/Top/TopLeft/PanelContainer/MarginContainer/VBoxContainer/Clock
onready var _Devils :=$GameMargin/GameContainer/Top/TopLeft/PanelContainer/MarginContainer/VBoxContainer/Devils
onready var _Rules := $GameMargin/GameContainer/Top/TopMid/RulesPanel/MarginContainer/Rules
onready var _Score := $GameMargin/GameContainer/Top/TopRight/PanelContainer/MarginContainer/Score
onready var _PrefixList := $GameMargin/GameContainer/Fragments/VBoxContainer2/PanelContainer/MarginContainer/Prefixes
onready var _SuffixList := $GameMargin/GameContainer/Fragments/VBoxContainer/PanelContainer/MarginContainer/Suffixes
onready var _Typed := $GameMargin/GameContainer/Bottom/PanelContainer/MarginContainer/Typed
onready var _Animations := $AnimationPlayer
onready var _WordCompleteSpawn := $GameMargin/CompleteSpawn

onready var _CompleteWord: PackedScene = preload("res://scenes/ui/CompleteWord.tscn")

var alt_font := false



func _ready() -> void:
  _GameContainer.hide()
  _StartContainer.show()
  _CurseChooser.hide()


func end_game(score: int) -> void:
  _GameContainer.hide()
  _StartContainer.show()

  _GameOver.text = "Game Over!\nFinal Score: %s" % score
  _GameOver.show()

  yield(get_tree().create_timer(3), "timeout")
  _StartButton.show()


func show_game() -> void:
  _CurseChooser.hide()
  _GameContainer.show()


func show_curse_option(option: String, i: int) -> void:
  _CurseChoices[i].text = option

  _GameContainer.hide()
  _CurseChooser.show()


func update_prefix_list(prefixes) -> void:
  _update_list(_PrefixList, prefixes)


func update_suffix_list(suffixes) -> void:
  _update_list(_SuffixList, suffixes)


func _update_list(node: Control, list) -> void:
  for child in node.get_children():
    child.queue_free()

  for fragment in list:
    var label := Label.new()
    label.text = fragment.word
    if fragment.current:
      label.add_color_override("font_color", Color.green)
    elif fragment.used:
      label.add_color_override("font_color", Color.gray)
    node.add_child(label)


func reset_timer() -> void:
  _GameTimer.start()
  _time_remaining = GAME_LENGTH
  _update_clock(_time_remaining)


func stop_timer(emit := false) -> void:
  _GameTimer.stop()
  if emit:
    emit_signal("game_ended")


func incorrect_letter(_letter: String) -> void:
  AudioManager.play_incorrect_letter()
  _Animations.play("incorrect")


func word_complete() -> void:
  var complete_word := _CompleteWord.instance()
  complete_word.text = _Typed.text
  _WordCompleteSpawn.add_child(complete_word)


func _update_clock(time: int) -> void:
  _Clock.text = "Time Left: %3d" % time


func update_score(score: int) -> void:
  _Score.text = "Score: %d" % score


func update_devils(devil_count: int) -> void:
  _Devils.text = "Devils Left: %d" % devil_count


func update_rules(rules) -> void:
  var new_text := "Mind your "
  var and_string := ", and "
  for rule in rules:
    new_text += rule + and_string
  _Rules.text = new_text.trim_suffix(and_string) + "."


func update_typed(combined_word: String, help := false) -> void:
  if combined_word == "":
    _Typed.add_color_override("font_color", Color.dimgray)
    if help:
      combined_word = _DEFAULT_TYPED
    else:
      combined_word = ""
  else:
    _Typed.remove_color_override("font_color")

  _Typed.text = combined_word


func _on_StartButton_pressed() -> void:
  AudioManager.play_button_press()

  emit_signal("game_started")
  _StartContainer.hide()
  _StartButton.hide()
  _StartButton.text = "Play Again"
  _GameOver.hide()


func _on_Choice_pressed() -> void:
  emit_signal("curse_chosen", 0)


func _on_Choice2_pressed() -> void:
  emit_signal("curse_chosen", 1)


func _on_Choice3_pressed() -> void:
  emit_signal("curse_chosen", 2)


func _on_Timer_timeout() -> void:
  _time_remaining -= 1
  if _time_remaining >= 0:
    _update_clock(_time_remaining)
    if _time_remaining == 0:
      stop_timer(true)
  else:
    # shouldn't get here, but end here as well just in case
    stop_timer(true)


func focus_start() -> void:
  _StartButton.grab_focus()


func focus_choice() -> void:
  _CurseChoices[0].grab_focus()


func _on_FontChange_pressed() -> void:
  var alt_string = "" if alt_font else "_alt"
  var new_small_font := load("res://scenes/ui/theme/font_small%s.tres" % alt_string)
  var new_normal_font := load("res://scenes/ui/theme/font_normal%s.tres" % alt_string)

  _GameMargin.get_theme().set_default_font(new_normal_font)
  _Rules.add_font_override("font", new_small_font)
  alt_font = not alt_font

