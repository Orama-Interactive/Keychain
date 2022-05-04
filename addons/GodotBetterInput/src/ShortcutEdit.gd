extends Tree

var groups := {}

# Textures taken from Godot https://github.com/godotengine/godot/tree/master/editor/icons
onready var edit_texture: Texture = preload("res://addons/GodotBetterInput/assets/edit.svg")
onready var delete_texture: Texture = preload("res://addons/GodotBetterInput/assets/close.svg")


func _ready() -> void:
	var tree_root: TreeItem = create_item()
	tree_root.set_text(0, "Project Name")
	for action in InputMap.get_actions():
		action = (action as String)
		var group_name := ""

		if "@" in action:
			var pos: int = action.rfind("@")
			group_name = action.right(pos + 1)
			action = action.left(pos)
			if not group_name in groups:
				var group_root: TreeItem = create_item(tree_root)
				group_root.set_text(0, group_name)
				groups[group_name] = group_root

		var tree_item: TreeItem
		if group_name:
			tree_item = create_item(groups[group_name])
		else:
			tree_item = create_item(tree_root)
		tree_item.set_text(0, action)
		tree_item.add_button(0, edit_texture, 0, false, "Edit")
		tree_item.add_button(0, delete_texture, 1, false, "Delete")


func _on_ShortcutEdit_button_pressed(item: TreeItem, _column: int, id: int) -> void:
	print(item, id)
