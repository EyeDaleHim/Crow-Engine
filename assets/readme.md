# Asset Tree
Assets in Gear Engine have the following directory structure:

assets
 ├── atlases: `.json` files that contain information to stitch image files together into a runtime atlas to incur batching in the rendering.
 ├── contexts: `.json` files containing information about what assets to load or unload during parts of the game.
 ├── characters: `.json` files containing information for how the game displays characters.
 ├── data: A subdirectory that contains the game's data.
 ├──    ├── levels: `.json` files containing level data. In other engines, this can be referred as songs. Subdirectory for organizing is optional.
 ├──    ├── playlist: `.json` files containing level playlist data. In other engines, this can be referred as story mode or weeks. (example: `week1.json`)
 ├──    ├── scripts: `.hx` files containing game scripts.
 ├── fonts: A subdirectory of font files that can display text on screen.
 ├──    ├── bitmap: `.png` and `.fnt` files. Typically made with BMFont.
 ├──    ├── vector: `.ttf` and `.otf` files.
 ├── sounds: `.ogg` files that provide audio such as music or sound effects for the game. Subdirectory for organizing is optional.
 ├── stages: `.json` files containing information for how stages are rendered in the game.
 ├── textures: `.png` and `.xml` files that are used for rendering images and animations. Subdirectory for organizing is optional. For atlases, contexts are recommended to load them together.