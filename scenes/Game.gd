extends Node2D

const WORD_BUFFER := 2 # possible words = devil's max health + word_buffer
const NUM_CURSE_OPTIONS := 3
const NUM_DEVILS := 2 # per round
const GAME_LENGTH := 60 # in seconds

const CHEATING := true

enum GAMESTATE {
  CURSE_CHOICE = 0,
  PLAYING = 1,
  GAMEOVER = 2,
  DAMAGING = 3
 }
var current_state = GAMESTATE.GAMEOVER

onready var UI := $UI
onready var DevilSpawn := $DevilSpawn
onready var word_list := WordList.new()
onready var curses := Curses.new()
onready var player := Player.new()

var prefixes := [] #: [Dictionary{fragment, used}]
var suffixes := [] #: [Dictionary{fragment, used}]

onready var Mephistopheles: PackedScene = preload("res://scenes/devils/mephistopheles/Mephistopheles.tscn")
var devil:Node2D


func _ready() -> void:
  randomize()

  if (\
    UI.connect("game_started", self, "start_game") != OK or\
    UI.connect("game_restarted", self, "restart_game") != OK or\
    UI.connect("game_ended", self, "end_game") != OK or\
    UI.connect("curse_chosen", self, "curse_chosen") != OK):
      print("error connecting UI signals")

  UI.GAME_LENGTH = GAME_LENGTH


func start_game() -> void:
  player.reset()

  UI.update_score(player.score)
  UI.update_typed(player.get_word(), true)

  curses.shuffle_curse_options()
  show_curse_options()


func curse_chosen(index: int) -> void:
  UI.AudioManager.play_button_press()

  player.add_curse(curses.get_option(player.round_num, index))
  show_rules()
  show_multiplier()

  start_round()


func start_round() -> void:
  player.devils_left = NUM_DEVILS
  UI.update_devils(player.devils_left)

  UI.reset_timer()
  UI.show_game()

  spawn_devil()


func spawn_devil() -> void:
  devil = Mephistopheles.instance()
  DevilSpawn.add_child(devil)
  UI.AudioManager.play_devil_spawn()
  UI.update_devils(player.devils_left)

  if (\
    devil.connect("died", self, "_on_devil_died") != OK or\
    devil.connect("damage_taken", self, "_on_devil_damaged") != OK):
      print("error connecting devil signals")

  generate_words()
  current_state = GAMESTATE.PLAYING


func generate_words() -> void:
  prefixes = []
  suffixes = []
  for word in word_list.choose_prefixes(devil.MAX_HEALTH + WORD_BUFFER):
    prefixes.append({"fragment": word, "used": false, "current": false})
  for word in word_list.choose_suffixes(devil.MAX_HEALTH + WORD_BUFFER):
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


func end_round() -> void:
  UI.stop_timer()


  if player.next_round() == curses.num_rounds:
    end_game(true)
  else:
    show_curse_options()


func end_game(won := false) -> void:
  current_state = GAMESTATE.GAMEOVER
  for child in DevilSpawn.get_children():
    child.queue_free()

  UI.end_game(player.score, false, won)


func restart_game() -> void:
  current_state = GAMESTATE.GAMEOVER
  for child in DevilSpawn.get_children():
    child.queue_free()

  UI.end_game(0,true)
  UI.reset()

func _unhandled_key_input(event: InputEventKey) -> void:
  if event.pressed:
    match current_state:
      GAMESTATE.GAMEOVER:
        if is_focus_event(event):
          UI.focus_start()

      GAMESTATE.CURSE_CHOICE:
        if is_focus_event(event):
          UI.focus_choice()

      GAMESTATE.PLAYING:
        if event.scancode >= KEY_A and event.scancode <= KEY_Z:
          if CHEATING:
            if not player.is_prefix_complete():
              for prefix in prefixes:
                if not prefix.used:
                  prefix.current = true
                  player.prefix_add(prefix.fragment)
                  UI.update_typed(player.get_word())
                  player.set_prefix_complete()
                  break
              UI.update_prefix_list(prefixes)
            else:
              for suffix in suffixes:
                if not suffix.used:
                  suffix.current = true
                  player.prefix_add(suffix.fragment)
                  UI.update_typed(player.get_word())
                  break
              word_complete()
          else:
            var letter = OS.get_scancode_string(event.scancode).to_lower()

            if is_valid_choice(letter):
              UI.AudioManager.play_correct_letter()
              if not player.is_prefix_complete():
                player.prefix_add(letter)
                UI.update_typed(player.get_word())
                if check_prefix_complete():
                  player.set_prefix_complete()
                  UI.update_prefix_list(prefixes)
              else:
                player.suffix_add(letter)
                UI.update_typed(player.get_word())
                if check_word_complete():
                  word_complete()
            else:
              UI.incorrect_letter(letter)
        elif event.scancode == KEY_BACKSPACE:
          if player.get_word().length() > 0:
            UI.AudioManager.play_correct_letter()
            player.delete_character()
            if not player.is_prefix_complete():
              for prefix in prefixes:
                prefix.current = false
            UI.update_prefix_list(prefixes)
            UI.update_typed(player.get_word())
          else:
            UI.incorrect_letter("")


func is_focus_event(event: InputEventKey) -> bool:
  return event.is_action("ui_right") or event.is_action("ui_up") or \
    event.is_action("ui_left") or event.is_action("ui_down") or \
    event.is_action("ui_focus_next") or event.is_action("ui_focus_prev")


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


func word_complete() -> void:
  current_state = GAMESTATE.DAMAGING

  UI.word_complete()

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

  devil.damage()
  if devil.health == 0:
    UI.AudioManager.play_devil_death()
  UI.AudioManager.play_word_complete()

  player.reset_word()
  UI.update_typed(player.get_word())


func _on_devil_died() -> void:
  var score = UI.get_seconds_left() * curses.calc_curse_multiplier(player.curses)
  player.score_add(score)
  UI.update_score(player.score)

  if player.decr_devils() == 0:
    end_round()
  else:
    spawn_devil()


func _on_devil_damaged() -> void:
  current_state = GAMESTATE.PLAYING


func show_curse_options() -> void:
  current_state = GAMESTATE.CURSE_CHOICE
  for i in range(NUM_CURSE_OPTIONS):
    UI.show_curse_option(curses.get_round_description(player.round_num, i), i)


func show_rules() -> void:
  var curse_descs := []
  for curse in player.curses:
    curse_descs.append(curses.get_description(curse))
  UI.update_rules(curse_descs)


func show_multiplier() -> void:
  UI.update_multiplier(curses.calc_curse_multiplier(player.curses))
