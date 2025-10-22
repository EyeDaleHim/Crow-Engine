package gear.predicates;

enum abstract PredicateOperatorCode(String) from String to String {
	var EQ = "EQ";
	var NEQ = "NEQ";
	var GT = "GT";
	var LT = "LT";
	var GTE = "GTE";
	var LTE = "LTE";
	var MODULO = "MODULO";
}