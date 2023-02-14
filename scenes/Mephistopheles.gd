extends Node2D


onready var HeadSprite := $Sprite/Head/Sprite
onready var Animations := $AnimationPlayer



func spawn() -> void:
  change_face(0)
  Animations.play("spawn")


func die() -> void:
  Animations.play("die")


func change_face(index: int) -> void:
  HeadSprite.frame = index


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
  if anim_name == "spawn":
    Animations.play("idle")
