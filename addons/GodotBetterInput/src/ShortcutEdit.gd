extends Control

enum { KEYBOARD, MOUSE, JOY_BUTTON, JOY_AXIS }

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
	"",
	"",
	"",
	"",
	"",
	" (L2)",
	"",
	" (R2)",
	"",
	"",
	"",
	"",
]

export(Array, String) var ignore_actions := []
export(bool) var ignore_ui_actions := false
export(Array, bool) var changeable_types := [true, true, true, false]

var actions := {
	"test_action": InputAction.new("Test Action", "GroupOne"),
	"input": InputAction.new("Input"),
	"nicer_input": InputAction.new("", "GroupOne"),
	"hello": InputAction.new("Howdy!", "Test"),
	"grandchild": InputAction.new("Grandchild Action", "Child"),
	"sibling": InputAction.new("Sibling", "Child"),
}
var groups := {
	"GroupOne": InputGroup.new(),
	"Grandparent": InputGroup.new(),
	"Parent": InputGroup.new("Grandparent"),
	"Child": InputGroup.new("Parent"),
}
var currently_editing_tree_item: TreeItem
var listening_for_input: int = KEYBOARD
var listened_input: InputEvent

# Textures taken from Godot https://github.com/godotengine/godot/tree/master/editor/icons
var add_tex: Texture = preload("res://addons/GodotBetterInput/assets/add.svg")
var edit_tex: Texture = preload("res://addons/GodotBetterInput/assets/edit.svg")
var delete_tex: Texture = preload("res://addons/GodotBetterInput/assets/close.svg")
var joy_axis_tex: Texture = preload("res://addons/GodotBetterInput/assets/joy_axis.svg")
var joy_button_tex: Texture = preload("res://addons/GodotBetterInput/assets/joy_button.svg")
var key_tex: Texture = preload("res://addons/GodotBetterInput/assets/keyboard.svg")
var key_phys_tex: Texture = preload("res://addons/GodotBetterInput/assets/keyboard_physical.svg")
var mouse_tex: Texture = preload("res://addons/GodotBetterInput/assets/mouse.svg")
var shortcut_tex: Texture = preload("res://addons/GodotBetterInput/assets/shortcut.svg")
var folder_tex: Texture = preload("res://addons/GodotBetterInput/assets/folder.svg")

onready var tree: Tree = $VBoxContainer/ShortcutTree
onready var shortcut_type_menu: PopupMenu = $ShortcutTypeMenu
onready var keyboard_shortcut_selector: ConfirmationDialog = $KeyboardShortcutSelector
onready var mouse_shortcut_selector: ConfirmationDialog = $MouseShortcutSelector
onready var joy_key_shortcut_selector: ConfirmationDialog = $JoyKeyShortcutSelector
onready var joy_axis_shortcut_selector: ConfirmationDialog = $JoyAxisShortcutSelector
onready var key_shortcut_label: Label = keyboard_shortcut_selector.find_node("EnteredShortcutLabel")


class InputAction:
	var display_name := ""
	var group := ""

	func _init(_display_name := "", _group := "") -> void:
		display_name = _display_name
		group = _group


class InputGroup:
	var parent_group := ""
	var tree_item: TreeItem

	func _init(_parent_group := "") -> void:
		parent_group = _parent_group


func _ready() -> void:
	set_process_input(false)
	_fill_selector_options()
	var i := 0
	for type in changeable_types:
		if !type:
			shortcut_type_menu.remove_item(i)
		else:
			i += 1

	var tree_root: TreeItem = tree.create_item()
	for group in groups:  # Create groups
		var input_group: InputGroup = groups[group]
		_create_group_tree_item(input_group, group)

	for action in InputMap.get_actions():  # Fill the tree with actions and their events
		if action in ignore_actions:
			continue
		if ignore_ui_actions and action.begins_with("ui_"):
			continue

		var display_name := ""
		var group_name := ""
		if action in actions:
			var input_action: InputAction = actions[action]
			display_name = input_action.display_name
			group_name = input_action.group

		if display_name.empty():
			display_name = _humanize_snake_case(action)

		var tree_item: TreeItem
		if group_name and group_name in groups:
			var input_group: InputGroup = groups[group_name]
			var group_root: TreeItem = input_group.tree_item
			tree_item = tree.create_item(group_root)

		else:
			tree_item = tree.create_item(tree_root)

		tree_item.set_text(0, display_name)
		tree_item.set_metadata(0, action)
		tree_item.set_icon(0, shortcut_tex)
		for event in InputMap.get_action_list(action):
			_add_event_tree_item(event, tree_item)

		tree_item.add_button(0, add_tex, 0, false, "Add")
		tree_item.add_button(0, delete_tex, 1, false, "Delete")
		tree_item.collapsed = true


