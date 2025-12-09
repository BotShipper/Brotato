extends CanvasLayer
class_name PauseScreen


func _on_continue_button_pressed() -> void:
	Global.game_paused = false
	visible = false


func _on_setting_button_pressed() -> void:
	pass # Replace with function body.


func _on_back_main_button_pressed() -> void:
	get_tree().change_scene_to_file(Global.MAIN_MENU_PATH)
