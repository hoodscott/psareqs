extends Node2D

export (int) var GAME_LENGTH := 10
export (int) var MAX_HEALTH := 2
export (int) var WORD_BUFFER := 3
var NUM_CURSE_OPTIONS := 3
var NUM_DEMONS := 1

enum GAMESTATE {
  CURSE_CHOICE = 0,
  PLAYING = 1,
  GAMEOVER = 2
 }
var current_state = GAMESTATE.CURSE_CHOICE

enum CURSE {
  PQ = 0,
  DB = 1,
  VOWEL = 2,
  ALPHA = 3,
  REVERSE = 4,
  FLIP = 5, #todo (need to change pivot point of PrefixList and then rotate 180 (remember to reset)
  JUMBLE = 6,
  ROT13 = 7,
  ROT1 = 8,
  ROT1NEG = 9,
  ALLE = 10,
  KC = 11,
  ALLY = 12
 }
const curse_descriptions = [
  "Ps are Qs", "Ds are Bs", "vowels are shifted (a>e>i>o>u>a)",
  "words are alphabetised", "words are reversed", "words are flipped",
  "words are jumbled",  "letters are rot13 (a>m>a, b>n>b)",
  "letters are shifted (a>b>c>...)", "letters are shifted backwards (c>b>a>z>...)",
  "vowels are all E", "Ks are Cs", "vowels are all Y"
 ]
var curse_options := [
  [CURSE.PQ, CURSE.DB, CURSE.KC], # letter swaps
  [CURSE.VOWEL, CURSE.ALLE, CURSE.ALLY], # vowel changes
  [CURSE.REVERSE, CURSE.JUMBLE, CURSE.ALPHA, CURSE.ROT1, CURSE.ROT1NEG], # reorder
 ]
var num_rounds = curse_options.size()

onready var GameContainer := $CanvasLayer/GameContainer
onready var CurseChooser := $CanvasLayer/CenterContainer/CurseChooser
onready var CurseChoices := [
  $CanvasLayer/CenterContainer/CurseChooser/Choice,
  $CanvasLayer/CenterContainer/CurseChooser/Choice2,
  $CanvasLayer/CenterContainer/CurseChooser/Choice3
 ]
onready var GameOver := $CanvasLayer/CenterContainer/VBoxContainer/GameOver
onready var StartButton := $CanvasLayer/CenterContainer/VBoxContainer/StartButton
onready var Clock := $CanvasLayer/GameContainer/VBoxContainer/HBoxContainer/VBoxContainer/Clock
onready var Demons := $CanvasLayer/GameContainer/VBoxContainer/HBoxContainer/VBoxContainer/Demons
onready var Rules := $CanvasLayer/GameContainer/VBoxContainer/HBoxContainer/VBoxContainer1/Rules
onready var Score := $CanvasLayer/GameContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Score
onready var Health := $CanvasLayer/CenterContainer/Health
onready var Typed := $CanvasLayer/GameContainer/VBoxContainer/Typed
onready var PrefixList := $CanvasLayer/GameContainer/VBoxContainer/Fragments/Prefixes
onready var SuffixList := $CanvasLayer/GameContainer/VBoxContainer/Fragments/Suffixes
var timer:Timer

const WordList := preload("res://resources/word_list.gd")
var word_list

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


var current_curses = [
#  CURSE.PQ, CURSE.ALPHA, CURSE.VOWEL
#  CURSE.PQ, CURSE.ALLE, CURSE.ALPHA,
 ]


func _ready() -> void:
  randomize()
  word_list = WordList.new()

  create_timer()

  GameContainer.hide()

func start_game() -> void:
  score = 0
  current_curses = []
  current_round = 0
  reset_current()

  update_score()
  update_health()

  shuffle_curse_options()

  show_curse_options()


func show_curse_options() -> void:
  for i in range(NUM_CURSE_OPTIONS):
    CurseChoices[i].text = curse_descriptions[curse_options[current_round][i]]

  GameContainer.hide()
  CurseChooser.show()


func end_round() -> void:
  timer.stop()

  current_round += 1

  if current_round == num_rounds:
    end_game()
  else:
    current_state = GAMESTATE.CURSE_CHOICE
    show_curse_options()


func end_game() -> void:
  print("game over")
  GameContainer.hide()
  current_state = GAMESTATE.GAMEOVER

  GameOver.text = "Game Over!\nFinal Score: %s" % score
  GameOver.show()

  yield(get_tree().create_timer(3), "timeout")
  StartButton.show()


func curse_chosen(index: int) -> void:
  current_curses.append(curse_options[current_round][index])
  update_rules()

  current_health = MAX_HEALTH
  update_health()

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


func shuffle_curse_options():
  for i in curse_options:
    i.shuffle()


