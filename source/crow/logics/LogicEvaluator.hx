package crow.logics;

import crow.assets.metadata.logics.ActionMetadata;
import crow.assets.metadata.logics.LogicMetadata;
import crow.logics.StringInterpolator;
import crow.entities.AnimatedText;
import crow.utils.ColorData;

/**
 * A utility class for executing actions defined by `ListenerActionMetadata`.
 */
class LogicEvaluator
{
	public static final globalState:LogicState = new LogicState();

	public static function execute(actions:Array<ListenerActionMetadata>, executorState:LogicState, ?localState:LogicState, ?entities:Map<String, Entity>,
			?executor:IEventExecutor):Void
	{
		for (action in actions)
		{
			// Interpolate string values before execution
			final values:Dynamic = {};
			if (action.values != null)
			{
				if (!Reflect.isObject(action.values))
					throw 'action.values must be an object, not an array or primitive.';

				for (field in Reflect.fields(action.values))
				{
					if (Std.isOfType(Reflect.field(action.values, field), String))
					{
						Reflect.setField(values, field, StringInterpolator.interpolate(Reflect.field(action.values, field), executorState, localState));
					}
					else
					{
						Reflect.setField(values, field, Reflect.field(action.values, field));
					}
				}
			}
			final postEvents = action.postListenerEvents;

			final onComplete = (postEvents != null && executor != null) ? () ->
			{
				execute(postEvents, executorState, localState, entities, executor);
			} : null;

			final targetedEntities = (entities != null && action.targets != null) ? EntityFilter.filterEntities(entities, action.targets) : null;

			// TODO: create a jump table
			switch (action.type.trim())
			{
				case "play_animation":
					final animName:String = getValue(values, "anim");
					if (animName == null)
						continue;

					final force:Bool = getValue(values, "force", false);
					final updateHitbox:Bool = getValue(values, "updateHitbox", true);
					handleEntityAction(targetedEntities, (entity) ->
					{
						// TODO: Filters for sprites within entities?
						entity.forEachOfType(FlxSprite, (spr) ->
						{
							spr.animation.play(animName, force);
							if (localState != null)
							{
								// TODO: This might still be inaccurate in some cases, find solutions later!
								if (localState.get("compensate"))
								{
									spr.animation.update(localState.get("catchupMs") / 1000);
								}
							}
							if (updateHitbox)
								spr.updateHitbox();
						});
					});

				case "state_change":
					final stateChange:ActionMetadata = getValue(values, "state");
					if (stateChange == null)
						continue;
					if (stateChange.scope == ENTITY)
					{
						handleEntityAction(targetedEntities, (entity) ->
						{
							ActionEvaluator.evaluate(stateChange, executorState, localState, entity.logicState);
						});
					}
					else
						ActionEvaluator.evaluate(stateChange, executorState, localState);

				case "set_text" | "add_text" | "clear_text":
					handleEntityAction(targetedEntities, (entity) ->
					{
						entity.forEachOfType(AnimatedText, (textObject) ->
						{
							switch (action.type)
							{
								case "set_text": textObject.text = getValue(values, "text", "");
								case "add_text":
									final newText = getValue(values, "text", "");
									textObject.text += (textObject.text == "" ? "" : "\n") + newText;
								case "clear_text": textObject.text = "";
								default:
							}
						});
					});
				case "set_visible":
					final visible:Null<Bool> = getValue(values, "visible");
					if (visible == null)
						continue;
					handleEntityAction(targetedEntities, (entity) -> entity.visible = visible);
				case "set_alpha":
					final alpha:Null<Float> = getValue(values, "alpha");
					if (alpha == null)
						continue;
					handleEntityAction(targetedEntities, (entity) -> entity.alpha = alpha);
				case "play_sound":
					final soundId:String = getValue(values, "sound");
					if (soundId == null)
						continue;
					final volume:Float = getValue(values, "volume", 1.0);
					FlxG.sound.play(soundId, volume);
				case "camera_effect":
					final effectType:String = getValue(values, "effect");
					switch (effectType)
					{
						case "flash":
							final color:FlxColor = ColorData.fromDynamic(getValue(values, "color")) ?? FlxColor.WHITE;
							final duration:Float = getValue(values, "duration", 1.0);
							FlxG.camera.flash(color, duration, onComplete);
						case "fade":
							final color:FlxColor = ColorData.fromDynamic(getValue(values, "color")) ?? FlxColor.BLACK;
							final duration:Float = getValue(values, "duration", 1.0);
							final reverse:Bool = getValue(values, "reverse", false);
							FlxG.camera.fade(color, duration, reverse, onComplete);
						case "shake":
							final intensity:Float = getValue(values, "intensity", 0.05);
							final duration:Float = getValue(values, "duration", 0.15);
							final force:Bool = getValue(values, "force", true);
							FlxG.camera.shake(intensity, duration, onComplete, force);
					}
				case "dispatch_event":
					if (executor == null)
					{
						trace('Executor required for this action: $action.type');
						continue;
					}

					final eventName:String = getValue(values, "name");
					if (eventName == null)
						continue;
					final eventArgs:LogicState = getValue(values, "args");
					executor.onEvent(eventName, eventArgs);

				case "create_tween":
					if (executor == null)
					{
						trace('Executor required for this action: $action.type');
						continue;
					}

					final tweenName:String = getValue(values, "name");
					final tweenProps:Dynamic = getValue(values, "props");
					final duration:Null<Float> = getValue(values, "duration");

					if (tweenName == null || tweenProps == null || duration == null)
					{
						trace('Invalid arguments for create_tween: name, properties, and duration are required.');
						continue;
					}

					final tweenOptions:Dynamic = getValue(values, "options", {});
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

					final timerName:String = getValue(values, "name");
					final time:Null<Float> = getValue(values, "time");

					if (timerName == null || time == null)
					{
						if (timerName == null)
						{
							trace('Invalid arguments for create_timer: name is required.');
						}
						else if (time == null)
						{
							trace('Invalid arguments for create_timer: time is required.');
						}
						else
						{
							trace('Invalid arguments for create_timer: name and time are required.');
						}
						continue;
					}

					executor.timerManager.wait(timerName, time, onComplete);

				case "cancel_timer":
					if (executor == null)
					{
						trace('Executor required for this action: $action.type');
						continue;
					}
					final timerName:String = getValue(values, "name");
					if (timerName != null)
						executor.timerManager.remove(timerName);

				case "cancel_tween":
					if (executor == null)
					{
						trace('Executor required for this action: $action.type');
						continue;
					}
					final tweenName:String = getValue(values, "name");
					if (tweenName != null)
						executor.tweenManager.remove(tweenName);
				case "open_url":
					final url:String = getValue(values, "url");
					if (url != null)
						FlxG.openURL(url);
				case "exit_game":
					final code:Int = getValue(values, "code", 0);
					Sys.exit(code);
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
							final soundId:String = getValue(values, "sound");
							if (soundId != null) executor.music.load(soundId);
						case "music_play":
							executor.music.play();
						case "music_pause":
							executor.music.pause();
						case "music_stop":
							executor.music.stop();
						case "music_fade_in":
							final duration:Float = getValue(values, "duration", 1.0);
							final from:Null<Float> = getValue(values, "from");
							final to:Null<Float> = getValue(values, "to");
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
							final duration:Float = getValue(values, "duration", 1.0);
							final to:Null<Float> = getValue(values, "to");
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
					final tagToRemove:String = getValue(values, "tag");
					if (tagToRemove != null)
					{
						executor.removeListenersByTag(tagToRemove);
					}
				case "switch_scene":
					if (executor == null)
					{
						trace('Executor required for this action: $action.type');
						continue;
					}
					final sceneName:String = getValue(values, "scene");
					if (sceneName?.length > 0)
					{
						executor.switchScene(sceneName);
					}
					else
					{
						trace('ERROR: Scene name not provided for switch_scene action.');
					}
				default:
					trace('WARNING: Unknown action type: ${action.type}');
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

	private static inline function getValue<T>(values:Dynamic, name:String, ?defaultValue:T):T
	{
		return Reflect.hasField(values, name) ? Reflect.field(values, name) : defaultValue;
	}
}
