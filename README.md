# Godot Better Input
A plugin for the [Godot Engine](https://godotengine.org/) that aims to give the player full control over the input actions of the game. Created by [Orama Interactive](https://oramainteractive.com).

[![Join our Discord server](https://discord.com/api/guilds/645793202393186339/embed.png)](https://discord.gg/GTMtr8s)

## Features
- Easy to use shortcut re-mapping system, for all input types, keyboard, mouse, gamepad buttons and gamepad axes. Great for accessibility purposes.
- Add multiple input events (shortcuts) to each action, of multiple input types.
- Group your inputs together, and choose whether certain input actions are global or local. Global events cannot be re-assigned anywhere else, local events can, but not to other events in the same group.
- Choose between different input presets.

## Support
If you wish to support the development of this plugin, consider [supporting us on Patreon](https://patreon.com/OramaInteractive).

## Installation
Copy the `addons/godot_better_input` directory into your Godot project files, and then enable `Godot Better Input` in Project Settings > Plugins.

## How to use
Find the ShortcutEdit scene in `res://addons/godot_better_input/ShortcutEdit.tscn` and drag and drop it in the settings scene of your project. To put your input actions into groups, you can edit the `actions` and `groups` dictionaries found in the `BetterInput.gd` autoload script. Note that you cannot create new input actions this way, they must already exist in the Project Settings' Input Map.

You can also create your own presets by adding new instances of type `Preset` in the `presets` array.

In order to make certain actions not appear in the settings, you can add their names (as they're found in the Input Map) in the `ignore_actions` array.

## License
[MIT License](https://github.com/Orama-Interactive/GodotBetterInput/blob/main/LICENSE).
