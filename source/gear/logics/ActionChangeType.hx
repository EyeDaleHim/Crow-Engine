package gear.logics;

enum abstract ActionChangeType(String) from String to String
{
	var SET = "SET";
	var INCREMENT = "INCREMENT";
	var DECREMENT = "DECREMENT";
	var TOGGLE = "TOGGLE";
}