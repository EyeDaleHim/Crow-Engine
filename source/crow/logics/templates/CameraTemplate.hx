package crow.logics.templates;

import crow.logics.templates.Template;
import crow.utils.ColorData;

class CameraTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"camera_flash" => ExecutableAction.createAction((ctx) ->
			{
				final color:FlxColor = ColorData.fromDynamic(ctx.values.color) ?? FlxColor.WHITE;
				final duration:Float = ctx.values.duration != null ? ctx.values.duration : 1.0;
				FlxG.camera.flash(color, duration, ctx.onComplete);
			}, [{name: "color", type: "Dynamic", optional: true}, {name: "duration", type: "Float", optional: true}]),
			"camera_fade" => ExecutableAction.createAction((ctx) ->
			{
				final color:FlxColor = ColorData.fromDynamic(ctx.values.color) ?? FlxColor.BLACK;
				final duration:Float = ctx.values.duration != null ? ctx.values.duration : 1.0;
				final reverse:Bool = ctx.values.reverse != null ? ctx.values.reverse : false;
				FlxG.camera.fade(color, duration, reverse, ctx.onComplete);
			}, [
				{name: "color", type: "Dynamic", optional: true},
				{name: "duration", type: "Float", optional: true},
				{name: "reverse", type: "Bool", optional: true}
			]),
			"camera_shake" => ExecutableAction.createAction((ctx) ->
			{
				final intensity:Float = ctx.values.intensity != null ? ctx.values.intensity : 0.05;
				final duration:Float = ctx.values.duration != null ? ctx.values.duration : 0.15;
				final force:Bool = ctx.values.force != null ? ctx.values.force : true;
				FlxG.camera.shake(intensity, duration, ctx.onComplete, force);
			}, [
				{name: "intensity", type: "Float", optional: true},
				{name: "duration", type: "Float", optional: true},
				{name: "force", type: "Bool", optional: true}
			]),
            // legacy "camera_effect" for backwards compatibility
            
			"camera_effect" => ExecutableAction.createAction((ctx) ->
			{
				final effectType:String = ctx.values.effect;
				switch (effectType)
				{
					case "flash":
						final color:FlxColor = ColorData.fromDynamic(ctx.values.color) ?? FlxColor.WHITE;
						final duration:Float = ctx.values.duration != null ? ctx.values.duration : 1.0;
						FlxG.camera.flash(color, duration, ctx.onComplete);
					case "fade":
						final color:FlxColor = ColorData.fromDynamic(ctx.values.color) ?? FlxColor.BLACK;
						final duration:Float = ctx.values.duration != null ? ctx.values.duration : 1.0;
						final reverse:Bool = ctx.values.reverse != null ? ctx.values.reverse : false;
						FlxG.camera.fade(color, duration, ctx.onComplete);
					case "shake":
						final intensity:Float = ctx.values.intensity != null ? ctx.values.intensity : 0.05;
						final duration:Float = ctx.values.duration != null ? ctx.values.duration : 0.15;
						final force:Bool = ctx.values.force != null ? ctx.values.force : true;
						FlxG.camera.shake(intensity, duration, ctx.onComplete, force);
				}
			}, [
				{name: "effect", type: "String", optional: false},
				{name: "color", type: "Dynamic", optional: true},
				{name: "duration", type: "Float", optional: true},
				{name: "reverse", type: "Bool", optional: true},
				{name: "intensity", type: "Float", optional: true},
				{name: "force", type: "Bool", optional: true}
			])
			
		];
	}
}
