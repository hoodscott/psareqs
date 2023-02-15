extends CanvasLayer
class_name UI


const DEFAULT_TYPED := "type an insult to deal with the devil"
var GAME_LENGTH:int # set in Game.gd
var time_remaining := 0


signal game_started()
signal game_ended()
signal curse_chosen(index)


onready var AudioManager := $GameContainer/VBoxContainer/HBoxContainer/VBoxContainer2/AudioManager
onready var GameContainer := $GameContainer
onready var StartContainer := $StartContainer
onready var CurseChooser := $ChooserContainer
onready var CurseChoices := [
  $ChooserContainer/CurseChooser/Choice,
  $ChooserContainer/CurseChooser/Choice2,
  $ChooserContainer/CurseChooser/Choice3
 ]
onready var GameOver := $StartContainer/VBoxContainer/GameOver
onready var StartButton := $StartContainer/VBoxContainer/StartButton
onready var GameTimer := $Timer
onready var Clock := $GameContainer/VBoxContainer/HBoxContainer/VBoxContainer/Clock
onready var Devils := $GameContainer/VBoxContainer/HBoxContainer/VBoxContainer/Devils
onready var Rules := $GameContainer/VBoxContainer/HBoxContainer/VBoxContainer1/Rules
onready var Score := $GameContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Score
onready var PrefixList := $GameContainer/VBoxContainer/Fragments/Prefixes
onready var SuffixList := $GameContainer/VBoxContainer/Fragments/Suffixes
onready var Typed := $GameContainer/VBoxContainer/Typed



func _ready() -> void:
  GameContainer.hide()
  StartContainer.show()
  CurseChooser.hide()


func end_game(score: int) -> void:
  GameContainer.hide()
  StartContainer.show()

  GameOver.text = "Game Over!\nFinal Score: %s" % score
  GameOver.show()

  yield(get_tree().create_timer(3), "timeout")
  StartButton.show()


func show_game() -> void:
  CurseChooser.hide()
  GameContainer.show()


func show_curse_option(option: String, i: int) -> void:
  CurseChoices[i].text = option

  GameContainer.hide()
  CurseChooser.show()


func update_prefix_list(prefixes) -> void:
  update_list(PrefixList, prefixes)


func update_suffix_list(suffixes) -> void:
  update_list(SuffixList, suffixes)


func update_list(node: Control, list) -> void:
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
  GameTimer.start()
  time_remaining = GAME_LENGTH
  update_clock()


func stop_timer() -> void:
  GameTimer.stop()


func update_clock() -> void:
  Clock.text = "Time Left: %3d" % time_remaining


func update_score(score: int) -> void:
  Score.text = "Score: %d" % score


func update_devils(devil_count: int) -> void:
  Devils.text = "Devils Left: %d" % devil_count


func update_rules(rules) -> void:
  var new_text := "Mind your "
  var and_string := ", and "
  for rule in rules:
    new_text += rule + and_string
  Rules.text = new_text.trim_suffix(and_string) + "."


func update_typed(combined_word: String) -> void:
  if combined_word == "":
    Typed.add_color_override("font_color", Color.dimgray)
    combined_word = DEFAULT_TYPED
  else:
    Typed.remove_color_override("font_color")

  Typed.text = combined_word


func _on_StartButton_pressed() -> void:
  AudioManager.play_button_press()

  emit_signal("game_started")
  StartContainer.hide()
  StartButton.hide()
  StartButton.text = "Play Again"
  GameOver.hide()


func _on_Choice_pressed() -> void:
  emit_signal("curse_chosen", 0)


func _on_Choice2_pressed() -> void:
  emit_signal("curse_chosen", 1)


func _on_Choice3_pressed() -> void:
  emit_signal("curse_chosen", 2)


func _on_Timer_timeout() -> void:
  time_remaining -= 1
  if time_remaining >= 0:
    update_clock()
    if time_remaining == 0:
      GameTimer.stop()
      emit_signal("game_ended")
  else:
    # shouldn't get here, but end here as well just in case
    emit_signal("game_ended")
    print("game over - should be imposs")
    GameTimer.stop()
