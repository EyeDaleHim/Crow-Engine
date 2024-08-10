package objects.notes;

class NoteSprite extends FlxSprite
{
	public var noteData(default, set):Note;
	public var sustain:SustainNote;

	override public function new(noteData:Note)
	{
		super();

		frames = Assets.frames("game/ui/NOTE_assets");

		animation.addByPrefix("noteLEFT", "purple0", 24);
		animation.addByPrefix("noteDOWN", "blue0", 24);
		animation.addByPrefix("noteUP", "green0", 24);
		animation.addByPrefix("noteRIGHT", "red0", 24);

        this.noteData = noteData;

        scale.set(0.7, 0.7);
		updateHitbox();
	}

	override function set_x(value:Float):Float
	{
		this.x = value;

		if (sustain != null)
			sustain.centerOverlay(this, X);

		return value;
	}

	override function set_y(value:Float):Float
	{
		this.y = value;

		if (sustain != null)
			sustain.y = this.getMidpoint().y;

		return value;
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

			noteData.parent = this;
		}

		return (this.noteData = noteData);
	}
}
