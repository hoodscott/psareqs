extends PanelContainer

var text: String
onready var LabelNode := $MarginContainer/Label


func _ready() -> void:
  LabelNode.text = text


func _process(_delta: float) -> void:
  rect_pivot_offset = rect_size / 2


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
  if anim_name == "spawn":
    queue_free()
