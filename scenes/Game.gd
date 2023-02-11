extends Node2D

export (int) var GAME_LENGTH := 60
export (int) var MAX_HEALTH := 2
export (int) var WORD_BUFFER := 3

enum CURSE {
  PQ = 0,
  DB = 1,
  VOWEL = 2,
  ALPHA = 3,
  REVERSE = 4,
  FLIP = 5, #todo (need to change pivot point of PrefixList and then rotate 180 (remember to reset)
  JUMBLE = 6, #todo fix bug where word is rejumbled when label prefixe labels regenerated
  ROT13 = 7,
  ROT1 = 8,
  ROT1NEG = 9,
  ALLE = 10
 }

onready var GameOver = $CanvasLayer/CenterContainer/VBoxContainer/GameOver
onready var StartButton = $CanvasLayer/CenterContainer/VBoxContainer/StartButton
onready var Clock = $CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Clock
onready var Score = $CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Score
onready var Health = $CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Health
onready var Typed = $CanvasLayer/MarginContainer/VBoxContainer/Typed
onready var PrefixList = $CanvasLayer/MarginContainer/VBoxContainer/Fragments/Prefixes
onready var SuffixList = $CanvasLayer/MarginContainer/VBoxContainer/Fragments/Suffixes
var timer:Timer

const WordList := preload("res://resources/word_list.gd")
var word_list

var prefixes := [] #: [Dictionary{fragment, used}]
var suffixes := [] #: [Dictionary{fragment, used}]
var current_word: Dictionary = {
  "prefix": "", "suffix": "", "prefix_used": false
 }

var current_health := MAX_HEALTH
var time_remaining := 0
var score := 0

var playing := false

var curses = [
#  CURSE.PQ, CURSE.ALPHA, CURSE.VOWEL
  CURSE.ALLE,
 ]


func _ready() -> void:
  randomize()
  word_list = WordList.new()

  create_timer()

func start_game() -> void:
  score = 0
  current_health = MAX_HEALTH
  reset_current()

  update_score()
  update_health()

  generate_words()

  reset_timer()

  playing = true


func end_game() -> void:
  playing = false
  timer.stop()
  print("game over")

  GameOver.text = "Game Over!\nFinal Score: %s" % score
  GameOver.show()

  yield(get_tree().create_timer(3), "timeout")
  StartButton.show()


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
  if playing and event.pressed:
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
              score += 1 * curses.size()
              update_score()
              current_health = MAX_HEALTH
              update_health()
              generate_words()
            else:
              update_health()
              reset_current()

        update_label()
      else:
        print("invalid letter: ", letter)
    elif event.scancode == KEY_BACKSPACE:
      delete_character()
      update_prefix_list()
      update_label()


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


func update_label() -> void:
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
      for curse in curses:
        match curse:
          CURSE.VOWEL:
            word = string_vowel_shift(word)
          CURSE.REVERSE:
            word = string_reverse(word)
          CURSE.PQ:
            word = string_swap(word, "p", "q")
          CURSE.DB:
            word = string_swap(word, "b", "d")
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
      end_game()
  else:
    # shouldn't get here, but end here as well just in case
    end_game()
    print("game over")
    timer.stop()


func _on_Button_pressed() -> void:
  start_game()
  StartButton.hide()
  GameOver.hide()
