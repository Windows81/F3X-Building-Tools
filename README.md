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

A pre-built `rbxm` file [is provided](<./Build/Building Tools.rbxm>) for your convenience.

To generate your own builds, you'll need to have Rojo installed. Then you can execute:

```sh
rojo build --output "./Build/Building Tools.rbxm" .
```

---

Designed and built by [the F3X team](http://www.roblox.com/Groups/Group.aspx?gid=831895); patches added by [VisualPlugin](https://github.com/Windows81).
