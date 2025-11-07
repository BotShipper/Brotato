extends Control
class_name MainMenu

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(Global.ARENA_SCENE_PATH)


func _on_setting_button_pressed() -> void:
	print("Setting clicked")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
