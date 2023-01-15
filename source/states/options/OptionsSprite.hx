package states.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import utils.InputFormat;
import backend.data.Controls;
import states.options.ControlsBindSubState;

using StringTools;
using utils.Tools;

@:allow(states.options.OptionsMenu)
class OptionsSprite extends FlxTypedSpriteGroup<FlxSprite>
{
	public var name:String = '';
	public var saveHolder:String = '';
	public var description:String = '';

	public var isSelected(default, set):Bool = false;
	public var selectionIndex:Int = 0;

	private var _background:FlxSprite;
	private var _truthSprite:FlxSprite;
	private var _selectionBG:FlxSprite;
	private var _nameSprite:FlxText;

	// bool
	private var _isAccepted:Bool;
	private var _statsText:FlxText; // on, off

	// float, int
	private var _valueSet:Float;
	private var _bound:{min:Int, max:Int};
	private var _choices:Array<Dynamic> = [];
	private var _arrowLeft:FlxText;
	private var _arrowRight:FlxText;
	private var _numText:FlxText;
	private var _holdCooldown:Float = 0;
	private var _heldDown:Float = 0;

	// controls
	public var selectedControls:Int = 0;

	private var _controlTitle:FlxText;

	private var _mainControl:FlxText;
	private var _altControl:FlxText;

	private var _actualData:Dynamic = [];

	private var __type:Int = -1;

	override function new(name:String, saveHolder:String, description:String, defaultValue:Dynamic, ?bound:{min:Int, max:Int}, ?choices:Array<Dynamic>,
			type:Int = -1)
	{
		super();

		this.name = name;
		this.saveHolder = saveHolder;
		this.description = description;
		__type = type;
		_bound = bound;
		_choices = choices;

		_background = new FlxSprite().makeGraphic(Std.int(FlxG.width * 0.6), 90, FlxColor.BLACK);
		_background.scrollFactor.set();
		_background.alpha = 0.3;

		if (__type == 0)
		{
			_truthSprite = new FlxSprite().makeGraphic(20, 90, FlxColor.WHITE);
			_truthSprite.scrollFactor.set();
			add(_truthSprite);
		}

		_selectionBG = new FlxSprite().makeGraphic(Std.int(FlxG.width * 0.6), 90, FlxColor.WHITE);
		_selectionBG.scrollFactor.set();
		_selectionBG.alpha = 0.0;

		_nameSprite = new FlxText(20, 0, 0, name, 26);
		_nameSprite.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, LEFT);
		_nameSprite.centerOverlay(_background, Y);

		add(_background);
		add(_selectionBG);
		add(_nameSprite);

		switch (__type)
		{
			case 0:
				{
					_isAccepted = Settings.getPref(saveHolder, null);
					if (!Settings.prefExists(saveHolder))
						_isAccepted = defaultValue;

					_actualData = _isAccepted;

					_truthSprite.x = if (_isAccepted) width - _truthSprite.width else 0;

					_statsText = new FlxText(0, 0, 0, (_isAccepted ? 'ON' : 'OFF'), 20);
					_statsText.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, LEFT);
					_statsText.centerOverlay(_background, Y);
					_statsText.x = _background.x + _background.width - _statsText.width - 20;
					add(_statsText);
				}
			case 1 | 2:
				{
					_valueSet = Settings.getPref(saveHolder, null);
					if (!Settings.prefExists(saveHolder))
						_valueSet = defaultValue;

					_actualData = _valueSet;

					_numText = new FlxText(0, 0, 0, Std.string(_valueSet), 20);
					_numText.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, LEFT);
					_numText.centerOverlay(_background, Y);
					_numText.x = _background.x + _background.width - _numText.width - 60;
					add(_numText);

