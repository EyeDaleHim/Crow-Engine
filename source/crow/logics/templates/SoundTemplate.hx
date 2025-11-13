package crow.logics.templates;

import crow.logics.templates.Template;

class SoundTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"play_sound" => ExecutableAction.createAction((ctx) ->
			{
				final soundId:String = ctx.values.sound;
				final volume:Float = ctx.values.volume ?? 1.0;
				FlxG.sound.play(soundId, volume);
				ctx.onComplete();
			}, [
					{name: "sound", type: "String", optional: false},
					{name: "volume", type: "Float", optional: true}
			])
		];
	}
}