func _unhandled_key_input(event: InputEventKey) -> void:
  if current_state == GAMESTATE.PLAYING and event.pressed:
    if event.scancode >= KEY_A and event.scancode <= KEY_Z:
      var letter = OS.get_scancode_string(event.scancode).to_lower()

      if is_valid_choice(letter):
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
            if current_health == 0:
              score += 1 * current_curses.size()
              update_score()
              current_health = MAX_HEALTH
              update_health()
              current_demons -= 1

              if current_demons == 0:
                print("round complete")
                end_round()
              else:
                update_demons()
                generate_words()
            else:
              update_health()
              reset_current()

        update_typed()
      else:
        print("invalid letter: ", letter)
    elif event.scancode == KEY_BACKSPACE:
      delete_character()
      update_prefix_list()
      update_typed()


func create_timer() -> void:
  timer = Timer.new()
# warning-ignore:return_value_discarded
  timer.connect("timeout", self, "_on_timer_timeout")
  timer.set_wait_time(1)
  timer.set_one_shot(false)
  add_child(timer)


func reset_timer() -> void:
  timer.start()
  time_remaining = GAME_LENGTH
  update_clock()


func update_clock() -> void:
  Clock.text = "Time Left: %3d" % time_remaining


func update_score() -> void:
  Score.text = "Score: %d" % score


func update_health() -> void:
  Health.text = "Health: %d/%d" % [current_health, MAX_HEALTH]


func update_demons() -> void:
  Demons.text = "Demons Left: %d" % current_demons


func update_rules() -> void:
  var new_text := "Mind your "
  var and_string := ", and "
  for curse in current_curses:
    new_text += curse_descriptions[curse] + and_string
  Rules.text = new_text.trim_suffix(and_string) + "."


func update_typed() -> void:
  Typed.text = current_word.prefix + current_word.suffix


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
        match curse:
          CURSE.VOWEL:
            word = string_vowel_shift(word)
          CURSE.REVERSE:
            word = string_reverse(word)
          CURSE.PQ:
            word = string_swap(word, "p", "q")
          CURSE.DB:
            word = string_swap(word, "b", "d")
          CURSE.KC:
            word = string_swap(word, "k", "c")
          CURSE.ALPHA:
            word = string_alphabetise(word)
          CURSE.JUMBLE:
            word = string_jumble(word)
          CURSE.ROT13:
            word = string_rot(word, 13)
          CURSE.ROT1NEG:
            word = string_rot(word, -1)
          CURSE.ROT1:
            word = string_rot(word, 1)
          CURSE.ALLE:
            word = string_vowel_replace(word, "e")
          CURSE.ALLY:
            word = string_vowel_replace(word, "y")
          _:
            print("no curse implementation", curse)
            word = word
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


func string_reverse(s: String) -> String:
  var reversed := ""
  for letter_index in range(s.length() - 1, -1, -1):
    reversed += s[letter_index]
  return reversed


func string_alphabetise(s: String) -> String:
  var alphabetised := ""
  var letter_array := []

  for letter in s:
    letter_array.append(letter)
  letter_array.sort()

  for letter in letter_array:
    alphabetised += letter

  return alphabetised


func string_swap(s: String, swapa: String, swapb: String) -> String:
  var new_string := ""
  for letter in s:
    match letter:
      swapa:
        new_string += swapb
      swapb:
        new_string += swapa
      _:
        new_string += letter
  return new_string


func string_vowel_shift(s: String) -> String:
  var vowel_shifted := ""
  var vowels := "aeiou"
  var vowel_index: int
  for letter in s:
    vowel_index = vowels.find(letter)
    if vowel_index > -1:
      vowel_shifted += vowels[(vowel_index + 1) % vowels.length()]
    else:
      vowel_shifted += letter
  return vowel_shifted

func string_jumble(s: String) -> String:
  var jumbled := ""
  var jumbled_arr := []

  for letter in s:
    jumbled_arr.append(letter)
  jumbled_arr.shuffle()
  for letter in jumbled_arr:
    jumbled += letter

  return jumbled


func string_rot(s: String, value: int) -> String:
  var rotated := ""
  for letter in s:
    rotated += char(97 + ((ord(letter) + value - 97) % 26))
  return rotated


func string_vowel_replace(s: String, replace_with: String) -> String:
  var replaced := ""
  var vowels := "aeiou"
  for letter in s:
    if letter in vowels:
      replaced += replace_with
    else:
      replaced += letter
  return replaced


func _on_timer_timeout():
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


func _on_Button_pressed() -> void:
  start_game()
  StartButton.hide()
  GameOver.hide()


func _on_Choice_pressed() -> void:
  curse_chosen(0)


func _on_Choice2_pressed() -> void:
  curse_chosen(1)


func _on_Choice3_pressed() -> void:
  curse_chosen(2)
