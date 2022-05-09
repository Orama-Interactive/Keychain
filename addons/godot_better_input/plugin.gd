tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("ShortcutEdit", "Control", preload("src/ShortcutEdit.gd"), null)


func _exit_tree() -> void:
	remove_custom_type("ShortcutEdit")
