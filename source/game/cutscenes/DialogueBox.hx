package game.cutscenes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import states.PlayState;
import backend.Transitions;
import game.cutscenes.CutsceneHandler;

// to swick:

class DialogueBox extends FlxTypedGroup<FlxSprite>
{
	public var dialogue:Map<String, Array<DialogueText>> = [
		'senpai' => [
			{side: 'left', dialog: 'Ah, a new fair maiden has come in search of true love!'},
			{side: 'left', dialog: 'A serenade between gentlemen shall decide where her beautiful heart shall reside.'},
			{side: 'right', dialog: 'Beep bo bop'}
		],
		'roses' => [
			{side: 'left', dialog: 'Not bad for an ugly worm.'},
			{side: 'left', dialog: 'But this time I\'ll rip your nuts off right after your girlfriend finishes gargling mine.'},
			{side: 'right', dialog: 'Bop beep be be skdoo bep'}
		],
		'thorns' => [
			{side: 'left', dialog: 'Direct contact with real humans, after being trapped in here for so long...'},
			{side: 'left', dialog: 'and HER of all people.'},
			{side: 'left', dialog: 'I\'ll make her father pay for what he\'s done to me and all the others...'},
			{side: 'left', dialog: 'I\'ll beat you and make you take my place.'},
			{side: 'left', dialog: 'You don\'t mind your bodies being borrowed right? It\'s only fair.'}
		]
	];

	public static var songs:Array<String> = ['senpai', 'roses', 'thorns'];

	public var song:String;
	public var endCallback:Void->Void;

	private var background:FlxSprite;
	private var dialogueBox:FlxSprite;
	private var dialogueText:FlxTypeText;

	private var portraitLeft:FlxSprite;
	private var portraitRight:FlxSprite;

	private var handSelect:FlxSprite;

	private var senpaiTransform:FlxSprite;

	public override function new(song:String)
	{
		super();

		this.song = song;

		if (song == 'senpai')
		{
			Transitions.transition(1.5, Out, FlxEase.linear, Pixel_Fade, {
				endCallback: function()
				{
				}
			});
		}

		switch (song)
		{
			case 'senpai' | 'thorns':
				{
					FlxG.sound.playMusic(Paths.music('Lunchbox' + (song == 'thorns' ? 'Scary' : ''), 'week6'), 0.0);
					FlxG.sound.music.fadeIn(2, 0, 0.6);
				}
			case 'roses':
				{
					FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'), 0.6);
				}
		}

		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFB3DFD8);
		background.scrollFactor.set();
		background.alpha = 0;
		if (song == 'thorns')
			background.color = 0xFFFF1B31;
		background.active = false;
		add(background);

		switch (song)
		{
			case 'senpai':
				{
					portraitLeft = new FlxSprite(-20, 40);
					portraitLeft.frames = Paths.getSparrowAtlas('cutscenes/$song/portrait');
					portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
					portraitLeft.visible = false;
					portraitLeft.scale.set(6 * 0.9, 6 * 0.9);
					portraitLeft.updateHitbox();
					portraitLeft.antialiasing = false;
					portraitLeft.attributes.set('animationExists', true);
					add(portraitLeft);
				}
			case 'thorns':
				{
					portraitLeft = new FlxSprite(320, 170).loadGraphic(Paths.image('cutscenes/$song/spiritFaceForward'));
					portraitLeft.scale.set(6, 6);
					portraitLeft.antialiasing = false;
					portraitLeft.visible = false;
					add(portraitLeft);
				}
		}

		portraitRight = new FlxSprite(0, 25);
		portraitRight.frames = Paths.getSparrowAtlas('cutscenes/week6/bfPortrait');
		portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
		portraitRight.visible = false;
		portraitRight.scale.set(6 * 0.9, 6 * 0.9);
		portraitRight.updateHitbox();
		portraitRight.antialiasing = false;

		if (portraitLeft != null)
			add(portraitLeft);
		add(portraitRight);

		dialogueBox = new FlxSprite(-20, 25);

		dialogueBox.frames = Paths.getSparrowAtlas('cutscenes/$song/dialogueBox');
		dialogueBox.animation.addByPrefix('open', switch (song)
		{
			default:
				'Text Box Appear';
			case 'roses':
				'SENPAI ANGRY IMPACT SPEECH';
			case 'thorns':
				'Spirit Textbox spawn';
		}, 24, false);
		dialogueBox.animation.finishCallback = function(name)
		{
			dialogueBox.active = false;
			dialogueBox.animation.pause();

			changeDialogue();
		}
		dialogueBox.visible = false;
		dialogueBox.scale.set(6 * 0.9, 6 * 0.9);
		dialogueBox.antialiasing = false;
		dialogueBox.updateHitbox();
		dialogueBox.screenCenter(X);
		add(dialogueBox);

