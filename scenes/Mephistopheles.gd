extends Node2D


onready var _HeadSprite := $Sprite/Head/Sprite
onready var _Animations := $AnimationPlayer



func _ready() -> void:
  hide()


func spawn() -> void:
  show()
  change_face(0)
  _Animations.stop()
  _Animations.play("spawn")


func die() -> void:
  _set_playback_speed(1.0)
  _Animations.stop()
  _Animations.play("die")


func change_face(index: int) -> void:
  _set_playback_speed(1.0 - index*0.33)
  _HeadSprite.frame = index


func _set_playback_speed(value: float) -> void:
  _Animations.playback_speed = value


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
  if anim_name == "spawn":
    _Animations.play("idle")
  elif anim_name == "die":
    hide()