func _input(event: InputEvent) -> void:
	if listening_for_input == KEYBOARD and not event is InputEventKey:
		return
	if event.pressed:
		listened_input = event
		key_shortcut_label.text = OS.get_scancode_string(event.get_scancode_with_modifiers())


func _fill_selector_options() -> void:
	var mouse_option_button: OptionButton = mouse_shortcut_selector.find_node("OptionButton")
	for option in MOUSE_BUTTON_NAMES:
		mouse_option_button.add_item(option)

	var joy_key_option_button: OptionButton = joy_key_shortcut_selector.find_node("OptionButton")
	for i in JOY_BUTTON_MAX:
		var text: String = "Button %s" % i
		if i < JOY_BUTTON_NAMES.size():
			text += " (%s)" % JOY_BUTTON_NAMES[i]
		joy_key_option_button.add_item(text)

	var joy_axis_option_button: OptionButton = joy_axis_shortcut_selector.find_node("OptionButton")
	var i := 0.0
	for option in JOY_AXIS_NAMES:
		var sign_symbol = "+" if floor(i) != i else "-"
		var text: String = "Axis %s %s%s" % [floor(i), sign_symbol, option]
		joy_axis_option_button.add_item(text)
		i += 0.5


func _create_group_tree_item(group: InputGroup, group_name: String) -> void:
	if group.tree_item:
		return

	var group_root: TreeItem
	if group.parent_group:
		var parent_group: InputGroup = groups[group.parent_group]
		_create_group_tree_item(parent_group, group.parent_group)
		group_root = tree.create_item(parent_group.tree_item)
	else:
		group_root = tree.create_item(tree.get_root())
	group_root.set_text(0, group_name)
	group_root.set_icon(0, folder_tex)
	group.tree_item = group_root


func _humanize_snake_case(text: String) -> String:
	text = text.replace("_", " ")
	var first_letter := text.left(1)
	first_letter = first_letter.capitalize()
	text.erase(0, 1)
	text = text.insert(0, first_letter)
	return text


func _add_event_tree_item(event: InputEvent, action_tree_item: TreeItem) -> void:
	var event_tree_item: TreeItem = tree.create_item(action_tree_item)
	event_tree_item.set_text(0, _event_to_str(event))
	event_tree_item.set_metadata(0, event)
	match event.get_class():
		"InputEventJoypadMotion":
			event_tree_item.set_icon(0, joy_axis_tex)
		"InputEventJoypadButton":
			event_tree_item.set_icon(0, joy_button_tex)
		"InputEventKey":
			var scancode: int = event.get_scancode_with_modifiers()
			if scancode > 0:
				event_tree_item.set_icon(0, key_tex)
			else:
				event_tree_item.set_icon(0, key_phys_tex)
		"InputEventMouseButton":
			event_tree_item.set_icon(0, mouse_tex)
	event_tree_item.add_button(0, edit_tex, 0, false, "Edit")
	event_tree_item.add_button(0, delete_tex, 1, false, "Delete")


func _event_to_str(event: InputEvent) -> String:
	var output := ""
	if event is InputEventKey:
		var scancode: int = event.get_scancode_with_modifiers()
		var physical_str := ""
		if scancode == 0:
			scancode = event.get_physical_scancode_with_modifiers()
			physical_str = " " + tr("(Physical)")
		output = OS.get_scancode_string(scancode) + physical_str

	elif event is InputEventMouseButton:
		output = MOUSE_BUTTON_NAMES[event.button_index - 1]

	elif event is InputEventJoypadButton:
		var button_index: int = event.button_index
		if button_index >= JOY_BUTTON_NAMES.size():
			output = "Button %s" % button_index
		else:
			output = "Button %s (%s)" % [button_index, JOY_BUTTON_NAMES[button_index]]

	elif event is InputEventJoypadMotion:
		var positive_axis: bool = event.axis_value > 0
		var axis_value: int = event.axis * 2 + int(positive_axis)
		var sign_symbol = "+" if positive_axis else "-"
		output = "Axis %s %s%s" % [event.axis, sign_symbol, JOY_AXIS_NAMES[axis_value]]
	return output


