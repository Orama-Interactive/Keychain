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
var add_texture: Texture = preload("res://addons/GodotBetterInput/assets/add.svg")
var edit_texture: Texture = preload("res://addons/GodotBetterInput/assets/edit.svg")
var delete_texture: Texture = preload("res://addons/GodotBetterInput/assets/close.svg")
var joy_axis_texture: Texture = preload("res://addons/GodotBetterInput/assets/joy_axis.svg")
var joy_button_texture: Texture = preload("res://addons/GodotBetterInput/assets/joy_button.svg")
var keyboard_texture: Texture = preload("res://addons/GodotBetterInput/assets/keyboard.svg")
var keyboard_physical_texture: Texture = preload("res://addons/GodotBetterInput/assets/keyboard_physical.svg")
var mouse_texture: Texture = preload("res://addons/GodotBetterInput/assets/mouse.svg")

onready var tree: Tree = $VBoxContainer/ShortcutTree
onready var shortcut_selector: ConfirmationDialog = $ShortcutSelector


func _ready() -> void:
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
		tree_item.set_metadata(0, action)
		for event in InputMap.get_action_list(action):
			var event_tree_item: TreeItem = tree.create_item(tree_item)
			event_tree_item.set_text(0, event_to_strs(event))
			event_tree_item.set_metadata(0, event)
			match event.get_class():
				"InputEventJoypadMotion":
					event_tree_item.set_icon(0, joy_axis_texture)
				"InputEventJoypadButton":
					event_tree_item.set_icon(0, joy_button_texture)
				"InputEventKey":
					var scancode:int = event.get_scancode_with_modifiers()
					if scancode > 0:
						event_tree_item.set_icon(0, keyboard_texture)
					else:
						event_tree_item.set_icon(0, keyboard_physical_texture)
				"InputEventMouseButton":
					event_tree_item.set_icon(0, mouse_texture)
			event_tree_item.add_button(0, edit_texture, 0, false, "Edit")
			event_tree_item.add_button(0, delete_texture, 1, false, "Delete")

		tree_item.add_button(0, add_texture, 0, false, "Add")
		tree_item.add_button(0, delete_texture, 1, false, "Delete")
		tree_item.collapsed = true


func event_to_strs(event: InputEvent) -> String:
	var output := ""
	if event is InputEventKey:
		var scancode:int = event.get_scancode_with_modifiers()
		var physical_str := ""
		if scancode == 0:
			scancode = event.get_physical_scancode_with_modifiers()
			physical_str = " " + tr("(Physical)")
		output = OS.get_scancode_string(scancode) + physical_str
	elif event is InputEventMouseButton:
		output = MOUSE_BUTTON_NAMES[event.button_index]
	elif event is InputEventJoypadButton:
		output = JOY_BUTTON_NAMES[event.button_index]
	elif event is InputEventJoypadMotion:
		var axis_value: int = event.axis * 2 + int(event.axis_value > 0)
		output = "Axis %s -%s" % [event.axis, JOY_AXIS_NAMES[axis_value]]
	return output


func _on_ShortcutTree_button_pressed(item: TreeItem, column: int, id: int) -> void:
	var action = item.get_metadata(0)
	if action is String:
		if id == 0:  # Edit
			shortcut_selector.popup_centered()
		elif id == 1:  # Delete
			for event in InputMap.get_action_list(action):
				InputMap.action_erase_event(action, event)
			var child := item.get_children()
			while child != null:
				child.free()
				child = item.get_children()

	elif action is InputEvent:
		if id == 0:  # Edit
			shortcut_selector.popup_centered()
		elif id == 1:  # Delete
			var parent_action = item.get_parent().get_metadata(0)
			if not parent_action is String:
				return
			InputMap.action_erase_event(parent_action, action)
			item.free()


func _on_ShortcutTree_item_activated() -> void:
	print("e")
