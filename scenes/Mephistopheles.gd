extends Node2D


onready var HeadSprite := $Sprite/Head/Sprite
onready var Animations := $AnimationPlayer



func spawn() -> void:
  change_face(0)
  Animations.play("spawn")


func die() -> void:
  _set_playback_speed(1.0)
  Animations.play("die")


func change_face(index: int) -> void:
  _set_playback_speed(1.0 - index*0.33)
  HeadSprite.frame = index


func _set_playback_speed(value: float) -> void:
  Animations.playback_speed = value


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
  if anim_name == "spawn":
    Animations.play("idle")
