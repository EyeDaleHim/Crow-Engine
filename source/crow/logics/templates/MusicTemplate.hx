package crow.logics.templates;

import crow.logics.templates.Template;

class MusicTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		inline function checkExecutor(ctx:ActionContext, name:String):Bool
		{
			if (ctx.executor == null || ctx.executor.music == null)
			{
				trace('Executor with a music object is required for $name action.');
				return false;
			}
			return true;
		}

		return [
			"music_load" => ExecutableAction.createAction((ctx) ->
			{
				if (!checkExecutor(ctx, "music_load"))
					return;

				final soundId:String = ctx.values.sound;
				if (soundId != null)
					ctx.executor.music.load(soundId);
				ctx.onComplete();
			}, [{name: "sound", type: "String", optional: false}]),
			"music_play" => ExecutableAction.createAction((ctx) ->
			{
				if (!checkExecutor(ctx, "music_play"))
					return;

				ctx.executor.music.play();
				ctx.onComplete();
			}, []),
			"music_pause" => ExecutableAction.createAction((ctx) ->
			{
				if (!checkExecutor(ctx, "music_pause"))
					return;

				ctx.executor.music.pause();
				ctx.onComplete();
			}, []),
			"music_stop" => ExecutableAction.createAction((ctx) ->
			{
				if (!checkExecutor(ctx, "music_stop"))
					return;

				ctx.executor.music.stop();
				ctx.onComplete();
			}, []),
			"music_fade_in" => ExecutableAction.createAction((ctx) ->
			{
				if (!checkExecutor(ctx, "music_fade_in"))
					return;

				final duration:Float = ctx.values.duration != null ? ctx.values.duration : 1.0;
				final from:Null<Float> = ctx.values.from;
				final to:Null<Float> = ctx.values.to;
				if (ctx.executor.music.soundObject != null)
				{
					ctx.executor.music.soundObject.fadeIn(duration, from, to, (_) ->
					{
						if (ctx.onComplete != null)
							ctx.onComplete();
					});
				}
				else if (ctx.onComplete != null)
					ctx.onComplete();
			}, [
					{name: "duration", type: "Float", optional: true},
					{name: "from", type: "Float", optional: true},
					{name: "to", type: "Float", optional: true}
			]),
			"music_fade_out" => ExecutableAction.createAction((ctx) ->
			{
				if (!checkExecutor(ctx, "music_fade_out"))
					return;

				final duration:Float = ctx.values.duration != null ? ctx.values.duration : 1.0;
				final to:Null<Float> = ctx.values.to;
				if (ctx.executor.music.soundObject != null)
				{
					ctx.executor.music.soundObject.fadeOut(duration, to, (_) ->
					{
						if (ctx.onComplete != null)
							ctx.onComplete();
					});
				}
				else if (ctx.onComplete != null)
					ctx.onComplete();
			}, [
					{name: "duration", type: "Float", optional: true},
					{name: "to", type: "Float", optional: true}
			])
		];
	}
}
