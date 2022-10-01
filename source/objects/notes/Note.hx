package objects;

import flixel.FlxG;
import flixel.FlxSprite;

class Note extends FlxSprite
{
	public static var earlyMult:Float = 0.5;

	public var direction:Int = 0;
	public var strumTime:Float = 0;
	public var ownerInfo:Owner = NONE;

	public var mustPress(get, null):Bool;
	public var canBeHit(get, null):Bool;
	public var tooLate(get, null):Bool;
	public var wasGoodHit(get, null):Bool;

	private function get_mustPress():Bool
	{
		return ownerInfo == PLAYER;
	}

	private function get_canBeHit():Bool
	{
		return (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
			&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyMult));
	}

	private function get_tooLate():Bool
	{
		return (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit);
	}

	private function get_wasGoodHit():Bool
	{
		return ((strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyMult))
			&& (/*(isSustainNote && prevNote.wasGoodHit) ||*/ strumTime <= Conductor.songPosition));
	}
}

enum abstract Owner(Int)
{
	var PLAYER = 0;
	var ENEMY = 1;
	var NONE = 2;
}
