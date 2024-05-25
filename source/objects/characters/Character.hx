package objects.characters;

class Character extends Bopper
{
	public var singTimer:Float = 0.0;

	public var missList:Array<String> = [];
	public var singList:Array<String> = [];

    public var data:CharacterData;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, name:String)
	{
		super(x, y);
	}
}
