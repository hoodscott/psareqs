extends Node

class_name WordList

const prefixes = [
  "dumb", "bum", "poop",
  "dirt", "scum", "mud",
  "dip",
  "monkey", "turtle", "fish", "horse", "pig"
 ]
const suffixes = [
  "goblin", "wit", "stick", "stain", "clown",
  "hat", "bag",
  "crab",
  "brain", "head"
 ]

var prefixes_shuffled := []
var suffixes_shuffled := []


func _init():
  randomize()


func shuffle_prefixes() -> void:
  prefixes_shuffled = prefixes.duplicate()
  prefixes_shuffled.shuffle()


func shuffle_suffixes() -> void:
  suffixes_shuffled = suffixes.duplicate()
  suffixes_shuffled.shuffle()


func choose_prefixes(count: int):# -> []:
  var chosen = []
  var new_prefix: String
  while chosen.size() < count:
    new_prefix = choose_prefix()
    if not chosen.has(new_prefix):
      chosen.append(new_prefix)
  return chosen


func choose_suffixes(count: int):# -> []:
  var chosen = []
  var new_suffix: String
  while chosen.size() < count:
    new_suffix = choose_suffix()
    if not chosen.has(new_suffix):
      chosen.append(new_suffix)
  return chosen


func choose_prefix() -> String:
  if prefixes_shuffled.empty():
    shuffle_prefixes()
  return prefixes_shuffled.pop_front()


func choose_suffix() -> String:
  if suffixes_shuffled.empty():
    shuffle_suffixes()
  return suffixes_shuffled.pop_front()
