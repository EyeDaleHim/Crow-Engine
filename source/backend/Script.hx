package backend;

import Main.VersionScheme;
import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
import sys.FileSystem;
import lime.utils.Assets;

class Script
{
	public static final blacklistedClasses:Array<String> = [];
	public static final whitelistedVariables:Array<String> = [];

	public var interp:Interp;

	// compatibility
	public var definedVersion:VersionScheme = Main.engineVersion;

	public function new(path:String, script:String)
	{
		var scriptData:Parser = new Parser();

		scriptData.resumeErrors = true;
		scriptData.allowTypes = true;

		if (FileSystem.exists(Paths.file('assets/$path/$script', 'hx', TEXT)))
		{
			try
			{
				interp.execute(scriptData.parseString(Assets.getText(Paths.file('assets/$path/$script', 'hx', TEXT))));
			}
			catch (e)
			{
				trace(e.message);
			}
		}
		else
			return;

		setVariable("FlxG", flixel.FlxG);
		setVariable("FlxSprite", flixel.FlxSprite);
		setVariable("FlxObject", flixel.FlxObject);
		setVariable("FlxCamera", flixel.FlxCamera);

		setVariable("definedVersion", definedVersion.number);
	}

	public function setVariable(name:String, value:Dynamic)
	{
		interp.variables.set(name, value);
	}

	public function getVariable(name:String, defaultValue:Dynamic)
	{
		if (!interp.variables.exists(name))
			setVariable(name, defaultValue);
		return interp.variables.get(name);
	}

	public function executeFunction(name:String, args:Array<Any>)
	{
		if (interp.variables.exists(name))
		{
			var func = interp.variables.get(name);

			if (args == null)
			{
				try
				{
					func();
				}
				catch (e)
				{
					trace(e.message);
				}
			}
			else
			{
				try
				{
					Reflect.callMethod(null, func, args);
				}
				catch (e)
				{
					trace(e.message);
				}
			}
		}
	}
}
