package objects.stageParts;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import objects.Stage.BGSprite;
import states.PlayState;

class TankmenUnit extends FlxTypedGroup<TankmenSoldier>
{
	public override function new()
	{
		super();

		var tempTankman:TankmenSoldier = new TankmenSoldier(20, 500, true);
		tempTankman.strumTime = 10;
		add(tempTankman);

		var id:Int = 0;

		for (shoot in PlayState.current.spectator.singSchedules)
		{
			if (FlxG.random.bool(16) && shoot.time > 4000)
			{
				var soldier:TankmenSoldier = recycle(TankmenSoldier);
				soldier.ID = id;
				soldier.resetAsRecycled(shoot.time, 200 + FlxG.random.int(50, 100), shoot.direction < 2);
				add(soldier);

				id++;
			}
		}

		remove(tempTankman, true);
		tempTankman.destroy();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (members.length > 0)
		{
			for (soldier in members)
			{
				if (soldier != null)
				{
					if (soldier.animation.curAnim.name == "run")
					{
						var speed:Float = (Conductor.songPosition - soldier.strumTime) * soldier.tankSpeed;
						if (soldier.attributes['fromRight'])
							soldier.x = (0.02 * FlxG.width - soldier.attributes['endOffset']) + speed;
						else
							soldier.x = (0.74 * FlxG.width + soldier.attributes['endOffset']) - speed;

						soldier.x -= 200;

						if (Conductor.songPosition > soldier.strumTime)
						{
							soldier.active = true;

							soldier.animation.play('shot', true);
							if (soldier.attributes['fromRight'])
							{
								soldier.offset.set(300, 200);
							}
						}
					}
					else if (soldier.animation.curAnim.finished)
					{
						remove(soldier, true);
						soldier.destroy();
					}

					soldier.visible = (soldier.x > (-0.7 * FlxG.width) && soldier.x < (1.4 * FlxG.width));
				}
			}
		}
	}
}

class TankmenSoldier extends BGSprite
{
	public var strumTime:Float = 0;
	public var tankSpeed:Float = 0.7;

	override public function new(strumTime:Float, y:Float, onRight:Bool = false)
	{
		super(null);

		setPosition(0, y);

		this.strumTime = strumTime;
		tankSpeed = FlxG.random.float(0.6, 1.1);
		attributes.set('endOffset', FlxG.random.float(50, 200));
		attributes.set('fromRight', onRight);

		frames = Paths.getSparrowAtlas('warzone/tankmanKill');

		animation.addByPrefix('run', 'tankman running', 24, true);
		animation.addByPrefix('shot', 'John Shot ' + FlxG.random.int(1, 2), 24, false);

		animation.play('run');
		animation.curAnim.curFrame = FlxG.random.int(0, animation.curAnim.numFrames - 1);

		flipX = onRight;
		active = true;

		updateHitbox();
	}

	public function resetAsRecycled(strumTime:Float, y:Float, onRight:Bool = false)
	{
		this.strumTime = strumTime;
		this.y = y;
		tankSpeed = FlxG.random.float(0.6, 1.1);

		attributes.set('endOffset', FlxG.random.float(50, 200));
		attributes.set('fromRight', onRight);

		flipX = onRight;
	}
}
