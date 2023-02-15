extends Node2D

signal damage_taken()
signal died()


const MAX_HEALTH := 3 # should match number of head sprites
var health: int

onready var _HeadSprite := $Sprite/Head/Sprite
onready var _Animations := $AnimationPlayer



func _ready() -> void:
  health = MAX_HEALTH
  _change_face()


func _die() -> void:
  _set_playback_speed(1.0)
  _Animations.stop()
  _Animations.play("die")


func damage() -> void:
  health -= 1
  if health == 0:
    _die()
  else:
    _change_face()
    emit_signal("damage_taken")


func _change_face() -> void:
  var index := MAX_HEALTH - health
  _set_playback_speed(1.0 - index*0.33)
  _HeadSprite.frame = index


func _set_playback_speed(value: float) -> void:
  _Animations.playback_speed = value


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
  match anim_name:
    "die":
      emit_signal("died")
      queue_free()
    "spawn":
      _Animations.play("idle")
    _:
      pass

