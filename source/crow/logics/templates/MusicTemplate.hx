package crow.logics.templates;

import crow.logics.templates.Template;

class MusicTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"music_load" => ExecutableAction.createAction((ctx) ->
			{
				final soundId:String = ctx.values.sound;
				if (soundId != null)
					ctx.executor.music.load(soundId);
				ctx.onComplete();
			}, [{name: "sound", type: "String", optional: false}], {wantsExecutor: true}),
			"music_play" => ExecutableAction.createAction((ctx) ->
			{
				ctx.executor.music.play();
				ctx.onComplete();
			}, [], {wantsExecutor: true}),
			"music_pause" => ExecutableAction.createAction((ctx) ->
			{
				ctx.executor.music.pause();
				ctx.onComplete();
			}, [], {wantsExecutor: true}),
			"music_stop" => ExecutableAction.createAction((ctx) ->
			{
				ctx.executor.music.stop();
				ctx.onComplete();
			}, [], {wantsExecutor: true}),
			"music_fade_in" => ExecutableAction.createAction((ctx) ->
			{
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
			], {wantsExecutor: true}),
			"music_fade_out" => ExecutableAction.createAction((ctx) ->
			{
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
			], {wantsExecutor: true})
		];
	}
}
