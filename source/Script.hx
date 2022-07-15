package;

import flixel.math.FlxPoint;
import flixel.util.FlxAxes;
import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import openfl.utils.Assets;
import flixel.math.FlxMath;
import flixel.FlxG;
import openfl.display.BitmapData;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxSprite;
#if desktop
import sys.io.File;
#elseif web
import 
#end
import hscript.Parser;
import hscript.Interp;

class Script
{
	public static final FUNCTION_STOP = -64;
	public static final FUNCTION_CONTINUE = -128;
	public static final FUNCTION_FORCESTOP = -32;

	public static var libraries:Map<String, Script> = [];

	public var name:String;
	public var hscript:Interp;

	public static function executeLibraryFunc(script:String, funcName:String, ?args:Array<Any>)
	{
		if (libraries.exists(script))
		{
			return libraries[script].executeFunc(funcName, args);
		}
		return FUNCTION_STOP;
	}

	public function new(path:String)
	{
		#if HSCRIPT_ALLOWED
		name = path;
		hscript = new Interp();
		setVars();
		loadFile(path);
		#end
	}

	public function executeFunc(funcName:String, ?args:Array<Any>)
	{
		if (hscript.variables.exists(funcName))
		{
			var func = hscript.variables.get(funcName);
			if (args == null)
			{
				try
				{
					var callb:Null<Int> = func();
					if (callb == null)
						return FUNCTION_CONTINUE;
					return callb;
				}
				catch (e)
				{
					trace('$e');
				}
			}
			else
			{
				try
				{
					var callb:Null<Int> = Reflect.callMethod(null, func, args);
					if (callb == null)
						return FUNCTION_CONTINUE;
					return callb;
				}
				catch (e)
				{
					trace('${e.message} ${e.native}');
				}
			}
		}

		return FUNCTION_CONTINUE;
	}

	public function stopScript()
	{
		#if HSCRIPT_ALLOWED
		if (hscript == null)
			return;

		hscript = null;
		#end
	}

	function loadFile(path:String)
	{
		final path = path;
		if (path == '')
			return;

		var parser = new Parser();
		parser.allowTypes = true;

		try
		{
			hscript.execute(parser.parseString(File.getContent(path)));
		}
		catch (e)
		{
			trace('${e.message}');
		}
	}

	public function setVariable(name:String, value:Dynamic)
	{
		hscript.variables.set(name, value);
	}

	public function getVariable(name:String)
	{
		return hscript.variables.get(name);
	}

	public function setVars()
	{
		setVariable("FUNCTION_STOP", FUNCTION_STOP);
		setVariable("FUNCTION_CONTINUE", FUNCTION_CONTINUE);

		var buildEnvironment:String = 'unknown';
		#if windows
		buildEnvironment = 'windows';
		#elseif linux
		buildEnvironment = 'linux';
		#elseif mac
		buildEnvironment = 'mac';
		#elseif html5
		buildEnvironment = 'browser';
		#elseif android
		buildEnvironment = 'android';
		#end
		setVariable('buildEnvironment', buildEnvironment);

		// flixel
		setVariable("FlxSprite", FlxSprite);
		setVariable("FlxObject", FlxObject);
		setVariable("BitmapData", BitmapData);
		setVariable("FlxG", FlxG);
		setVariable("Paths", Paths);
		setVariable("Std", Std);
		setVariable("Math", Math);
		setVariable("FlxMath", FlxMath);
		setVariable("Assets", Assets);
		setVariable("StringTools", StringTools);
		setVariable("FlxSound", FlxSound);
		setVariable("FlxEase", FlxEase);
		setVariable("FlxTween", FlxTween);
		// setVariable("FlxColor", FlxColor);
		setVariable("FlxTypedGroup", FlxTypedGroup);
		setVariable("FlxTimer", FlxTimer);
		setVariable("CoolUtil", CoolUtil);
		setVariable("FlxTypeText", FlxTypeText);
		setVariable("FlxText", FlxText);
		setVariable("FlxAxes", FlxAxes);
		setVariable("FlxPoint", FlxPoint);

		// game
		setVariable("PlayState", PlayState.current);
		setVariable("_PlayState", PlayState);
		setVariable("_GameOverSubstate", GameOverSubstate);
		setVariable("ClientPrefs", ClientPrefs);

		setVariable("_Paths", Paths);

		setVariable("trace", trace);
	}

	public function trace(s:Dynamic)
	{
		trace(s);
	}
}

class HScriptText extends FlxText
{
	private var disableTime:Float = 6;

	public var parentGroup:FlxTypedGroup<HScriptText>;

	public function new(text:String, parentGroup:FlxTypedGroup<HScriptText>, color:FlxColor)
	{
		this.parentGroup = parentGroup;
		super(10, 10, 0, text, 16);
		setFormat(Paths.defaultFont, 20, color, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollFactor.set();
		borderSize = 1;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		disableTime -= elapsed;
		if (disableTime <= 0)
		{
			x -= elapsed * 2.5;
            alpha -= elapsed * 1.5;
		}
        if (x + width <= -2 || alpha == 0)
        {
            kill();
			parentGroup.remove(this);
			destroy();
        }
	}
}
