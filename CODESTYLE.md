# Crow Engine - Code Style Guidelines

When submitting a Pull Request for the Crow Engine project, please ensure that your code adheres to the following guidelines:

## File Formatting
All .hx files should be properly formatted before submission (Right Click -> Format Document).

## Variable Naming

Variable names should be formatted as follows:

* **SNAKE_CASED** (`e.g. var MIN_TIME:Float = .5;`) should be used for important variables, typically after static variables.
* **pascalCased** (`e.g. var defaultZoom:Float = .9;`) may be used in certain cases as deemed necessary.
It is important to ensure that variable names accurately reflect their purpose or function.

## Long Functions / Important Variables
If a function is particularly long or if a variable is of particular importance, please include a comment explaining why (e.g. // a cool comment).

## Optimization
Please ensure that your Pull Request has been thoroughly tested and is functioning optimally before submission.