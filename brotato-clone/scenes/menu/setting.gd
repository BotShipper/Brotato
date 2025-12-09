extends VBoxContainer

# Tham chiếu đến các slider
@onready var master_slider: HSlider = $MasterVolume/HSlider
@onready var music_slider: HSlider = $MusicVolume/HSlider
@onready var sfx_slider: HSlider = $SFXVolume/HSlider

# Tham chiếu đến các label hiển thị phần trăm
@onready var master_label: Label = $MasterVolume/Label
@onready var music_label: Label = $MusicVolume/Label
@onready var sfx_label: Label = $SFXVolume/Label

# Tên các bus trong Audio Bus Layout
const MASTER_BUS = "Master"
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

func _ready():
	# Kết nối signal từ slider
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Load setting đã lưu
	load_volume_settings()

func _on_master_volume_changed(value: float):
	set_bus_volume(MASTER_BUS, value)
	master_label.text = "Master: %d%%" % value
	save_volume_settings()

func _on_music_volume_changed(value: float):
	set_bus_volume(MUSIC_BUS, value)
	music_label.text = "Music: %d%%" % value
	save_volume_settings()

func _on_sfx_volume_changed(value: float):
	set_bus_volume(SFX_BUS, value)
	sfx_label.text = "SFX: %d%%" % value
	save_volume_settings()
	
	# Phát sound effect test khi điều chỉnh
	play_test_sound()

func set_bus_volume(bus_name: String, value: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	
	if value == 0:
		# Mute nếu slider ở 0
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		# Chuyển từ phần trăm (0-100) sang decibel
		var db = linear_to_db(value / 100.0)
		AudioServer.set_bus_volume_db(bus_index, db)

func save_volume_settings():
	# Lưu settings vào file
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_slider.value)
	config.set_value("audio", "music_volume", music_slider.value)
	config.set_value("audio", "sfx_volume", sfx_slider.value)
	config.save("user://audio_settings.cfg")

func load_volume_settings():
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	
	if err == OK:
		# Load giá trị đã lưu
		master_slider.value = config.get_value("audio", "master_volume", 100)
		music_slider.value = config.get_value("audio", "music_volume", 80)
		sfx_slider.value = config.get_value("audio", "sfx_volume", 80)
	else:
		# Giá trị mặc định
		master_slider.value = 100
		music_slider.value = 80
		sfx_slider.value = 80

func play_test_sound():
	# Optional: Phát một sound effect test
	# Bạn cần có AudioStreamPlayer với tên $TestSFX
	if has_node("TestSFX"):
		$TestSFX.play()
