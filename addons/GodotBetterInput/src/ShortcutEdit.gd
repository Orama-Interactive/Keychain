extends Control

const MOUSE_BUTTON_NAMES := [
	"Left Button",
	"Right Button",
	"Middle Button",
	"Wheel Up Button",
	"Wheel Down Button",
	"Wheel Left Button",
	"Wheel Right Button",
	"X Button 1",
	"X Button 2",
]

const JOY_BUTTON_NAMES := [
	"DualShock Cross, Xbox A, Nintendo B",
	"DualShock Circle, Xbox B, Nintendo A",
	"DualShock Square, Xbox X, Nintendo Y",
	"DualShock Triangle, Xbox Y, Nintendo X",
	"L, L1",
	"R, R1",
	"L2",
	"R2",
	"L3",
	"R3",
	"Select, DualShock Share, Nintendo -",
	"Start, DualShock Options, Nintendo +",
	"D-Pad Up",
	"D-Pad Down",
	"D-Pad Left",
	"D-Pad Right",
	"Home, DualShock PS, Guide",
	"Xbox Share, PS5 Microphone, Nintendo Capture",
	"Xbox Paddle 1",
	"Xbox Paddle 2",
	"Xbox Paddle 3",
	"Xbox Paddle 4",
	"PS4/5 Touchpad",
]

const JOY_AXIS_NAMES := [
	" (Left Stick Left)",
	" (Left Stick Right)",
	" (Left Stick Up)",
	" (Left Stick Down)",
	" (Right Stick Left)",
	" (Right Stick Right)",
	" (Right Stick Up)",
	" (Right Stick Down)",
	"", "", "", "",
	"", " (L2)",
	"", " (R2)",
	"", "", "", "",
]

var groups := {}
# Textures taken from Godot https://github.com/godotengine/godot/tree/master/editor/icons
var edit_texture: Texture = preload("res://addons/GodotBetterInput/assets/edit.svg")
var delete_texture: Texture = preload("res://addons/GodotBetterInput/assets/close.svg")

onready var tree: Tree = $VBoxContainer/ShortcutTree
onready var shortcut_selector: ConfirmationDialog = $ShortcutSelector


func _ready() -> void:
	tree.columns = 2
	var tree_root: TreeItem = tree.create_item()
	tree_root.set_text(0, "Project Name")
	for action in InputMap.get_actions():
		var action_name := action as String
		var group_name := ""

		if "@" in action:
			var pos: int = action.rfind("@")
			group_name = action.right(pos + 1)
			action_name = action.left(pos)
			if not group_name in groups:
				var group_root: TreeItem = tree.create_item(tree_root)
				group_root.set_text(0, group_name)
				groups[group_name] = group_root

		var tree_item: TreeItem
		if group_name:
			tree_item = tree.create_item(groups[group_name])
		else:
			tree_item = tree.create_item(tree_root)
		tree_item.set_text(0, action_name)
		tree_item.set_text(1, action_to_str(action))
		tree_item.add_button(1, edit_texture, 0, false, "Edit")
		tree_item.add_button(1, delete_texture, 1, false, "Delete")


func action_to_str(action: String) -> String:
	var output := ""
	var i := 1
	for event in InputMap.get_action_list(action):
		var event_str := ""
		if event is InputEventKey:
			event_str = OS.get_scancode_string(event.get_scancode_with_modifiers())
		elif event is InputEventMouse:
			event_str = MOUSE_BUTTON_NAMES[event.button_index]
		elif event is InputEventJoypadButton:
			event_str = JOY_BUTTON_NAMES[event.button_index]
		elif event is InputEventJoypadMotion:
			var axis_value: int = event.axis * 2 + int(event.axis_value > 0)
			event_str = "Axis %s -%s" % [event.axis, JOY_AXIS_NAMES[axis_value]]
		output += "%s: %s " % [i, event_str]
		i += 1
	if output == "":
		output = "None"
	return output


func _on_ShortcutTree_button_pressed(item: TreeItem, column: int, id: int) -> void:
	var action: String = item.get_text(0)
	if id == 0:  # Edit
		shortcut_selector.popup_centered()
	elif id == 1:  # Delete
		for event in InputMap.get_action_list(action):
			InputMap.action_erase_event(action, event)
		item.set_text(1, "None")
