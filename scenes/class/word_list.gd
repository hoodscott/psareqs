extends Node
class_name WordList


const _prefixes = [
  "dumb", "bum", "poop", "snot", "toilet",
  "dirt", "scum", "mud", "stink", "clod",
  "bean", "onion", "cabbage", "potato", "pea",
  "dip", "horn", "eel", "dog", "crab",
  "horse", "pig", "sheep", "goat", "bull",
  "goose", "duck", "chicken", "pigeon", "rabbit",
  "monkey", "squirrel", "turtle", "fish", "rat"
 ] #35
const _suffixes = [
  "goblin", "clown", "gremlin", "bogey", "troll",
  "wit", "stick", "stain", "smudge", "wipe",
  "head", "foot", "toe", "hoof", "legs",
  "eyes", "hat", "cap", "pants", "vest",
  "shoe", "sock", "slipper", "bag", "drum",
  "crab", "slug", "snake", "worm", "grub",
  "brain", "guts", "mouth", "breath", "whiff"
 ] #35

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
