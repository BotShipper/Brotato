extends Panel
class_name ShopCard

signal on_item_purchased(item: ItemBase)

@export var shop_item: ItemBase: set = _set_shop_item

@onready var item_icon: TextureRect = %ItemIcon
@onready var item_name: Label = %ItemName
@onready var item_type: Label = %ItemType
@onready var item_description: RichTextLabel = %ItemDescription
@onready var coins_label: Label = %CoinsLabel

func _ready() -> void:
	add_to_group(Global.SHOP_TAG)

func _set_shop_item(value: ItemBase) -> void:
	shop_item = value
	item_icon.texture = value.item_icon
	item_name.text = value.item_name
	item_type.text = ItemBase.ItemType.keys()[value.item_type]
	item_description.text = value.get_description()
	coins_label.text = str(value.item_cost)
	
	var style := Global.get_tier_style(value.item_tier)
	add_theme_stylebox_override("panel", style)


func _on_buy_buttom_pressed() -> void:
	SoundManager.play_sound(SoundManager.Sound.UI)
	
	if Global.equipped_weapons.size() >= 6:
		return
	
	if Global.coins >= shop_item.item_cost:
		Global.coins -= shop_item.item_cost
		on_item_purchased.emit(shop_item)
		queue_free()
	
	var tutorial = get_tree().get_first_node_in_group(Global.TUTORIAL_GROUP)
	tutorial.check_step_condition("shop_open")
