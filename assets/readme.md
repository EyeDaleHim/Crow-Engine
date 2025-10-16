# Asset Tree
Assets in Gear Engine have the following directory structure:

assets
 ├── contexts: `.json` files containing information about what assets to load or unload during parts of the game.
 ├── data: A subdirectory that contains the game's data.
 ├──    ├── levels: `.json` files containing level data. Subdirectory for organizing is optional. (example: `bopeebo-hard.json`)
 ├──    ├── playlist: `.json` files containing level playlist data. In other engines, this can be referred to as story mode. (example: `week1.json`)
 ├──    ├── scripts: `.hx` files containing game scripts.
 ├── fonts: A subdirectory of font files that can display text on screen.
 ├──    ├── bitmap: Bitmap fonts. Typically made with BMFont.
 ├──    ├── vector: `.ttf` and `.otf` fonts.
 ├── sounds: `.ogg` files that provide audio such as music or sound effects for the game. Subdirectory for organizing is optional.
 ├── textures: `.png` and `.xml` files that are used for rendering images and animations. Subdirectory for organizing is optional. For atlases, contexts are recommended to load them together.