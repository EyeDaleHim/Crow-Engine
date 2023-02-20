package backend.libraries;

import lime.system.System;
import openfl.Lib;

class FlxRes
{
	/**
	 * Returns the other dimension than the one you provide of the design resolution.
	 * 
	 * @param designValue The design, the ideal width or height. The assumption of design value as width or height is based on [returnWidth]
	 * @param returnWidth If true, will return the other dimension as width and will assume the [designValue] as height. 
	 * 					  If false will return the other dimension as height and will assume the [designValue] as width 
	 * @return Int Returns the other dimension based on [designValue] and [returnWidth].
	 */
	static public function getOtherDimension(designValue:Int, ?returnWidth:Bool = false):Int
	{
		// the returning value
		var otherDimension:Float;

		// is the orientation is landscape
		if (isLandscape())
		{
			// if the returning dimension is the width
			if (returnWidth)
				otherDimension = designValue * getRatio();
			// if the returning dimension is the height
			else
				otherDimension = designValue / getRatio();
		}
		// is the orientation is landscape
		else if (isPortait())
		{
			// if the returning dimension is the width
			if (returnWidth)
				otherDimension = designValue / getRatio();
			// if the returning dimension is the height
			else
				otherDimension = designValue * getRatio();
		}
		// if the ratio is 1:1
		else
		{
			otherDimension = designValue;
		}

		// make sure that the other dimension is an even number
		if (Math.floor(otherDimension) % 2 != 0 && otherDimension != designValue)
			otherDimension++;

		// return the other dimension as integer
		return Math.floor(otherDimension);
	}

	/**
	 * Returns the aspect ratio of screen if full screen or the game window if windowed
	 * @return Float
	 */
	static public function getRatio():Float
	{
		return
			Lib.current.stage.stageWidth > Lib.current.stage.stageHeight ? Lib.current.stage.stageWidth / Lib.current.stage.stageHeight : Lib.current.stage.stageHeight / Lib.current.stage.stageWidth;
	}

	/**
	 * Returns true is the orientation is landscape
	 * @return Bool
	 */
	static public function isLandscape():Bool
	{
		return Lib.current.stage.stageWidth > Lib.current.stage.stageHeight;
	}

	/**
	 * Returns true is the orientation is portrait
	 * @return Bool
	 */
	static public function isPortait():Bool
	{
		return Lib.current.stage.stageWidth < Lib.current.stage.stageHeight;
	}

	/**
	 * Returns the diagonal of screen (if full screen) or the game window (if wimdowed) in inches
	 */
	static public function getDiagonal():Float
	{
		return Math.sqrt(Math.pow(Lib.current.stage.stageWidth, 2) + Math.pow(Lib.current.stage.stageHeight, 2)) / System.getDisplay(0).dpi;
	}
}