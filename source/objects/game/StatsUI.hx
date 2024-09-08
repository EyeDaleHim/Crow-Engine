package objects.game;

class StatsUI extends FlxSpriteGroup
{
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var statText:FlxText;

	public var leftIcon:IconSprite;
	public var rightIcon:IconSprite;

	public var health(get, never):Float;

	function get_health():Float
	{
		if (getHealth == null)
			return 0;
		return getHealth();
	}

	public var getHealth:Void->Float = null;
	public var getMaxHealth(default, set):Void->Float = null;

	function set_getMaxHealth(func:Void->Float):Void->Float
	{
		if (func == null)
			return null;
		healthBar.setRange(0.0, func());

		return getMaxHealth = func;
	}

	public function new(?x:Float = 0.0, ?y:Float = 0.0)
	{
		super(x, y);

		healthBarBG = new FlxSprite(0, 0).loadGraphic(Assets.image("game/ui/healthBar"));
		healthBarBG.active = false;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, (healthBarBG.width - 8).floor(), (healthBarBG.height - 8).floor(), this,
			'health', 0, 1);
		healthBar.createFilledBar(FlxColor.RED, FlxColor.LIME);
		healthBar.numDivisions = 250;
		add(healthBar);

		leftIcon = new IconSprite();
		add(leftIcon);

		rightIcon = new IconSprite();
		rightIcon.flipX = true;
		add(rightIcon);

		statText = new FlxText();
		statText.setFormat(Assets.font("vcr").fontName, 18);
		statText.centerOverlay(healthBarBG, X);
		statText.y = healthBarBG.objBottom() + 10;
		add(statText);
	}

	override public function update(elapsed:Float)
	{
		var time:Float = elapsed * 0.9;

		leftIcon.scale.set(Math.max(1.0, leftIcon.scale.x - time), Math.max(1.0, leftIcon.scale.y - time));
		rightIcon.scale.set(Math.max(1.0, rightIcon.scale.x - time), Math.max(1.0, rightIcon.scale.y - time));

		leftIcon.updateHitbox();
		rightIcon.updateHitbox();

		leftIcon.setPosition(FlxMath.remapToRange(health, healthBar.max, 0, healthBar.x, healthBar.objRight()), healthBar.y - (leftIcon.frameHeight / 2));
		leftIcon.x -= leftIcon.width + 10;
		rightIcon.setPosition(FlxMath.remapToRange(health, healthBar.max, 0, healthBar.x, healthBar.objRight()), healthBar.y - (rightIcon.frameHeight / 2));
		rightIcon.x += 10;

		super.update(elapsed);
	}

	public function beatHit(beat:Int):Void
	{
		if (active && beat % 2 == 0)
		{
			leftIcon.scale.set(1.2, 1.2);
			rightIcon.scale.set(1.2, 1.2);

			leftIcon.updateHitbox();
			rightIcon.updateHitbox();

			leftIcon.setPosition(FlxMath.remapToRange(health, healthBar.max, 0, healthBar.x, healthBar.objRight()), healthBar.y - (leftIcon.frameHeight / 2));
			leftIcon.x -= 10;
			rightIcon.setPosition(FlxMath.remapToRange(health, healthBar.max, 0, healthBar.x, healthBar.objRight()), healthBar.y
				- (rightIcon.frameHeight / 2));
			rightIcon.x += 10;
		}
	}

	public function updateStatsText(score:Int = 0, misses:Int = 0, accuracy:Float = 0.0):Void
	{
		var separator:String = "//";

		var scoreString:String = 'Score: $score';
		var missString:String = 'Misses: $misses';

		if (Math.isNaN(accuracy))
			accuracy = 0.0;

		var accuracyString:String = 'Accuracy: ${FlxMath.roundDecimal(accuracy * 100.0, 2)}%';

		statText.text = '$scoreString $separator $missString $separator $accuracyString';
		statText.centerOverlay(healthBarBG, X);
	}
}
