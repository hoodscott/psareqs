extends Node
class_name Curses


enum CURSE {
  PQ = 0,
  DB = 1,
  VOWEL = 2,
  ALPHA = 3,
  REVERSE = 4,
  UNIMPLEMENTED = 5,
  JUMBLE = 6,
  ROT13 = 7,
  ROT1 = 8,
  ROT1NEG = 9,
  ALLE = 10,
  KC = 11,
  ALLY = 12,
  ALLO = 13,
  UNVOWEL = 14,
  FG = 15,
  LT = 16,
  RS = 17, # description reads awkwardly
  VOWELPAIR = 18
 }
const _curse_descriptions = [
  "Ps are Qs", "Ds are Bs", "vowels are shifted (a>e>i>o>u>a)",
  "words are alphabetised", "words are reversed", "UNIMPLEMENTED",
  "words are jumbled",  "words are ciphered using rot13 (a>m>a, b>n>b)",
  "letters are shifted (a>b>c>...)", "letters are shifted backwards (c>b>a>z>...)",
  "vowels are all E", "Ks are Cs", "vowels are all Y", "vowels are all O",
  "vowels are unshifted (a>u>o>i>e>a)", "Fs are Gs", "Ls are Ts",
  "Rs are Ss", "vowel pairs are flipped"
 ]
var _curse_multipliers = {
  # letter swap
  CURSE.PQ: 1,
  CURSE.DB: 1,
  CURSE.KC: 1,
  CURSE.FG: 1,
  CURSE.LT: 1,
  CURSE.RS: 1,

  # vowel change easy
  CURSE.VOWELPAIR: 1,
  # vowel change medium
  CURSE.VOWEL: 2,
  CURSE.UNVOWEL: 2,
  # vowel change hard
  CURSE.ALLE: 4,
  CURSE.ALLY: 4,
  CURSE.ALLO: 3,

  # word reorder easy
  CURSE.REVERSE: 2,
  # word reorder medium
  CURSE.ROT1: 4,
  CURSE.ROT1NEG: 4,
  CURSE.JUMBLE: 4,
  CURSE.ALPHA: 4,
  # word reorder hard
  CURSE.ROT13: 16,
 }
var _curse_options := [
  # 1: letter swaps
  [CURSE.PQ, CURSE.DB, CURSE.KC, CURSE.FG, CURSE.LT],
  # 2: vowel changes
  [
    CURSE.VOWEL, CURSE.UNVOWEL, CURSE.VOWELPAIR,
    CURSE.ALLE, CURSE.ALLY, CURSE.ALLO
  ],
  # 3: word reorder
  [
    CURSE.REVERSE, CURSE.JUMBLE, CURSE.ALPHA,
    CURSE.ROT1, CURSE.ROT1NEG, CURSE.ROT13
  ]
 ]
var num_rounds = _curse_options.size()



func apply_curse(word: String, curse: int) -> String:
  match curse:
    CURSE.VOWEL:
      word = _vowel_shift(word)
    CURSE.UNVOWEL:
      word = _vowel_shift(word, true)
    CURSE.VOWELPAIR:
      word = _vowel_pair_flip(word)
    CURSE.REVERSE:
      word = _reverse(word)
    CURSE.PQ:
      word = _swap(word, "p", "q")
    CURSE.DB:
      word = _swap(word, "b", "d")
    CURSE.KC:
      word = _swap(word, "k", "c")
    CURSE.FG:
      word = _swap(word, "f", "g")
    CURSE.LT:
      word = _swap(word, "l", "t")
    CURSE.ALPHA:
      word = _alphabetise(word)
    CURSE.JUMBLE:
      word = _jumble(word)
    CURSE.ROT13:
      word = _rot(word, 13)
    CURSE.ROT1NEG:
      word = _rot(word, -1)
    CURSE.ROT1:
      word = _rot(word, 1)
    CURSE.ALLE:
      word = _vowel_replace(word, "e")
    CURSE.ALLY:
      word = _vowel_replace(word, "y")
    CURSE.ALLO:
      word = _vowel_replace(word, "o")
    _:
      print("no curse implementation", curse)
      word = word
  return word


func get_description(curse: int) -> String:
  return _curse_descriptions[curse]


func get_round_description(current_round: int, index: int) -> String:
  var text = _curse_descriptions[_curse_options[current_round][index]]
  text += " (x%s)" % _curse_multipliers[_curse_options[current_round][index]]
  return text


func get_option(current_round: int, index: int) -> int:
  return _curse_options[current_round][index]


func shuffle_curse_options() -> void:

  for i in _curse_options:
    i.shuffle()


func calc_curse_multiplier(curses) -> int:
  var mult = 1

  for curse in curses:
    mult *= _curse_multipliers[curse]

  return mult


func _reverse(s: String) -> String:
  var reversed := ""
  for letter_index in range(s.length() - 1, -1, -1):
    reversed += s[letter_index]
  return reversed


func _alphabetise(s: String) -> String:
  var alphabetised := ""
  var letter_array := []

  for letter in s:
    letter_array.append(letter)
  letter_array.sort()

  for letter in letter_array:
    alphabetised += letter

  return alphabetised


func _swap(s: String, swapa: String, swapb: String) -> String:
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


func _vowel_shift(s: String, reverse := false) -> String:
  var vowel_shifted := ""
  var vowels := "aeiou"
  if reverse:
    vowels = _reverse(vowels)
  var vowel_index: int
  for letter in s:
    vowel_index = vowels.find(letter)
    if vowel_index > -1:
      vowel_shifted += vowels[(vowel_index + 1) % vowels.length()]
    else:
      vowel_shifted += letter
  return vowel_shifted

func _jumble(s: String) -> String:
  var jumbled := ""
  var jumbled_arr := []

  for letter in s:
    jumbled_arr.append(letter)
  jumbled_arr.shuffle()
  for letter in jumbled_arr:
    jumbled += letter

  return jumbled


func _rot(s: String, value: int) -> String:
  var rotated := ""
  for letter in s:
    rotated += char(97 + ((ord(letter) + value - 97) % 26))
  return rotated


func _vowel_replace(s: String, replace_with: String) -> String:
  var replaced := ""
  var vowels := "aeiou"
  for letter in s:
    if letter in vowels:
      replaced += replace_with
    else:
      replaced += letter
  return replaced


func _vowel_pair_flip(s: String) -> String:
  var flipped := ""
  var vowels := "aeiou"
  var prev_vowel := ""

  for letter in s:
    if not letter in vowels:
      if prev_vowel != "":
        flipped += prev_vowel
        prev_vowel = ""
      flipped += letter
    else:
      if prev_vowel == "":
        prev_vowel = letter
      else:
        flipped += letter + prev_vowel
        prev_vowel = ""

  return flipped + prev_vowel
