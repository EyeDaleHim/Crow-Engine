package states.options;

// 0x00, default options category
// 0x01m controls options category
// 0x02, notes options category
@:enum
abstract OptionsCategoryType(String)
{
	var GAMEPLAY = "gameplay&d";
	var GRAPHICS = "graphics&d";
	var CONTROLS = "controls&f";
	var NOTES = "controls&e";
}
