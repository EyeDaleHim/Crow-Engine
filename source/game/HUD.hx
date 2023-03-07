package game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import objects.notes.StrumNote;
import objects.notes.Note;
import objects.HealthIcon;
import states.PlayState;

class HUD extends FlxGroup
{
    public var healthBarBG:FlxSprite;
    public var healthBar:FlxSprite;

    public var iconP1:HealthIcon;
    public var iconP2:HealthIcon;

    public var scoreText:FlxText;
    public var engineText:FlxText;

    public override function new()
    {
        super();

        healthBarBG = new FlxSprite(0, FlxG.height * (Settings.getPref('downscroll', false) ? 0.1 : 0.9)).loadGraphic(Paths.image('game/ui/healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8),  PlayState.current.gameInfo,
			'health', 0, PlayState.current.gameInfo.maxHealth);
		healthBar.scrollFactor.set();
		healthBar.numDivisions = healthBar.frameWidth;
		healthBar.createFilledBar(PlayState.current.opponent.healthColor, PlayState.current.player.healthColor);
		add(healthBar);

		iconP1 = new HealthIcon(0, 0, PlayState.current.player.name);
		iconP1.origin.x = 0;
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.scrollFactor.set();
		iconP1.updateScale = true;
		iconP1.flipX = true;
		add(iconP1);

		iconP2 = new HealthIcon(0, 0, PlayState.current.opponent.name);
		iconP2.origin.x = iconP2.width;
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.scrollFactor.set();
		iconP2.updateScale = true;
		add(iconP2);

		scoreText = new FlxText(0, 0, 0, "[Score] 0 // [Misses] 0 // [Rank] (0.00% - N/A)");
		scoreText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 1.25;
		scoreText.screenCenter(X);
		scoreText.y = healthBarBG.y + 30;
		add(scoreText);

		engineText = new FlxText(0, 0, 0, 'Crow Engine ${Main.engineVersion.display}');
		engineText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		engineText.borderSize = 1.25;
		engineText.x = FlxG.width - engineText.width - 40;
		engineText.y = healthBarBG.y + 30;
		add(engineText);
    }
}