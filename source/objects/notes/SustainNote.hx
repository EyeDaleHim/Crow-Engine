package objects.notes;

class SustainNote extends FlxSprite
{
	public var noteData(default, set):Note;
	public var wrap(default, set):WrapMode = STRETCH;
	public var length(default, set):Float = 0.0;

	override public function new(noteData:Note, wrap:WrapMode = STRETCH, length:Float = 0.0)
	{
		super();

		frames = Assets.frames("game/ui/NOTE_assets");

		animation.addByPrefix("noteLEFT", "purple hold piece", 24);
		animation.addByPrefix("noteDOWN", "blue hold piece", 24);
		animation.addByPrefix("noteUP", "green hold piece", 24);
		animation.addByPrefix("noteRIGHT", "red hold piece", 24);

		this.noteData = noteData;
		this.length = length;
		this.wrap = wrap;
	}

	function set_length(value:Float)
	{
		scale.set(0.7, (1.0 + value) * 0.7);
		updateHitbox();

		return (this.length = value);
	}

	function set_noteData(noteData:Note)
	{
		if (noteData != null)
		{
			switch (noteData.direction)
			{
				case 0:
					animation.play("noteLEFT");
				case 1:
					animation.play("noteDOWN");
				case 2:
					animation.play("noteUP");
				case 3:
					animation.play("noteRIGHT");
			}

			noteData.sustainParent = this;
		}

		return (this.noteData = noteData);
	}

	function set_wrap(wrap:WrapMode):WrapMode
	{
		final shader = this.shader != null ? this.shader : graphic.shader;
		shader.bitmap.wrap = wrap == STRETCH ? CLAMP : REPEAT;

		return this.wrap = wrap;
	}
}

enum WrapMode
{
	STRETCH;
	TILE;
}
