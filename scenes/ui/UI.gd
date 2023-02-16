extends CanvasLayer
class_name UI


const _DEFAULT_TYPED := "type an insult to deal with the devil"
var GAME_LENGTH:int # set in Game.gd
var _time_remaining := 0


signal game_started()
signal game_ended()
signal curse_chosen(index)


onready var AudioManager := $GameContainer/VBoxContainer/TopRow/TopRight/AudioManager
onready var _GameContainer := $GameContainer
onready var _StartContainer := $StartContainer
onready var _CurseChooser := $ChooserContainer
onready var _CurseChoices := [
  $ChooserContainer/CurseChooser/Choice,
  $ChooserContainer/CurseChooser/Choice2,
  $ChooserContainer/CurseChooser/Choice3
 ]
onready var _GameOver := $StartContainer/VBoxContainer/PanelContainer/MarginContainer/GameOver
onready var _StartButton := $StartContainer/VBoxContainer/StartButton
onready var _GameTimer := $Timer
onready var _Clock := $GameContainer/VBoxContainer/TopRow/TopLeft/PanelContainer/MarginContainer/VBoxContainer/Clock
onready var _Devils :=$GameContainer/VBoxContainer/TopRow/TopLeft/PanelContainer/MarginContainer/VBoxContainer/Devils
onready var _Rules := $GameContainer/VBoxContainer/TopRow/TopMid/RulesPanel/MarginContainer/Rules
onready var _Score := $GameContainer/VBoxContainer/TopRow/TopRight/PanelContainer/MarginContainer/Score
onready var _PrefixList := $GameContainer/VBoxContainer/Fragments/VBoxContainer2/PanelContainer/MarginContainer/Prefixes
onready var _SuffixList := $GameContainer/VBoxContainer/Fragments/VBoxContainer/PanelContainer/MarginContainer/Suffixes
onready var _Typed := $GameContainer/VBoxContainer/Bottom/PanelContainer/MarginContainer/Typed
onready var _Animations := $AnimationPlayer



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
  print("invalid letter: ", _letter)


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


func update_typed(combined_word: String) -> void:
  if combined_word == "":
    _Typed.add_color_override("font_color", Color.dimgray)
    combined_word = _DEFAULT_TYPED
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
    print("game over - should be imposs")
    stop_timer(true)


func focus_start() -> void:
  _StartButton.grab_focus()


func focus_choice() -> void:
  _CurseChoices[0].grab_focus()
