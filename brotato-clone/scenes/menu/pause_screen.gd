extends CanvasLayer
class_name PauseScreen
@onready var volume_setting: Control = $VolumeSetting


func _on_continue_button_pressed() -> void:
	Global.game_paused = false
	visible = false


func _on_setting_button_pressed() -> void:
	volume_setting.visible = true


func _on_back_main_button_pressed() -> void:
	get_tree().change_scene_to_file(Global.MAIN_MENU_PATH)


func _on_button_pressed() -> void:
	volume_setting.visible = false
