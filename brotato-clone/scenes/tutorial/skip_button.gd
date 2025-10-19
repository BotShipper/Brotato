extends Button


func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	# Lấy TutorialManager
	var tutorial_manager = get_tree().get_first_node_in_group("tutorial_manager")
	if tutorial_manager:
		tutorial_manager.skip_tutorial()
