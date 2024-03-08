package objects.sprites;

enum Alignment
{
	LEFT;
	CENTERED;
	RIGHT;
}

class Alphabet extends FlxObject
{
	public var antialiasing:Bool = FlxSprite.defaultAntialiasing;

	public var alpha:Float = 1.0;

    public var bakedRotationAngle(default, null):Float = 0;

	public var blend:BlendMode;

	public var color:FlxColor = 0xFFFFFFFF;

	public var colorTransform:ColorTransform;

    public var scale:FlxPoint = FlxPoint.get(1.0, 1.0);

    public var frames:FlxFramesCollection;

	public var text:String = "";
	public var bold:Bool = false;
	public var alignment:Alignment = LEFT;

	public function new(x:Float, y:Float, text:String = "", bold:Bool = true, alignment:Alignment = LEFT)
	{
		super(x, y);

		this.text = text;
		this.bold = bold;
		this.alignment = alignment;

		Assets.image('alphabet');
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override public function draw()
	{
        if (alpha == 0 || text.length == 0)
            return;

        for (camera in cameras)
        {
            if (!camera.visible || !camera.exists || !isOnScreen(camera))
                continue;

            if (isSimpleRender())
                drawSimple();
            else
                drawComplex();
        }

        #if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

    function drawSimple():Void
    {
        for (i in 0...text.length)
        {

        }
    }

    function drawComplex():Void
    {
        for (i in 0...text.length)
        {

        }
    }

	public function isSimpleRender(?camera:FlxCamera):Bool
	{
		if (FlxG.renderTile)
			return false;

		return isSimpleRenderBlit(camera);
	}

	public function isSimpleRenderBlit(?camera:FlxCamera):Bool
	{
		var result:Bool = (angle == 0 || bakedRotationAngle > 0) && scale.x == 1 && scale.y == 1 && blend == null;
		result = result && (camera != null ? isPixelPerfectRender(camera) : pixelPerfectRender);
		return result;
	}
}
