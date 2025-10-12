extends Control
class_name MainMenu

const ARENA_SCENE = "res://scenes/arena/arena.tscn"

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(ARENA_SCENE)


func _on_setting_button_pressed() -> void:
	print("Setting clicked")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
