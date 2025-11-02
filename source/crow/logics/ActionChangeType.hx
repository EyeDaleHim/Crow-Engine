package crow.logics;

enum abstract ActionChangeType(String) from String to String
{
	var SET = "SET";
	var INCREMENT = "INCREMENT";
	var DECREMENT = "DECREMENT";
	var TOGGLE = "TOGGLE";
	var ADD = "ADD";
	var SUBTRACT = "SUBTRACT";
	var MULTIPLY = "MULTIPLY";
	var DIVIDE = "DIVIDE";
}