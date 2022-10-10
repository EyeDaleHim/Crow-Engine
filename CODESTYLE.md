# Crow Engine - Code Style

When making a Pull Request for Crow Engine, please consider the following requirements:

---

## File Formatting

Please always format your haxe `.hx` files (Right Click -> Format Document)

## Variable Naming
Variable names should follow as is:

All non-class variables must be **pascalCased** `var myCoolVar:Bool;`, any static variables should be upper **SNAKE_CASED** `static var AWESOME_HOLDER:Dynamic;` and class variables must be **CamelCased** `public var SomeThing:Sprite;`

Please ensure your variable names are not something like `var shitThing:Int;` or `var myCoolPepsi:Bool;`

## Long Functions / Important Variables

If a function is extremely long or if a variable is important, leave a comment `// a cool comment` to why.

## Optimization

Please make sure your pull request is tested and running well before you submit your pull request in the first place.

