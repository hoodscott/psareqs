extends Node
class_name WordList


const _prefixes = [
  "dumb", "bum", "poop",
  "dirt", "scum", "mud",
  "dip",
  "monkey", "turtle", "fish", "horse", "pig"
 ]
const _suffixes = [
  "goblin", "wit", "stick", "stain", "clown",
  "hat", "bag",
  "crab",
  "brain", "head"
 ]

var _prefixes_shuffled := []
var _suffixes_shuffled := []



func choose_prefixes(count: int):# -> []:
  var chosen = []
  var new_prefix: String
  while chosen.size() < count:
    new_prefix = _choose_prefix()
    if not chosen.has(new_prefix):
      chosen.append(new_prefix)
  return chosen


func choose_suffixes(count: int):# -> []:
  var chosen = []
  var new_suffix: String
  while chosen.size() < count:
    new_suffix = _choose_suffix()
    if not chosen.has(new_suffix):
      chosen.append(new_suffix)
  return chosen


func _shuffle_prefixes() -> void:
  _prefixes_shuffled = _prefixes.duplicate()
  _prefixes_shuffled.shuffle()


func _shuffle_suffixes() -> void:
  _suffixes_shuffled = _suffixes.duplicate()
  _suffixes_shuffled.shuffle()


func _choose_prefix() -> String:
  if _prefixes_shuffled.empty():
    _shuffle_prefixes()
  return _prefixes_shuffled.pop_front()


func _choose_suffix() -> String:
  if _suffixes_shuffled.empty():
    _shuffle_suffixes()
  return _suffixes_shuffled.pop_front()
