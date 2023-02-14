extends Node2D

var GAME_LENGTH := 10
var MAX_HEALTH := 3
var WORD_BUFFER := 2
var NUM_CURSE_OPTIONS := 3
var NUM_DEMONS := 1

var DEFAULT_TYPED := "type an insult to deal with the demon"

enum GAMESTATE {
  CURSE_CHOICE = 0,
  PLAYING = 1,
  GAMEOVER = 2
 }
var current_state = GAMESTATE.CURSE_CHOICE

onready var GameContainer := $UI/GameContainer
onready var StartContainer := $UI/StartContainer
onready var CurseChooser := $UI/ChooserContainer
onready var CurseChoices := [
  $UI/ChooserContainer/CurseChooser/Choice,
  $UI/ChooserContainer/CurseChooser/Choice2,
  $UI/ChooserContainer/CurseChooser/Choice3
 ]
onready var GameOver := $UI/StartContainer/VBoxContainer/GameOver
onready var StartButton := $UI/StartContainer/VBoxContainer/StartButton
onready var Clock := $UI/GameContainer/VBoxContainer/HBoxContainer/VBoxContainer/Clock
onready var Demons := $UI/GameContainer/VBoxContainer/HBoxContainer/VBoxContainer/Demons
onready var Rules := $UI/GameContainer/VBoxContainer/HBoxContainer/VBoxContainer1/Rules
onready var Score := $UI/GameContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Score
onready var Typed := $UI/GameContainer/VBoxContainer/Typed
onready var PrefixList := $UI/GameContainer/VBoxContainer/Fragments/Prefixes
onready var SuffixList := $UI/GameContainer/VBoxContainer/Fragments/Suffixes
onready var Mephistopheles := $Mephistopheles
onready var AudioManager := $UI/GameContainer/VBoxContainer/HBoxContainer/VBoxContainer2/AudioManager
onready var timer := $UI/Timer

onready var word_list:= WordList.new()
onready var curses:= Curses.new()

var prefixes := [] #: [Dictionary{fragment, used}]
var suffixes := [] #: [Dictionary{fragment, used}]
var current_word: Dictionary = {
  "prefix": "", "suffix": "", "prefix_used": false
 }

var current_demons := NUM_DEMONS
var current_health := MAX_HEALTH
var time_remaining := 0
var score := 0
var current_round := 0
var current_curses = []



func _ready() -> void:
  randomize()

  GameContainer.hide()
  StartContainer.show()
  CurseChooser.hide()

func start_game() -> void:
  score = 0
  current_curses = []
  current_round = 0
  reset_current()

  update_score()
  update_typed()

  curses.shuffle_curse_options()

  show_curse_options()


func show_curse_options() -> void:
  for i in range(NUM_CURSE_OPTIONS):
    CurseChoices[i].text = curses.get_round_description(current_round, i)

  GameContainer.hide()
  CurseChooser.show()


func end_round() -> void:
  timer.stop()

  current_round += 1

  if current_round == curses.num_rounds:
    end_game()
  else:
    current_state = GAMESTATE.CURSE_CHOICE
    show_curse_options()


func end_game() -> void:
  print("game over")
  GameContainer.hide()
  StartContainer.show()
  current_state = GAMESTATE.GAMEOVER

  GameOver.text = "Game Over!\nFinal Score: %s" % score
  GameOver.show()

  yield(get_tree().create_timer(3), "timeout")
  StartButton.show()


func curse_chosen(index: int) -> void:
  AudioManager.play_button_press()

  current_curses.append(curses.get_option(current_round, index))
  update_rules()

  current_health = MAX_HEALTH
  Mephistopheles.spawn()

  current_demons = NUM_DEMONS
  update_demons()

  generate_words()

  reset_timer()

  CurseChooser.hide()
  GameContainer.show()

  current_state = GAMESTATE.PLAYING


func generate_words() -> void:
  prefixes = []
  suffixes = []
  for word in word_list.choose_prefixes(MAX_HEALTH + WORD_BUFFER):
    prefixes.append({"fragment": word, "used": false, "current": false})
  for word in word_list.choose_suffixes(MAX_HEALTH + WORD_BUFFER):
    suffixes.append({"fragment": word, "used": false, "current": false})

  update_prefix_list(true)
  update_suffix_list(true)

  reset_current()


func reset_current() -> void:
  current_word.prefix = ""
  current_word.suffix = ""
  current_word.prefix_used = false