					_arrowLeft = new FlxText(0, 0, 0, "<", 18);
					_arrowLeft.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, LEFT);
					_arrowLeft.centerOverlay(_numText, Y);
					_arrowLeft.x = _numText.x - _arrowLeft.width - 8;
					add(_arrowLeft);

					_arrowRight = new FlxText(0, 0, 0, ">", 18);
					_arrowRight.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, LEFT);
					_arrowRight.centerOverlay(_numText, Y);
					_arrowRight.x = _numText.x + _numText.width + 8;
					add(_arrowRight);
				}
			case 3:
				{
					remove(_nameSprite);

					_controlTitle = new FlxText(0, 0, 0, Controls.RENAME_CONTROLS.get(saveHolder.replace('#CONTROL_', '')), 20);
					_controlTitle.setFormat(Paths.font("vcr.ttf"), 26);
					_controlTitle.centerOverlay(_background, Y);
					_controlTitle.x = _background.x + 30;
					add(_controlTitle);

					@:privateAccess
					{
						_mainControl = new FlxText(0, 0, 0,
							InputFormat.format(Controls.instance.LIST_CONTROLS.get(saveHolder.replace('#CONTROL_', '')).__keys[0]).toUpperCase(), 18);
						_mainControl.setFormat(Paths.font("vcr.ttf"), 24);
						_mainControl.centerOverlay(_controlTitle, Y);
						_mainControl.x = _controlTitle.x + Math.max(_controlTitle.width, 200) + 150;
						_mainControl.x -= _mainControl.width / 2;
						add(_mainControl);

						_altControl = new FlxText(0, 0, 0,
							InputFormat.format(Controls.instance.LIST_CONTROLS.get(saveHolder.replace('#CONTROL_', '')).__keys[1]).toUpperCase(), 18);
						_altControl.setFormat(Paths.font("vcr.ttf"), 24);
						_altControl.centerOverlay(_controlTitle, Y);
						_altControl.x = _controlTitle.x + Math.max(_controlTitle.width, 200) + 400;
						_altControl.x -= _altControl.width / 2;
						add(_altControl);
					}
				}
		}
	}

	private var _offsetReset:Float = 0.0;

	override function update(elapsed:Float)
	{
		if ((_offsetReset += elapsed) > 1 / 12)
		{
			offset.set();
			if (_truthSprite != null)
				_truthSprite.offset.set();
		}

		if (isSelected)
			_selectionBG.alpha = 0.2;
		else
			_selectionBG.alpha = 0.0;

		_holdCooldown -= elapsed;

		if (__type == 0)
		{
			var wantedScale:Float = _truthSprite.scale.x + 1.5;

			if (_truthSprite.x <= _background.x || _truthSprite.x >= _background.x + _background.width - _truthSprite.width)
				wantedScale = 1.0;

			_truthSprite.scale.x = FlxMath.bound(Tools.lerpBound(_truthSprite.scale.x, wantedScale, elapsed * 12.4), 1, 1.8);
			_truthSprite.updateHitbox();

			if (_isAccepted)
				_truthSprite.x += elapsed * 320 * 4.7;
			else
				_truthSprite.x -= elapsed * 320 * 4.7;

			_truthSprite.x = FlxMath.bound(_truthSprite.x, _background.x, _background.x + _background.width - _truthSprite.width);
		}
		else if (__type == 3)
		{
			if (isSelected)
			{
				if (Controls.instance.getKey('UI_LEFT', JUST_PRESSED) || Controls.instance.getKey('UI_RIGHT', JUST_PRESSED))
				{
					selectedControls = (selectedControls == 0 ? 1 : 0);

					(selectedControls == 0 ? _mainControl : _altControl).scale.set(1.3, 1.3);
					(selectedControls == 1 ? _mainControl : _altControl).scale.set(1.0, 1.0);

					FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.75);
				}
			}

			@:privateAccess
			{
				_mainControl.text = InputFormat.format(Controls.instance.LIST_CONTROLS.get(saveHolder.replace('#CONTROL_', '')).__keys[0]).toUpperCase();
				_altControl.text = InputFormat.format(Controls.instance.LIST_CONTROLS.get(saveHolder.replace('#CONTROL_', '')).__keys[1]).toUpperCase();
			}
		}

		super.update(elapsed);
	}

	public function onChange(Value:Dynamic)
	{
		var acceptedOffset:Bool = false;

		switch (__type)
		{
			case 0:
				{
					_actualData = _isAccepted = Value;

					_statsText.text = _isAccepted ? 'ON' : 'OFF';
					_statsText.x = _background.x + _background.width - _statsText.width - 20;

					Settings.setPref(saveHolder, _isAccepted);

					acceptedOffset = true;
				}
			case 1 | 2:
				{
					if (_choices != null && __type == 2)
					{
						var index:Int = _choices.indexOf(_actualData);

						if (index == -1)
							index = 0;

						index = FlxMath.wrap(index + Value, 0, _choices.length - 1);

						_numText.text = Std.string(_choices[index]);
						_numText.x = _background.x + _background.width - _numText.width - 60;

						_arrowLeft.x = _numText.x - _arrowLeft.width - 8;
						_arrowRight.x = _numText.x + _numText.width + 8;

						Settings.setPref(saveHolder, _choices[index]);

						_actualData = _choices[index];
					}
					else
					{
						if (_bound != null)
							_valueSet = FlxMath.bound(_valueSet + Value, _bound.min, _bound.max);
						else
							_valueSet = _valueSet + Value;

						_actualData = _valueSet;

						_numText.text = Std.string(_valueSet);
						_numText.x = _background.x + _background.width - _numText.width - 60;

						_arrowLeft.x = _numText.x - _arrowLeft.width - 8;
						_arrowRight.x = _numText.x + _numText.width + 8;

						Settings.setPref(saveHolder, _valueSet);
					}

					acceptedOffset = true;
				}
			case 3:
				{
					FlxG.state.persistentUpdate = false;

					FlxG.state.openSubState(new ControlsBindSubState(saveHolder.replace('#CONTROL_', ''), selectedControls));

					acceptedOffset = true;
				}
		}

		if (acceptedOffset)
		{
			_offsetReset = 0.0;
			offset.set(0, -8);
			if (_truthSprite != null)
				_truthSprite.offset.set(0, -8);
		}
	}

	function set_isSelected(Value:Bool):Bool
	{
		if (__type == 3)
		{
			_mainControl.scale.set(1.0, 1.0);
			_altControl.scale.set(1.0, 1.0);

			if (Value)
				(selectedControls == 0 ? _mainControl : _altControl).scale.set(1.3, 1.3);
		}

		return (isSelected = Value);
	}
}