func _on_ShortcutTree_button_pressed(item: TreeItem, _column: int, id: int) -> void:
	var action = item.get_metadata(0)
	currently_editing_tree_item = item
	if action is String:
		if id == 0:  # Add
			var rect: Rect2 = tree.get_item_area_rect(item, 0)
			rect.position.x = rect.end.x
			rect.position.y += 42 - tree.get_scroll().y
			rect.size = Vector2(110, 23 * shortcut_type_menu.get_item_count())
			shortcut_type_menu.popup(rect)
		elif id == 1:  # Delete
			for event in InputMap.get_action_list(action):
				InputMap.action_erase_event(action, event)
			var child := item.get_children()
			while child != null:
				child.free()
				child = item.get_children()

	elif action is InputEvent:
		var parent_action = item.get_parent().get_metadata(0)
		if id == 0:  # Edit
			if action is InputEventKey:
				keyboard_shortcut_selector.popup_centered()
			elif action is InputEventMouseButton:
				mouse_shortcut_selector.popup_centered()
			elif action is InputEventJoypadButton:
				joy_key_shortcut_selector.popup_centered()
			elif action is InputEventJoypadMotion:
				joy_axis_shortcut_selector.popup_centered()
		elif id == 1:  # Delete
			if not parent_action is String:
				return
			InputMap.action_erase_event(parent_action, action)
			item.free()


func _on_ShortcutTree_item_activated() -> void:
	_on_ShortcutTree_button_pressed(tree.get_selected(), 0, 0)


func _on_ShortcutTypeMenu_id_pressed(id: int) -> void:
	if id == KEYBOARD:
		keyboard_shortcut_selector.popup_centered()
	elif id == MOUSE:
		mouse_shortcut_selector.popup_centered()
	elif id == JOY_BUTTON:
		joy_key_shortcut_selector.popup_centered()
	elif id == JOY_AXIS:
		joy_axis_shortcut_selector.popup_centered()


func _apply_shortcut_change(input_type: int, value: int) -> void:
	var new_input: InputEvent
	if input_type == MOUSE:
		new_input = InputEventMouseButton.new()
		new_input.button_index = value + 1
	elif input_type == JOY_BUTTON:
		new_input = InputEventJoypadButton.new()
		new_input.button_index = value
	elif input_type == JOY_AXIS:
		new_input = InputEventJoypadMotion.new()
		new_input.axis = value / 2
		new_input.axis_value = -1.0 if value % 2 == 0 else 1.0

	var metadata = currently_editing_tree_item.get_metadata(0)
	# If metadata is InputEvent, we are editing an input event.
	# If it's a string, we are adding a new input event to an action.
	if metadata is InputEvent:
		var parent_metadata = currently_editing_tree_item.get_parent().get_metadata(0)
		var changed := _set_shortcut(parent_metadata, metadata, new_input)
		if !changed:
			return
		currently_editing_tree_item.set_metadata(0, new_input)
		currently_editing_tree_item.set_text(0, _event_to_str(new_input))
	elif metadata is String:
		var changed := _set_shortcut(metadata, null, new_input)
		if !changed:
			return
		_add_event_tree_item(new_input, currently_editing_tree_item)


func _set_shortcut(action: String, old_event: InputEvent, new_event: InputEvent) -> bool:
	if InputMap.action_has_event(action, new_event):
		return false
	if old_event:
		InputMap.action_erase_event(action, old_event)
	InputMap.action_add_event(action, new_event)
	return true


func _on_KeyboardShortcutSelector_about_to_show() -> void:
	listening_for_input = KEYBOARD
	listened_input = null
	key_shortcut_label.text = ""
	set_process_input(true)


func _on_KeyboardShortcutSelector_popup_hide() -> void:
	set_process_input(false)


func _on_KeyboardShortcutSelector_confirmed() -> void:
	if listened_input == null:
		return
	var metadata = currently_editing_tree_item.get_metadata(0)
	if metadata is InputEvent:  # Editing an input event
		var parent_metadata = currently_editing_tree_item.get_parent().get_metadata(0)
		var changed := _set_shortcut(parent_metadata, metadata, listened_input)
		if !changed:
			return
		currently_editing_tree_item.set_metadata(0, listened_input)
		currently_editing_tree_item.set_text(0, _event_to_str(listened_input))
	elif metadata is String:  # Adding a new input event to an action
		var changed := _set_shortcut(metadata, null, listened_input)
		if !changed:
			return
		_add_event_tree_item(listened_input, currently_editing_tree_item)


func _on_MouseShortcutSelector_confirmed() -> void:
	_apply_shortcut_change(MOUSE, mouse_shortcut_selector.find_node("OptionButton").selected)


func _on_JoyKeyShortcutSelector_confirmed() -> void:
	_apply_shortcut_change(JOY_BUTTON, joy_key_shortcut_selector.find_node("OptionButton").selected)


func _on_JoyAxisShortcutSelector_confirmed() -> void:
	_apply_shortcut_change(JOY_AXIS, joy_axis_shortcut_selector.find_node("OptionButton").selected)
