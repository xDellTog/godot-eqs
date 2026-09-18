extends Node3D

@onready var avoidance_label: Label = $UI/Container/AvoidanceLabel

func _ready() -> void:
    avoidance_label.text = "Navigation Agent > Avoidance > On"
