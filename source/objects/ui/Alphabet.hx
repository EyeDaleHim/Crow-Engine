package objects.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import objects.handlers.IFunkinSprite;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxTypedSpriteGroup<AlphaCharacter> implements IFunkinSprite
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;

	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, text:String = "", ?bold:Bool = false, typed:Bool = false)
	{
		super(x, y);

		_finalText = text;
		this.text = text;
		isBold = bold;

		if (text != "")
		{
			if (typed)
			{
				startTypedText();
			}
			else
			{
				addText();
			}
		}
	}

	public function addText()
	{
		doSplitWords();

		for (character in splitWords)
		{
			// if (character.fastCodeAt() == " ")
			// {
			// }

			if (character == " " || character == "-")
			{
				lastWasSpace = true;
			}

			var isLetter = AlphaCharacter.alphabet.match(character.toLowerCase());
			var isNumber = AlphaCharacter.numbers.match(character.toLowerCase());
			var isSymbol = AlphaCharacter.symbols.match(character.toLowerCase());

			if (isLetter || isNumber || isSymbol)
			{
				var xPos = lastSprite != null ? lastSprite.x + lastSprite.width : 0;
				xPos += lastWasSpace ? 40 : 0;
				lastWasSpace = false;

				var letter = new AlphaCharacter(xPos, 0);
				if (isLetter)
					letter.createLetter(character, isBold);
				else if (isNumber)
					letter.createNumber(character, isBold);
				else if (isSymbol)
					letter.createSymbol(character, isBold);
				add(letter);

				lastSprite = letter;
			}

			// loopNum += 1;
		}
	}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		// trace(arrayShit);

		var xPos:Float = 0;
		var curRow:Int = 0;

		for (i in 0...splitWords.length)
		{
			// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));
			if (_finalText.fastCodeAt(i) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
			}

			if (splitWords[i] == " ")
			{
				lastWasSpace = true;
			}

			var isNumber:Bool = AlphaCharacter.numbers.match(splitWords[i]);
			var isSymbol:Bool = AlphaCharacter.symbols.match(splitWords[i]);

			if (AlphaCharacter.alphabet.match(splitWords[i].toLowerCase()) || isNumber || isSymbol)
				// if (AlphaCharacter.alphabet.contains(splitWords[loopNum].toLowerCase()) || isNumber || isSymbol)

			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
					// if (isBold)
					// xPos -= 80;
				}
				else
				{
					xPosResetted = false;
				}

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}
				// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = recycle(AlphaCharacter);
				letter.setPosition(xPos, 55 * yMulti);
				letter.ID = i;
				letter.row = curRow;
				if (isNumber)
				{
					letter.createNumber(splitWords[i], isBold);
				}
				else if (isSymbol)
				{
					letter.createSymbol(splitWords[i], isBold);
				}
				else
				{
					letter.createLetter(splitWords[i], isBold);
				}

				letter.x += 90;

				add(letter);

				lastSprite = letter;
			}
		}
	}

	override function update(elapsed:Float)
	{
		updateMenuPosition(elapsed);

		super.update(elapsed);
	}

	public function updateMenuPosition(elapsed:Float, force:Bool = false)
	{
		if (isMenuItem || force)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = Tools.lerpBound(y, (scaledY * 120) + (FlxG.height - height) / 2, elapsed * 6.3);
			x = Tools.lerpBound(x, (targetY * 20) + 90, elapsed * 6.3);
		}
	}

	function set_text(Text:String):String
	{
		for (letter in members)
		{
			remove(letter, true);
			letter.destroy();
		}

		text = Text;
		addText();

		return text;
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet = ~/[a-z]|[A-Z]/g;
	public static var numbers = ~/[0-9]/g;
	public static var symbols = ~/[\|~#$%()*+-:;<=>\[\]\^_.,'!@]/g;

	public var row:Int = 0;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		moves = false;

		var tex = Paths.getSparrowAtlas('alphabet');
		frames = tex;

		antialiasing = true;
	}

	public function createLetter(letter:String, bold:Bool = false):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
		{
			letterCase = 'capital';
		}

		if (bold)
			letterCase = "bold";

		animation.addByPrefix(letter, (letterCase == 'bold' ? letter.toUpperCase() : letter) + " " + letterCase, 24);
		animation.play(letter);
		updateHitbox();

		y += row * 60;
	}

	public function createNumber(letter:String, bold:Bool = false):Void
	{
		animation.addByPrefix(letter, (bold ? "bold" : "") + letter, 24);
		animation.play(letter);

		updateHitbox();
	}

	public function createSymbol(letter:String, bold:Bool = false)
	{
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'period' + (bold ? " bold" : ""), 24);
				animation.play(letter);
				y += 50;
			case "'":
				animation.addByPrefix(letter, (bold ? 'apostraphie'.toUpperCase() : 'apostraphie') + (bold ? " bold" : ""), 24);
				animation.play(letter);
			case "?":
				animation.addByPrefix(letter, 'question mark' + (bold ? " bold" : ""), 24);
				animation.play(letter);
			case "!":
				animation.addByPrefix(letter, 'exclamation point' + (bold ? " bold" : ""), 24);
				animation.play(letter);
		}

		updateHitbox();
	}
}
