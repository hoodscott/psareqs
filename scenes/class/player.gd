extends Node
class_name Player


var devils_left :int
var score := 0
var round_num := 0
var curses := []
var _word: Dictionary = {
  "prefix": "", "suffix": "", "prefix_used": false
 }



func reset() -> void:
  score = 0
  round_num = 0
  curses = []
  reset_word()


func reset_word() -> void:
  _word.prefix = ""
  _word.suffix = ""
  _word.prefix_used = false


func get_prefix() -> String:
  return _word.prefix


func get_suffix() -> String:
  return _word.suffix


func get_word() -> String:
  return _word.prefix + _word.suffix


func add_curse(curse: int) -> void:
  curses.append(curse)


func next_round() -> int:
  round_num += 1
  return round_num


func score_add() -> void:
  score += 1 * curses.size()


func decr_devils() -> int:
  devils_left -= 1
  return devils_left


func is_prefix_complete() -> bool:
  return _word.prefix_used


func set_prefix_complete() -> void:
  _word.prefix_used = true


func prefix_add(letter: String) -> void:
  _word.prefix += letter


func suffix_add(letter: String) -> void:
  _word.suffix += letter


func delete_character() -> void:
  if _word.prefix_used and _word.suffix.length() > 0:
    _word.suffix = _word.suffix.left(_word.suffix.length() - 1)
  elif _word.prefix.length() > 0:
    _word.prefix = _word.prefix.left(_word.prefix.length() - 1)
    if is_prefix_complete():
      _word.prefix_used = false
