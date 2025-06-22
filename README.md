<<<<<<< HEAD
# Fork3X

An open-source, patched, and improved fork of the F3X building tools.

A plugin will also be released, but the tool is more often used, hence why I started by that.

# Note about the files in the fork:

I only started to use GitHub on the 22nd April 2025. I still didn't update the fork's file, and I'll only update them once I'll be done with the plugin. Sorry for the inconvenience!

# What does Fork3X include compared to F3X?

## For tools:

- Support for Particle Emitters (with NumberRanges and NumberSequences), highlights and selectionboxes as effects.
- A marketplace tool to find decals without proxy (if you have a proxy, you can add more things tho).
- A text tool to write text that gets filtered and with RichText support.
- A transformation tool to make unions.
- 3 more constraints: ropes, rods and hinges.
- Support for attachments.
- A scale mode for the resize tool to scale models without losing proportions.
- Fast mode for images incase F3X don't restore their servers.
- Color for decals.
- Reverting anchor will also revert CFrame.

I will likely expand this part a bit.

-----

## For utilities:

- A grouping and multiselecting button to let any users group, ungroup and multiselect.
- A save/load tool that allows you to save your builds via datastores.
- A hint system to know what you're pointing with your mouse next to it.
- Support for Deferred SignalBehavior and StreamingEnabled.
- Ability to change slightly what's display in Explorer (you can add for example who owns a part)

This probably has to be expanded.

----

## For security:

- A flexible options module that allows you to hide Explorer, disable Save/Load, remove creatable instance, kick/ban/warn people when they do "bad stuff", blacklist malicious images (c00lkidd e. g.), etc...
- A webhook module by somebody I cannot find back sadly (if you're the creator of this module, please let me know) to send messages to your Discord. You put your webhook in a server script, so you should be safe from hackers!
- Support for anti-grief: two functions in the options module to configure for a fully functional anti-grief system.
- Cloning delay.

I will expand this part if there's anything more to add.

# Can I use raidRoleplay and Fork3X at the same time?

**You can, but you must be able to modify more or less unclean pieces of code in raidRoleplay** in order to make it support Fork3X. The problem is the log that can only log actions found in the original building tools. Every new tools won't return anything without raidRoleplay being modified.

# How do I get the Fork3X?

There's sadly no Fork3X free model due to Roblox's unacceptable model moderation. I almost got my account banned for a model that doesn't contain any require(), genfenv() (that are used in the building tools!) and etc...

Instead, my ways to distribute the Fork3X are:

- The GitHub you're consulting here.
- The uncopylocked place that can be found here: https://www.roblox.com/games/121011278181789/Fork3X-Demonstration-Place

If you want to use them in your game, I strongly advise you to have a look at the Options module, where stand every settings you need.

# FAQ

## Q: Is this project open-source?

A: Yes, it is. The building tools by F3X are free to use, meaning there's almost no reason in making this closed source.

## Q: People can lag bomb with particle emitters!

A: A security to this is integrated to the building tools.

## Q: How do I use NumberRanges and NumberSequences?

A: Simply by writing X,Y. X is the property at the start and Y at the end. For example, setting a particle emitter's Opacity to 0,1 will make the particles fade before they disappear.

## Q: Is the dropdown bug fixed?

A: Of course! It is completely functional in this version.

## Q: Why is the code a little bit janky?

A: Because I'm sadly not the creator of the original building tools. I mightn't understand some things very well, hence why I might use some strange manners. Sorry!

## Q: How can I support the project?

A: By using it! I make stuff on Roblox exclusively for fun. There isn't any financial goal behind my projects.

---------

Made with love by the F3X team, forked for you by Vikko151.
=======
# Building Tools by F3X

A set of powerful, easy building tools for Rōblox; **patched for [Rōblox Freedom Distribution](https://github.com/Windows81/Roblox-Freedom-Distribution) [2021E]**

## What's included?

BT includes the following tools:

- A **move** tool, which lets you move parts normally, each part relative to itself, or relative to the last part selected. You can also change the increment.
- A **resize** tool, which lets you resize parts in either a single direction, or in both directions. You can also change the size increment.
- A **rotate** tool, which lets you rotate parts around the center of the selection, each part around itself, or around the last part selected. You can also change the increment by which to rotate the part, and rotate around a part's edges.
- A **paint** tool, which lets you change the color of parts.
- A **surface** tool, which lets you change the surface types of parts.
- A **material** tool, which lets you change the transparency, reflectance, and material of parts.
- An **anchor** tool, which lets you make parts anchored (or not).
- A **collision** tool, which lets you enable (or disable) collision on parts.
- A **new part** tool, which lets you create new parts of different shapes and types.
- A **mesh** tool, which lets you add meshes to parts.
- A **texture** tool, which lets you add decals and textures to parts.
- A **weld** tool, which lets you create an artificial weld between parts.
- A **lighting** tool, which lets you add spotlights and point lights to parts.
- A **decorate** tool, which lets you add smoke, fire, and sparkles to parts.

You can also:

- Export your creations (Shift + P) to F3X's servers and import them into Rōblox Studio (using [this plugin](http://www.roblox.com/Import-from-Building-Tools-by-F3X-item?id=142485815))
- Select multiple parts in various convenient ways such as:
  - Adding parts to the selection individually (Shift + Click)
  - Selecting parts using a 2D rectangle (Shift + Click & Drag)
  - Selecting parts found within the parts in the current selection (Shift + K)
- Create named groups of parts to select simultaneously or ignore (Shift + G)
- Clone parts (Shift + C)
- Delete parts (Shift + X)
- Undo and redo any changes you make (Shift + Z, Shift + Y)
- Switch between tools using hotkeys

## How to generate the `rbxm`?

A pre-built `rbxm` file [is provided](<./Build/Building%20Tools%20(RFD).rbxm>) for your convenience.

To generate your own builds, you'll need to have Rojo installed. Then you can execute:

```sh
rojo build . --output "./Build/Building Tools.rbxm"
```

Because Rojo is optimised for modern versions of Rōblox, some aesthetic properties may not match with what you expect. Using the [Rōblox Freedom Distribution](https://github.com/Windows81/Roblox-Freedom-Distribution) executable, run the following:

```sh
RFD serialise --method rbxl --load "./Build/Building Tools.rbxm" --save "./Build/Building Tools (RFD).rbxm"
```

---

Designed and built by [the F3X team](http://www.roblox.com/Groups/Group.aspx?gid=831895); patches added by [VisualPlugin](https://github.com/Windows81) et al.
```
>>>>>>> 7f554bf23fbe876f7bd3b803d56b443f3debac10
