package gear.logics;

import gear.assets.metadata.logics.ActionMetadata;
import gear.assets.metadata.logics.LogicMetadata;
import gear.entities.AnimatedText;
import gear.utils.ColorData;

/**
 * A utility class for executing actions defined by `ListenerActionMetadata`.
 */
class LogicEvaluator
{
	public static function execute(actions:Array<ListenerActionMetadata>, logicState:Map<String, Dynamic>, ?entities:Map<String, Entity>,
			?executor:IEventExecutor):Void
	{
		for (action in actions)
		{
			final values = action.values ?? [];
			final postEvents = action.postListenerEvents;

			final onComplete = (postEvents != null && executor != null) ? () ->
			{
				execute(postEvents, logicState, entities, executor);
			} : null;

			final targetedEntities = (entities != null && action.targets != null) ? EntityFilter.filterEntities(entities, action.targets) : null;

			// TODO: create a jump table
			switch (action.type.trim())
			{
				case "play_animation":
					final animName:String = getValue(values, 0);
					if (animName == null)
						continue;

					final force:Bool = getValue(values, 1, false);
					handleEntityAction(targetedEntities, (entity) ->
					{
						// TODO: Filters for sprites within entities?
						entity.forEachOfType(FlxSprite, (spr) ->
						{
							spr.animation.play(animName, force);
						});
					});

				case "state_change":
					final stateChange:ActionMetadata = getValue(values, 0);
					if (stateChange == null)
						continue;
					ActionEvaluator.evaluate(stateChange, logicState);

				case "set_text" | "add_text" | "clear_text":
					handleEntityAction(targetedEntities, (entity) ->
					{
						entity.forEachOfType(AnimatedText, (textObject) ->
						{
							switch (action.type)
							{
								case "set_text": textObject.text = values.join("\n");
								case "add_text": textObject.text += (textObject.text == "" ? "" : "\n") + values.join("\n");
								case "clear_text": textObject.text = "";
								default:
							}
						});
					});
				case "set_visible":
					final visible:Null<Bool> = getValue(values, 0);
					if (visible == null)
						continue;
					handleEntityAction(targetedEntities, (entity) -> entity.visible = visible);
				case "set_alpha":
					final alpha:Null<Float> = getValue(values, 0);
					if (alpha == null)
						continue;
					handleEntityAction(targetedEntities, (entity) -> entity.alpha = alpha);
				case "play_sound":
					final soundId:String = getValue(values, 0);
					if (soundId == null)
						continue;
					final volume:Float = getValue(values, 1, 1.0);
					FlxG.sound.play(soundId, volume);
				case "camera_effect":
					final effectType:String = getValue(values, 0);
					switch (effectType)
					{
						case "flash":
							final color:FlxColor = ColorData.fromDynamic(getValue(values, 1)) ?? FlxColor.WHITE;
							final duration:Float = getValue(values, 2, 1.0);
							FlxG.camera.flash(color, duration, onComplete);
						case "fade":
							final color:FlxColor = ColorData.fromDynamic(getValue(values, 1)) ?? FlxColor.BLACK;
							final duration:Float = getValue(values, 2, 1.0);
							final reverse:Bool = getValue(values, 3, false);
							FlxG.camera.fade(color, duration, reverse, onComplete);
						case "shake":
							final intensity:Float = getValue(values, 1, 0.05);
							final duration:Float = getValue(values, 2, 0.15);
							final force:Bool = getValue(values, 3, true);
							FlxG.camera.shake(intensity, duration, onComplete, force);
					}
				case "dispatch_event":
					if (executor == null)
					{
						trace('Executor required for this action: $action.type');
						continue;
					}

					final eventName:String = getValue(values, 0);
					if (eventName == null)
						continue;
					final eventArgs:Map<String, Dynamic> = getValue(values, 1);
					executor.onEvent(eventName, eventArgs);

				case "create_tween":
					if (executor == null)
					{
						trace('Executor required for this action: $action.type');
						continue;
					}

					final tweenName:String = getValue(values, 0);
					final tweenProps:Dynamic = getValue(values, 1);
					final duration:Null<Float> = getValue(values, 2);

					if (tweenName == null || tweenProps == null || duration == null)
					{
						trace('Invalid arguments for create_tween: name, properties, and duration are required.');
						continue;
					}

					final tweenOptions:Dynamic = getValue(values, 3, {});
					if (onComplete != null)
						tweenOptions.onComplete = onComplete;

					handleEntityAction(targetedEntities, (entity) ->
					{
						// TODO: Allow targeting specific sprites within an entity.
						executor.tweenManager.tween(tweenName, entity, tweenProps, duration, tweenOptions);
					});

				case "create_timer":
					if (executor == null)
					{
						trace('Executor required for this action: $action.type');
						continue;
					}

					final timerName:String = getValue(values, 0);
					final time:Null<Float> = getValue(values, 1);

					if (timerName == null || time == null)
					{
						trace('Invalid arguments for create_timer: name and time are required.');
						continue;
					}

					executor.timerManager.wait(timerName, time, onComplete);

				case "cancel_timer":
					if (executor == null)
					{
						trace('Executor required for this action: $action.type');
						continue;
					}
					final timerName:String = getValue(values, 0);
					if (timerName != null)
						executor.timerManager.remove(timerName);

				case "cancel_tween":
					if (executor == null)
					{
						trace('Executor required for this action: $action.type');
						continue;
					}
					final tweenName:String = getValue(values, 0);
					if (tweenName != null)
						executor.tweenManager.remove(tweenName);
				case "open_url":
					final url:String = getValue(values, 0);
					if (url != null)
						FlxG.openURL(url);
				case "exit_game":
					Sys.exit(0);
				case "destroy_entity":
					handleEntityAction(targetedEntities, (entity) ->
					{
						if (entities.exists(entity.entityName))
						{
							entity.destroy();
							entities.remove(entity.entityName); // Remove from map after destroying
						}
					});
				case "music_load" | "music_play" | "music_pause" | "music_stop" | "music_fade_in" | "music_fade_out":
					if (executor == null || executor.music == null)
					{
						trace('Executor with a music object is required for music actions: $action.type');
						continue;
					}
					switch (action.type)
					{
						case "music_load":
							final soundId:String = getValue(values, 0);
							if (soundId != null) executor.music.load(soundId);
						case "music_play":
							executor.music.play();
						case "music_pause":
							executor.music.pause();
						case "music_stop":
							executor.music.stop();
						case "music_fade_in":
							final duration:Float = getValue(values, 0, 1.0);
							final from:Null<Float> = getValue(values, 1);
							final to:Null<Float> = getValue(values, 2);
							if (executor.music.soundObject != null)
							{
								executor.music.soundObject.fadeIn(duration, from, to, (_) ->
								{
									if (onComplete != null)
										onComplete();
								});
							}
							else if (onComplete != null) onComplete();
						case "music_fade_out":
							final duration:Float = getValue(values, 0, 1.0);
							final to:Null<Float> = getValue(values, 1);
							if (executor.music.soundObject != null)
							{
								executor.music.soundObject.fadeOut(duration, to, (_) ->
								{
									if (onComplete != null)
										onComplete();
								});
							}
							else if (onComplete != null) onComplete();
					}
				case "remove_listeners_by_tag":
					if (executor == null)
					{
						trace('Executor required for this action: $action.type');
						continue;
					}
					final tagToRemove:String = getValue(values, 0);
					if (tagToRemove != null)
					{
						executor.removeListenersByTag(tagToRemove);
					}
				default:
					// Other actions can be added here.
			}
		}
	}

	private static function handleEntityAction(entities:Array<Entity>, entityFunc:Entity->Void):Void
	{
		if (entities == null)
			return;
		for (entity in entities)
		{
			entityFunc(entity);
		}
	}

	private static inline function getValue<T>(values:Array<Dynamic>, index:Int, ?defaultValue:T):T
	{
		return (values != null && index < values.length && values[index] != null) ? values[index] : defaultValue;
	}
}
