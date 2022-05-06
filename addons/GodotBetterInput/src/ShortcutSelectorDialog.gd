extends ConfirmationDialog

enum InputTypes { KEYBOARD, MOUSE, JOY_BUTTON, JOY_AXIS }

export(InputTypes) var input_type: int = InputTypes.KEYBOARD
var listened_input: InputEvent

onready var root: Node = get_tree().current_scene
onready var input_type_l: Label = $VBoxContainer/InputTypeLabel
onready var entered_shortcut: Label = $VBoxContainer/EnteredShortcutLabel
onready var option_button: OptionButton = $VBoxContainer/OptionButton
onready var already_exists: Label = $VBoxContainer/AlreadyExistsLabel


func _ready() -> void:
	set_process_input(false)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if event.pressed:
		listened_input = event
		entered_shortcut.text = OS.get_scancode_string(event.get_scancode_with_modifiers())
		_show_if_assigned(event)


func _show_if_assigned(event: InputEvent) -> void:
	var matching_pair: Array = _find_matching_event_in_map(event)
	if matching_pair:
		already_exists.text = (
			"Already assigned to: %s"
			% root.get_action_name(matching_pair[0])
		)
	else:
		already_exists.text = ""


func _on_ShortcutSelectorDialog_confirmed() -> void:
	if listened_input == null:
		return
	_apply_shortcut_change(listened_input)


func _apply_shortcut_change(input_event: InputEvent) -> void:
	var metadata = root.currently_editing_tree_item.get_metadata(0)
	if metadata is InputEvent:  # Editing an input event
		var parent_metadata = root.currently_editing_tree_item.get_parent().get_metadata(0)
		var changed: bool = _set_shortcut(parent_metadata, metadata, input_event)
		if !changed:
			return
		root.currently_editing_tree_item.set_metadata(0, input_event)
		root.currently_editing_tree_item.set_text(0, root.event_to_str(input_event))
	elif metadata is String:  # Adding a new input event to an action
		var changed: bool = _set_shortcut(metadata, null, input_event)
		if !changed:
			return
		root.add_event_tree_item(input_event, root.currently_editing_tree_item)


func _set_shortcut(action: String, old_event: InputEvent, new_event: InputEvent) -> bool:
	if InputMap.action_has_event(action, new_event):  # If the current action already has that event
		return false
	if old_event:
		InputMap.action_erase_event(action, old_event)

	# Loop through other actions to see if the event exists there, to re-assign it
	var matching_pair := _find_matching_event_in_map(new_event)

	if matching_pair:
		var action_to_replace: String = matching_pair[0]
		var input_to_replace: InputEvent = matching_pair[1]
		InputMap.action_erase_event(action_to_replace, input_to_replace)
		var tree_item: TreeItem = root.tree.get_root()
		var prev_tree_item: TreeItem
		while tree_item != null:  # Loop through Tree's TreeItems...
			var metadata = tree_item.get_metadata(0)
			if metadata is InputEvent:
				if input_to_replace.shortcut_match(metadata):
					tree_item.free()
					break

			tree_item = _get_next_tree_item(tree_item)

	InputMap.action_add_event(action, new_event)
	return true


# Algorithm based on https://github.com/godotengine/godot/blob/master/scene/gui/tree.cpp#L685
func _get_next_tree_item(current: TreeItem) -> TreeItem:
	if current.get_children():
		current = current.get_children()
	elif current.get_next():
		current = current.get_next()
	else:
		while current and !current.get_next():
			current = current.get_parent()
		if current:
			current = current.get_next()
	return current


func _find_matching_event_in_map(event: InputEvent) -> Array:
	for action in InputMap.get_actions():
		if action in root.ignore_actions:
			continue
		if root.ignore_ui_actions and action.begins_with("ui_"):
			continue
		for input_event in InputMap.get_action_list(action):
			if event.shortcut_match(input_event):
				return [action, input_event]

	return []


func _on_ShortcutSelectorDialog_about_to_show() -> void:
	if input_type == InputTypes.KEYBOARD:
		listened_input = null
		already_exists.text = ""
		entered_shortcut.text = ""
	else:
		if !listened_input:
			_on_OptionButton_item_selected(0)
	set_process_input(true)


func _on_ShortcutSelectorDialog_popup_hide() -> void:
	set_process_input(false)


func _on_OptionButton_item_selected(index: int) -> void:
	if input_type == InputTypes.MOUSE:
		listened_input = InputEventMouseButton.new()
		listened_input.button_index = index + 1
	elif input_type == InputTypes.JOY_BUTTON:
		listened_input = InputEventJoypadButton.new()
		listened_input.button_index = index
	elif input_type == InputTypes.JOY_AXIS:
		listened_input = InputEventJoypadMotion.new()
		listened_input.axis = index / 2
		listened_input.axis_value = -1.0 if index % 2 == 0 else 1.0
	_show_if_assigned(listened_input)