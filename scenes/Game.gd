extends Node2D


const MAX_HEALTH := 3 #todo - should current health be stored in devil's script instead of player object?
const WORD_BUFFER := 2
const NUM_CURSE_OPTIONS := 3
const NUM_DEVILS := 1
const GAME_LENGTH := 60

enum GAMESTATE {
  CURSE_CHOICE = 0,
  PLAYING = 1,
  GAMEOVER = 2
 }
var current_state = GAMESTATE.CURSE_CHOICE

onready var UI := $UI
onready var Mephistopheles := $Mephistopheles
onready var word_list := WordList.new()
onready var curses := Curses.new()
onready var player := Player.new()

var prefixes := [] #: [Dictionary{fragment, used}]
var suffixes := [] #: [Dictionary{fragment, used}]



func _ready() -> void:
  randomize()
  seed(1)

  if (\
    UI.connect("game_started", self, "start_game") != OK or\
    UI.connect("game_ended", self, "end_game") != OK or\
    UI.connect("curse_chosen", self, "curse_chosen") != OK):
      print("error connecting UI signals")

  UI.GAME_LENGTH = GAME_LENGTH


func start_game() -> void:
  player.reset()

  UI.update_score(player.score)
  UI.update_typed(player.get_word())

  curses.shuffle_curse_options()
  show_curse_options()


func curse_chosen(index: int) -> void:
  UI.AudioManager.play_button_press()

  player.add_curse(curses.get_option(player.round_num, index))
  show_rules()

  start_round()


func start_round() -> void:
  player.devils_left = NUM_DEVILS
  UI.update_devils(player.devils_left)

  UI.reset_timer()

  UI.show_game()

  current_state = GAMESTATE.PLAYING

  spawn_devil()


func spawn_devil() -> void:
  player.devil_health = MAX_HEALTH
  Mephistopheles.spawn()

  generate_words()


func generate_words() -> void:
  prefixes = []
  suffixes = []
  for word in word_list.choose_prefixes(MAX_HEALTH + WORD_BUFFER):
    prefixes.append({"fragment": word, "used": false, "current": false})
  for word in word_list.choose_suffixes(MAX_HEALTH + WORD_BUFFER):
    suffixes.append({"fragment": word, "used": false, "current": false})

  # apply curses
  for fragment in prefixes:
    var word: String = fragment.fragment
    for curse in player.curses:
      word = curses.apply_curse(word, curse)
    fragment.word = word
  for fragment in suffixes:
    var word: String = fragment.fragment
    for curse in player.curses:
      word = curses.apply_curse(word, curse)
    fragment.word = word

  UI.update_prefix_list(prefixes)
  UI.update_suffix_list(suffixes)

  player.reset_word()


func end_round() -> void:
  UI.stop_timer()


  if player.next_round() == curses.num_rounds:
    end_game()
  else:
    current_state = GAMESTATE.CURSE_CHOICE
    show_curse_options()


func end_game() -> void:
  print("game over")
  current_state = GAMESTATE.GAMEOVER

  UI.end_game(player.score)


func _unhandled_key_input(event: InputEventKey) -> void:
  if current_state == GAMESTATE.PLAYING and event.pressed:
    if event.scancode >= KEY_A and event.scancode <= KEY_Z:
      var letter = OS.get_scancode_string(event.scancode).to_lower()

      if is_valid_choice(letter):
        UI.AudioManager.play_correct_letter()
        if not player.is_prefix_complete():
          player.prefix_add(letter)
          if check_prefix_complete():
            player.set_prefix_complete()
            UI.update_prefix_list(prefixes)
        else:
          player.suffix_add(letter)
          if check_word_complete():
            for prefix in prefixes:
              if prefix.current:
                prefix.current = false
                prefix.used = true
            UI.update_prefix_list(prefixes)

            for suffix in suffixes:
              if suffix.current:
                suffix.current = false
                suffix.used = true
            UI.update_suffix_list(suffixes)

            print("word complete")
            player.damage()
            Mephistopheles.change_face(MAX_HEALTH - player.devil_health)
            UI.AudioManager.play_word_complete()

            if player.devil_health == 0:
              Mephistopheles.die()
              UI.AudioManager.play_devil_death()

              player.score_add()
              UI.update_score(player.score)
              player.devil_health = MAX_HEALTH
              Mephistopheles.spawn()


              if player.decr_devils() == 0:
                print("round complete")
                end_round()
              else:
                UI.AudioManager.play_devil_spawn()
                UI.update_devils(player.devils_left)
                generate_words()
            else:
              player.reset_word()

        UI.update_typed(player.get_word())
      else:
        UI.AudioManager.play_incorrect_letter()
        print("invalid letter: ", letter)
    elif event.scancode == KEY_BACKSPACE:
      player.delete_character()
      if not player.is_prefix_complete():
        for prefix in prefixes:
          prefix.current = false
      UI.update_prefix_list(prefixes)
      UI.update_typed(player.get_word())


func is_valid_choice(letter: String) -> bool:
  var list
  var new_word: String

  # are we checking prefixes or suffixes?
  if not player.is_prefix_complete():
    list = prefixes
    new_word = player.get_prefix()
  else:
    list = suffixes
    new_word = player.get_suffix()
  new_word += letter

  # check left x letters match current word + new letter
  for word in list:
    if not word.used and new_word == word.fragment.left(new_word.length()):
      return true
  return false


func check_prefix_complete() -> bool:
  for prefix in prefixes:
    if prefix.fragment == player.get_prefix():
      prefix.current = true
      return true
  return false


func check_word_complete() -> bool:
  for suffix in suffixes:
    if suffix.fragment == player.get_suffix():
      suffix.current = true
      return true
  return false


func show_curse_options() -> void:
  for i in range(NUM_CURSE_OPTIONS):
    UI.show_curse_option(curses.get_round_description(player.round_num, i), i)


func show_rules() -> void:
  var curse_descs := []
  for curse in player.curses:
    curse_descs.append(curses.get_description(curse))
  UI.update_rules(curse_descs)