		dialogueText = new FlxTypeText(230, 475, Std.int(FlxG.width * 0.6), "", 32);
		dialogueText.setFormat('Pixel Arial 11 Bold', 32, 0xFF3F2021, LEFT, SHADOW, 0xFFD89494);
		dialogueText.borderSize = 0.5;
		dialogueText.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		dialogueText.completeCallback = function()
		{
			handSelect.visible = true;
		};
		add(dialogueText);

		handSelect = new FlxSprite(1000, 575).loadGraphic(Paths.image('cutscenes/week6/hand_textbox'));
		handSelect.scale.set(6 * 0.9, 6 * 0.9);
		handSelect.updateHitbox();
		handSelect.visible = false;
		handSelect.antialiasing = false;
		add(handSelect);

		PlayState.current.hudCamera.alpha = 0.0;

		if (song != 'thorns')
		{
			new FlxTimer().start(0.8, function(tmr:FlxTimer)
			{
				background.alpha += (1 / 5) * 0.7;

				if (background.alpha > 0.7)
					background.alpha = 0.7;
			}, 5);

			new FlxTimer().start(0.6 * 5, function(tmr:FlxTimer)
			{
				startConversation = true;
			});
		}
		else
		{
			background.alpha = 1;
			dialogueText.color = 0xFFFFFFFF;
			dialogueText.borderColor = 0;

			senpaiTransform = new FlxSprite();
			senpaiTransform.frames = Paths.getSparrowAtlas('cutscenes/thorns/senpaiCrazy');
			senpaiTransform.animation.addByPrefix('transform', 'Senpai Pre Explosion', 24, false);
			senpaiTransform.scale.set(5 * 0.9, 5 * 0.9);
			senpaiTransform.updateHitbox();
			senpaiTransform.screenCenter();
			senpaiTransform.antialiasing = false;
			add(senpaiTransform);

			senpaiTransform.alpha = 0;
			new FlxTimer().start(0.8, function(tmr:FlxTimer)
			{
				senpaiTransform.alpha += (1 / 5);
			}, 5);

			new FlxTimer().start(0.9 * 5, function(tmr:FlxTimer)
			{
				senpaiTransform.animation.play('transform');
				FlxG.sound.play(Paths.sound('Senpai_Dies'), 0.6, false, true, function()
				{
					senpaiTransform.destroy();
					background.color = 0xFF000000;
					background.alpha = 0.7;

					startConversation = true;

					PlayState.current.pauseCamera.fade(0, 0.0016, true);
				});

				new FlxTimer().start(3.2, function(deadTime:FlxTimer)
				{
					PlayState.current.pauseCamera.fade(0xFFFFFFFF, 1.6, false);
				});
			});
		}
	}

	private var startConversation:Bool = false;

	public override function update(elapsed:Float)
	{
		if (startConversation)
		{
			dialogueBox.visible = true;

			if (dialogueBox.animation.curAnim == null)
			{
				dialogueBox.animation.play('open');

				if (portraitLeft?.attributes.exists('animationExists'))
					portraitLeft.animation.play('enter');
			}

			if (PlayState.current.controls.getKey('ACCEPT', JUST_PRESSED))
			{
				changeDialogue();
			}
		}

		super.update(elapsed);
	}

	public function endDialogue():Void
	{
		startConversation = false;

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			dialogueBox.alpha -= 1 / 5;
			background.alpha -= 1 / 5 * 0.7;
			if (portraitLeft != null)
				portraitLeft.visible = false;
			if (portraitRight != null)
				portraitRight.visible = false;
			dialogueText.alpha -= 1 / 5;
			handSelect.alpha -= 1 / 5;
		}, 5);

		new FlxTimer().start(0.6 * 5, function(tmr:FlxTimer)
		{
			endCallback();
			destroy();
		});
	}

	private var dialogueStarted:Bool = false;

	public function changeDialogue():Void
	{
		if (dialogue[song].length == 0)
		{
			endDialogue();
			return;
		}

		if (dialogueText.text == dialogue[song][0].dialog)
		{
			dialogueText.skip();
			return;
		}

		switch (dialogue[song][0].side)
		{
			case 'left':
				portraitRight.visible = false;
				if (portraitLeft != null)
				{
					if (!portraitLeft.visible)
					{
						portraitLeft.visible = true;
						if (portraitLeft.attributes.exists('animationExists'))
							portraitLeft.animation.play('enter');
					}
				}
			case 'right':
				if (portraitLeft != null)
					portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
		}

		handSelect.visible = false;

		if (dialogueStarted)
			FlxG.sound.play(Paths.sound('clickText'), 0.6);

		dialogueText.resetText(dialogue[song][0].dialog);
		dialogueText.start(0.04);

		dialogue[song].shift();

		dialogueStarted = true;
	}
}

typedef DialogueText =
{
	var side:String;
	var dialog:String;
}
