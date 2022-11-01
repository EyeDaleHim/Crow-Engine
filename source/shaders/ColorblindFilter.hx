package shaders;

import lime.math.ColorMatrix;
import flixel.FlxG;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;

class ColorblindFilter
{
	public static var deuteranopia:{filter:BitmapFilter, apply:Void->Void} = {
		filter: new ColorMatrixFilter([
			0.43, 0.72, -.15, 0, 0,
			0.34, 0.57, 0.09, 0, 0,
			-.02, 0.03,    1, 0, 0,
			   0,    0,    0, 1, 0
		]),
		apply: applyFilter.bind('deuteranopia')
	};

	public static var protanopia:{filter:BitmapFilter, apply:Void->Void} = {
		filter: new ColorMatrixFilter([
			0.20, 0.99, -.19, 0, 0,
			0.16, 0.79, 0.04, 0, 0,
			0.01, -.01,    1, 0, 0,
			   0,    0,    0, 1, 0,
		]),
		apply: applyFilter.bind('protanopia')
	};

	public static var tritanopia:{filter:BitmapFilter, apply:Void->Void} = {
		filter: new ColorMatrixFilter([
			0.97, 0.11, -.08, 0, 0,
			0.02, 0.82, 0.16, 0, 0,
			0.06, 0.88, 0.18, 0, 0,
			   0,    0,    0, 1, 0,
		]),
		apply: applyFilter.bind('tritanopia')
	}

	public static function applyFilter(filter:String)
	{
		var filterArray = [];
		FlxG.game.setFilters(filterArray);

		switch (filter)
		{
			case 'deuteranopia':
				{
					FlxG.game.setFilters([deuteranopia.filter]);
				}
			case 'protanopia':
				{
					FlxG.game.setFilters([protanopia.filter]);
				}
			case 'tritanopia':
				{
					FlxG.game.setFilters([tritanopia.filter]);
				}
		}
	}
}
