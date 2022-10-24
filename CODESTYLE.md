# Crow Engine - Code Style

When making a Pull Request for Crow Engine, please consider the following requirements:

---

## File Formatting

Please always format your haxe `.hx` files (Right Click -> Format Document)

## Variable Naming
Variable names should follow as is:

**SNAKE_CASED** `var MIN_TIME:Float = .5;` is made in a way to differentiate importance. Name variables this way for important variables, usually after static variables.
**pascalCased** `var defaultZoom:Float = .9;` is commonly used, you are free to use this in some cases you find necessary.

Please name a variable properly that defines their actual functionality or variable.

## Long Functions / Important Variables

If a function is extremely long or if a variable is important, leave a comment `// a cool comment` to why.

## Optimization

Please make sure your pull request is tested and running well before you submit your pull request in the first place.

