# GodotBetterInput
A plugin for the [Godot Engine](https://godotengine.org/) that aims to give the player full control over the input actions of the game.

[![Join our Discord server](https://discord.com/api/guilds/645793202393186339/embed.png)](https://discord.gg/GTMtr8s)

## Installation
Copy the `addons/godot_better_input` directory into your Godot project files, and then enable `Godot Better Input` in Project Settings > Plugins.

## How to use
Find the ShortcutEdit scene in `res://addons/godot_better_input/ShortcutEdit.tscn` and drag and drop it in the settings scene of your project. To put your input actions into groups, you can edit the `actions` and `groups` dictionaries found in the `BetterInput.gd` autoload script. Note that you cannot create new input actions this way, they must already exist in the Project Settings' Input Map.

You can also create your own presets by adding new instances of type `Preset` in the `presets` array.

In order to make certain actions not appear in the settings, you can add their names (as they're found in the Input Map) in the `ignore_actions` array.