func _unhandled_key_input(event: InputEventKey) -> void:
  if current_state == GAMESTATE.PLAYING and event.pressed:
    if event.scancode >= KEY_A and event.scancode <= KEY_Z:
      var letter = OS.get_scancode_string(event.scancode).to_lower()

      if is_valid_choice(letter):
        AudioManager.play_correct_letter()
        if not current_word.prefix_used:
          current_word.prefix += letter
          if check_prefix_complete():
            current_word.prefix_used = true
            update_prefix_list()
        else:
          current_word.suffix += letter
          if check_word_complete():
            for prefix in prefixes:
              if prefix.current:
                prefix.current = false
                prefix.used = true
            update_prefix_list()

            for suffix in suffixes:
              if suffix.current:
                suffix.current = false
                suffix.used = true
            update_suffix_list()

            print("word complete")
            current_health -= 1
            Mephistopheles.change_face(MAX_HEALTH - current_health)
            AudioManager.play_word_complete()

            if current_health == 0:
              Mephistopheles.die()
              AudioManager.play_demon_death()

              score += 1 * current_curses.size()
              update_score()
              current_health = MAX_HEALTH
              Mephistopheles.spawn()
              current_demons -= 1

              if current_demons == 0:
                print("round complete")
                end_round()
              else:

                AudioManager.play_demon_spawn()
                update_demons()
                generate_words()
            else:
              reset_current()

        update_typed()
      else:
        AudioManager.play_incorrect_letter()
        print("invalid letter: ", letter)
    elif event.scancode == KEY_BACKSPACE:
      delete_character()
      update_prefix_list()
      update_typed()


func reset_timer() -> void:
  timer.start()
  time_remaining = GAME_LENGTH
  update_clock()


func update_clock() -> void:
  Clock.text = "Time Left: %3d" % time_remaining


func update_score() -> void:
  Score.text = "Score: %d" % score


func update_demons() -> void:
  Demons.text = "Demons Left: %d" % current_demons


func update_rules() -> void:
  var new_text := "Mind your "
  var and_string := ", and "
  for curse in current_curses:
    new_text += curses.get_description(curse) + and_string
  Rules.text = new_text.trim_suffix(and_string) + "."


func update_typed() -> void:
  var combined_word: String = current_word.prefix + current_word.suffix
  if combined_word == "":
    Typed.add_color_override("font_color", Color.dimgray)
    combined_word = DEFAULT_TYPED
  else:
    Typed.remove_color_override("font_color")

  Typed.text = combined_word


func update_prefix_list(new := false) -> void:
  update_list(PrefixList, prefixes, new)


func update_suffix_list(new := false) -> void:
  update_list(SuffixList, suffixes, new)


func update_list(node: Control, list, new := false) -> void:
  for child in node.get_children():
    child.queue_free()

  for fragment in list:
    if new:
      var word: String = fragment.fragment
      for curse in current_curses:
        word = curses.apply_curse(word, curse)
      fragment.word = word

    var label := Label.new()
    label.text = fragment.word
    if fragment.current:
      label.add_color_override("font_color", Color.green)
    elif fragment.used:
      label.add_color_override("font_color", Color.gray)
    node.add_child(label)


func is_valid_choice(letter: String) -> bool:
  var list
  var letter_pos

  if not current_word.prefix_used:
    list = prefixes
    letter_pos = current_word.prefix.length()
  else:
    list = suffixes
    letter_pos = current_word.suffix.length()

  for fragment in list:
    if not fragment.used and fragment.fragment.length() > letter_pos \
      and fragment.fragment[letter_pos] == letter:
      return true

  return false


func check_prefix_complete() -> bool:
  for prefix in prefixes:
    if prefix.fragment == current_word.prefix:
      prefix.current = true
      return true
  return false


func check_word_complete() -> bool:
  for suffix in suffixes:
    if suffix.fragment == current_word.suffix:
      suffix.current = true
      return true
  return false


func delete_character() -> void:
  if current_word.prefix_used and current_word.suffix.length() > 0:
    current_word.suffix = current_word.suffix.left(current_word.suffix.length() - 1)
  elif current_word.prefix.length() > 0:
    current_word.prefix = current_word.prefix.left(current_word.prefix.length() - 1)
    if current_word.prefix_used:
      current_word.prefix_used = false
      for prefix in prefixes:
        prefix.current = false


func _on_Button_pressed() -> void:
  AudioManager.play_button_press()

  start_game()
  StartContainer.hide()
  StartButton.hide()
  StartButton.text = "Play Again"
  GameOver.hide()


func _on_Choice_pressed() -> void:
  curse_chosen(0)


func _on_Choice2_pressed() -> void:
  curse_chosen(1)


func _on_Choice3_pressed() -> void:
  curse_chosen(2)


func _on_Timer_timeout() -> void:
  time_remaining -= 1
  if time_remaining >= 0:
    update_clock()
    if time_remaining == 0:
      timer.stop()
      end_game()
  else:
    # shouldn't get here, but end here as well just in case
    end_game()
    print("game over - should be imposs")
    timer.stop()
