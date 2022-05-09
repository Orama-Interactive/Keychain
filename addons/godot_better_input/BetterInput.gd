extends Node

# Change these settings
var presets := [Preset.new("Default", false), Preset.new("Custom")]
var selected_preset: Preset = presets[0]
var actions := {"pixelorama": MenuInputAction.new("", "", true, "nah", 0)}
var groups := {}
var config_path := "user://cache.ini"
var config_file: ConfigFile

class Preset:
	var name := ""
	var customizable := true
	var bindings := {}
	var config_section := ""

	func _init(_name := "", _customizable := true) -> void:
		name = _name
		customizable = _customizable
		config_section = "shortcuts-%s" % name

		for action in InputMap.get_actions():
			bindings[action] = InputMap.get_action_list(action)

	func load_from_file() -> void:
		if !BetterInput.config_file:
			return
		if !customizable:
			return
		for action in bindings:
			var action_list = BetterInput.config_file.get_value(config_section, action, [null])
			if action_list != [null]:
				bindings[action] = action_list

	func change_action(action: String) -> void:
		bindings[action] = InputMap.get_action_list(action)
		if BetterInput.config_file and customizable:
			BetterInput.config_file.set_value(config_section, action, bindings[action])
			BetterInput.config_file.save(BetterInput.config_path)


class InputAction:
	var display_name := ""
	var group := ""
	var global := true

	func _init(_display_name := "", _group := "", _global := true) -> void:
		display_name = _display_name
		group = _group
		global = _global


class MenuInputAction:
	extends InputAction
	var menu_node_path := ""
	var menu_node: PopupMenu
	var menu_item_id := 0
	var echo := false

	func _init(
		_display_name := "",
		_group := "",
		_global := true,
		_menu_node_path := "",
		_menu_item_id := 0,
		_echo := false
	) -> void:
		._init(_display_name, _group, _global)
		menu_node_path = _menu_node_path
		menu_item_id = _menu_item_id
		echo = _echo

	func get_menu_node(root: Node) -> void:
		var node = root.get_node(menu_node_path)
		if node is PopupMenu:
			menu_node = node
		elif node is MenuButton:
			menu_node = node.get_popup()


class InputGroup:
	var parent_group := ""
	var tree_item: TreeItem

	func _init(_parent_group := "") -> void:
		parent_group = _parent_group


func _init() -> void:
	if !config_file:
		config_file = ConfigFile.new()
		if !config_path.empty():
			config_file.load(config_path)


func _input(event: InputEvent) -> void:
	for action in actions:
		var input_action: InputAction = actions[action]
		if not input_action is MenuInputAction:
			continue

		if event.is_action_pressed(action):
			var menu: PopupMenu = input_action.menu_node
			if not menu:
				return
			if event is InputEventKey:
				var acc: int = menu.get_item_accelerator(input_action.menu_item_id)
				# If the event is the same as the menu item's accelerator, skip
				if acc == event.get_scancode_with_modifiers():
					return
			menu.emit_signal("id_pressed", input_action.menu_item_id)
			return
		if event.is_action(action) and input_action.echo:
			if event.is_echo():
				var menu: PopupMenu = input_action.menu_node
				menu.emit_signal("id_pressed", input_action.menu_item_id)
				return
