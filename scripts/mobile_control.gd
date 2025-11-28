extends CanvasLayer
@onready var exe_1: TouchScreenButton = $MarginContainer/attack/exe1
@onready var exe_2: TouchScreenButton = $MarginContainer/attack/exe2
@onready var exe_3: TouchScreenButton = $MarginContainer/attack/exe3
@onready var exe_4: TouchScreenButton = $MarginContainer/attack/exe4
@onready var exe_5: TouchScreenButton = $MarginContainer/attack/exe5


func _ready() -> void:
	get_viewport().size = DisplayServer.screen_get_size()
