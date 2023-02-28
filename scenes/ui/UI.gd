extends CanvasLayer
class_name UI


signal game_started()
signal game_ended()
signal curse_chosen(index)
signal game_restarted()


const _DEFAULT_TYPED := "type an insult to deal with the devil"
var GAME_LENGTH:int # set in Game.gd
var _time_remaining := 0
var _alt_font := false
var _settings_open := false
var _visibilty_states := []


onready var AudioManager := $AudioManager

onready var _GameMargin = $GameMargin
onready var _StartContainer := $GameMargin/StartContainer
onready var _GameOver := $GameMargin/StartContainer/VBoxContainer/PanelContainer/GameOver
onready var _StartButton := $GameMargin/StartContainer/VBoxContainer/StartButton

onready var _CurseChooser := $GameMargin/ChooserContainer
onready var _CurseChoices := [
  $GameMargin/ChooserContainer/CurseChooser/Choice,
  $GameMargin/ChooserContainer/CurseChooser/Choice2,
  $GameMargin/ChooserContainer/CurseChooser/Choice3
 ]
onready var _GameContainer := $GameMargin/GameContainer
onready var _Clock := $GameMargin/GameContainer/Top/TopLeft/PanelContainer/VBoxContainer/Clock
onready var _Devils :=$GameMargin/GameContainer/Top/TopLeft/PanelContainer/VBoxContainer/Devils
onready var _Rules := $GameMargin/GameContainer/Top/TopMid/RulesPanel/Rules
onready var _Score := $GameMargin/GameContainer/Top/TopRight/PanelContainer/VBoxContainer/Score
onready var _Multiplier := $GameMargin/GameContainer/Top/TopRight/PanelContainer/VBoxContainer/Multiplier
onready var _PrefixList := $GameMargin/GameContainer/Fragments/VBoxContainer2/PanelContainer/Prefixes
onready var _SuffixList := $GameMargin/GameContainer/Fragments/VBoxContainer/PanelContainer/Suffixes
onready var _Typed := $GameMargin/GameContainer/Bottom/PanelContainer/Typed
onready var _WordCompleteSpawn := $GameMargin/CompleteSpawn

onready var _Settings := $GameMargin/SettingsContainer
onready var _MusicSlider := $GameMargin/SettingsContainer/Panel/Row/MusicContainer/VBoxContainer/MusicVolumeSlider
onready var _SoundSlider := $GameMargin/SettingsContainer/Panel/Row/SoundContainer/VBoxContainer/SoundVolumeSlider
onready var _SettingsButton := $GameMargin/SettingOpener/SettingsButton

onready var _Help := $GameMargin/HelpContainer
onready var _HelpCloseButton := $GameMargin/HelpContainer/VBoxContainer/HBoxContainer3/HelpCloseButton
onready var _Credits := $GameMargin/CreditsContainer
onready var _CreditsCloseButton := $GameMargin/CreditsContainer/VBoxContainer/HBoxContainer3/CreditsCloseButton

onready var _Animations := $AnimationPlayer
onready var _GameTimer := $Timer

onready var _CompleteWord: PackedScene = preload("res://scenes/ui/CompleteWord.tscn")



func _ready() -> void:
  reset()


func reset() -> void:
  _GameTimer.stop()
  _GameContainer.hide()
  _CurseChooser.hide()
  _Settings.hide()
  _Help.hide()
  _Credits.hide()
  _StartContainer.show()


func end_game(score: int, reset := false, won := false) -> void:
  _GameContainer.hide()
  _StartContainer.show()

  if won:
    _GameOver.text = "Congratulations!\n\nThe devils have been dealt with!\n\nFinal Score: %s" % score
  elif reset:
    _GameOver.text = "Mind your\nPs and Qs"
    _StartButton.text = "Start Game"
  else:
    _GameOver.text = "Game Over!\n\nThere is no time left\nto deal with the devils.\n\nFinal Score: %s" % score

  _GameOver.show()

  if not reset:
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


func get_seconds_left() -> int:
  return int(_time_remaining)


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


func update_multiplier(mult: int) -> void:
  _Multiplier.text = "Multiplier: x%d" % mult


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
  _StartButton.text = "Play Again?"
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


func _on_FontChange_toggled(button_pressed: bool) -> void:
  AudioManager.play_button_press()
  _alt_font = not button_pressed

  var alt_string = "" if _alt_font else "_alt"
  var new_small_font := load("res://scenes/ui/theme/font_small%s.tres" % alt_string)
  var new_theme := load("res://scenes/ui/theme/theme%s.tres" % alt_string)

  _GameMargin.set_theme(new_theme)
  _Rules.add_font_override("font", new_small_font)


func _on_MuteMusicButton_pressed() -> void:
  AudioManager.play_button_press()
  _MusicSlider.value = 0


func _on_MuteSoundButton_pressed() -> void:
  AudioManager.play_button_press()
  _SoundSlider.value = 0


func _on_SettingsButton_pressed() -> void:
  AudioManager.play_button_press()
  _toggle_settings()


func _toggle_settings() -> void:
  if _settings_open:
    _SettingsButton.text = "Settings"
    _GameTimer.set_paused(false)

    # put game UI back to state before settings were opened
    if _visibilty_states[0]:
      _GameContainer.show()
    if _visibilty_states[1]:
      _StartContainer.show()
    if _visibilty_states[2]:
      _CurseChooser.show()

    _Settings.hide()
    # release focus trick
    _SettingsButton.hide()
    _SettingsButton.show()
  else:
    _SettingsButton.text = "Close Settings"
    _GameTimer.set_paused(true)

    # remember current state of UI before settings were opened
    _visibilty_states = []
    _visibilty_states.append(_GameContainer.visible)
    _GameContainer.hide()
    _visibilty_states.append(_StartContainer.visible)
    _StartContainer.hide()
    _visibilty_states.append(_CurseChooser.visible)
    _CurseChooser.hide()

    _Settings.show()
    _MusicSlider.grab_focus()

  _settings_open = not _settings_open


func _on_SoundVolumeSlider_value_changed(value: float) -> void:
  AudioManager.change_sound_bus(value)
  AudioManager.play_button_press()


func _on_MusicVolumeSlider_value_changed(value: float) -> void:
  AudioManager.change_music_bus(value)


func _on_HelpCloseButton_pressed() -> void:
  AudioManager.play_button_press()
  _Help.hide()
  _Settings.show()
  _MusicSlider.grab_focus()


func _on_HelpButton_pressed() -> void:
  AudioManager.play_button_press()
  _Settings.hide()
  _Help.show()
  _HelpCloseButton.grab_focus()


func _on_CreditsButton_pressed() -> void:
  AudioManager.play_button_press()
  _Settings.hide()
  _Credits.show()
  _CreditsCloseButton.grab_focus()


func _on_CreditsCloseButton_pressed() -> void:
  AudioManager.play_button_press()
  _Credits.hide()
  _Settings.show()
  _MusicSlider.grab_focus()


func _on_RestartButton_pressed() -> void:
  AudioManager.play_button_press()
  _toggle_settings()
  emit_signal("game_restarted")


func _on_RichTextLabel_meta_clicked(meta) -> void:
  if OS.shell_open(str(meta)) != OK:
    print("error opening link ", meta)
