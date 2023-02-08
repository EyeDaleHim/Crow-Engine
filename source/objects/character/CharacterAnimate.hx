package objects.character;

import flxanimate.FlxAnimate;

class CharacterAnimate extends FlxAnimate
{
	public var name:String = 'bf';

	public function new(x:Float = 0, y:Float = 0, character:String = 'bf', path:String = 'characters/bf')
	{
		name = character;
		super(x, y, Paths.imagePath('${path}/${character}').replace('.png', ''));
	}

	public function addAnim(name:String, symbol:String, fps:Int = 24, looped:Bool = false, ?indices:Array<Int> = null, ?x:Float = 0, ?y:Float = 0)
	{
		if (indices != null && indices.length > 0)
			anim.addBySymbolIndices(name, symbol, indices, fps, looped, x, y);
		else
			anim.addBySymbol(name, symbol, fps, looped, x, y);
	}

	public function playAnim(?Name:String = "", ?Force:Bool = false, ?Reverse:Bool = false, ?Frame:Int = 0)
	{
		anim.play(Name, Force, Reverse, Frame);
	}
}
