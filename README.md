# Keychain
**Keychain** is a plugin for the [Godot Engine](https://godotengine.org/) that aims to give the player full control over the input actions of the game. Created by [Orama Interactive](https://oramainteractive.com).

[![Join our Discord server](https://discord.com/api/guilds/645793202393186339/embed.png)](https://discord.gg/GTMtr8s)

![Screenshot from Pixelorama](https://user-images.githubusercontent.com/35376950/168581977-62a5c64d-0b64-428c-a738-528611c88898.png)
Screenshot from [Pixelorama](https://github.com/Orama-Interactive/Pixelorama).

## Features
- Easy to use shortcut re-mapping system, for all input types, keyboard, mouse, gamepad buttons and gamepad axes. Great for accessibility purposes.
- Add multiple input events (shortcuts) to each action, of multiple input types.
- Group your inputs together, and choose whether certain input actions are global or local. Global events cannot be re-assigned anywhere else, local events can, but not to other events in the same group.
- Choose between different shortcut profiles and create custom ones.
- Save shortcut modifications.
- Support for localization.
- Automatically deletes old input actions that have been deprecated during development of your project, so there is no need to worry over this.

## Support
If you wish to support the development of this plugin, consider [supporting us on Patreon](https://patreon.com/OramaInteractive).

## Installation
Copy the `addons/keychain` directory into your Godot project files, and then enable `Keychain` in Project Settings > Plugins.

## How to use
Find the ShortcutEdit scene in `res://addons/keychain/ShortcutEdit.tscn` and drag and drop it in the settings scene of your project. To put your input actions into groups, you can edit the `actions` and `groups` dictionaries found in the `Keychain.gd` autoload script. Note that you cannot create new input actions this way, they must already exist in the Project Settings' Input Map.

You can also create your own shortcut profile by creating new `ShortcutProfile` resources and preloading them in the `profiles` array. Or you can create shortcut profiles using the addon itself while your project is running, and they will get saved as `.tres` Godot resource files inside `user://shortcut_profiles`.

In order to make certain actions not appear in the settings, you can add their names (as they're found in the Input Map) in the `ignore_actions` array.

If you'd like to avoid editing the addon files themselves to ensure easy updating, you can access the `Keychain` autoload and edit the variables from somewhere else in your project.

## License
[MIT License](https://github.com/Orama-Interactive/GodotBetterInput/blob/main/LICENSE).
