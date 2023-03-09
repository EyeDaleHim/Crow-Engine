package game.cutscenes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import states.PlayState;
import backend.Transitions;

// to swick:
/*
	do the senpai transformation scene here
	feel free to copy from base FNF shit ill uhh look when you finish
*/

class DialogueBox extends FlxTypedGroup<FlxSprite>
{
    public var dialogue:Array<DialogueText> = [];

    public static var songs:Array<String> = ['senpai', 'roses', 'thorns'];

	public var song:String;
	public var endCallback:Void->Void;

	private var background:FlxSprite;
    private var dialogueBox:FlxSprite;

    private var portraitLeft:FlxSprite;
    private var portraitRight:FlxSprite;

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
        if (song == 'thorns')
            background.color = 0xFF000000;
		background.scrollFactor.set();
		background.alpha = 0;
		background.active = false;
		add(background);

        dialogueBox = new FlxSprite(-20, -45);

        var openingBox:String = switch (song)
        {
            default:
                'Text Box Appear';
            case 'roses':
                'SENPAI ANGRY IMPACT SPEECH';
            case 'thorns':
                'Spirit Textbox spawn';
        };

        dialogueBox.frames = Paths.getSparrowAtlas('cutscenes/$song/dialogueBox');
        dialogueBox.animation.addByPrefix('open', openingBox, 24, false);
        dialogueBox.animation.finishCallback = function(name)
        {
            dialogueBox.animation.pause();
        }
        dialogueBox.animation.play('open');
        dialogueBox.scale.set(6 * 0.9, 6 * 0.9);
        dialogueBox.antialiasing = false;
        dialogueBox.screenCenter(X);
        add(dialogueBox);


		PlayState.current.hudCamera.alpha = 0.0;

		new FlxTimer().start(0.8, function(tmr:FlxTimer)
		{
			background.alpha += (1 / 5) * 0.7;

			if (background.alpha > 0.7)
				background.alpha = 0.7;
		}, 5);
	}
}

typedef DialogueText =
{
    var char:String;
    var dialog:String;
}