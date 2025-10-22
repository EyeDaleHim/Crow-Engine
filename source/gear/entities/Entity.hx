package gear.entities;

import gear.assets.metadata.EntityMetadata;

/**
 * A data-driven game object that can be animated and controlled through JSON metadata.
 * It acts as a container for sprites and manages its own state and event-based logic.
 */
class Entity extends FlxSpriteContainer
{
	/**
	 * The name of this entity, from metadata.
	 */
	public var entityName:String;

	/**
	 * A map of sprites belonging to this entity, accessible by name.
	 */
	public var spritesMap:Map<String, FlxSprite> = [];

	/**
	 * The internal state of the entity, which can be modified by listeners.
	 */
	public var state:Map<String, Dynamic> = [];

	private var _listeners:Array<EntityListenerMetadata> = [];

	public function new(?x:Float = 0.0, ?y:Float = 0.0, inputFile:String)
	{
		final jsonContent = FlxG.assets.getTextUnsafe(Path.join(['entities', '$inputFile.json']));
		final metadata:EntityMetadata = Json.parse(jsonContent);

		super(metadata.position.x, metadata.position.y);

		this.entityName = metadata.name;

		if (metadata.initialState != null) // If initialState is provided in JSON
		{
			// Manually populate the state map from the dynamic object
			for (key in Reflect.fields(metadata.initialState))
				this.state.set(key, Reflect.field(metadata.initialState, key));
		}

		if (metadata.listeners != null)
			this._listeners = metadata.listeners;

		for (spriteMeta in metadata.sprites)
		{
			final sprite = new FlxSprite();
			if (spriteMeta.usingAtlas == true)
			{
				final frames = Main.assets.frames(spriteMeta.assetPath);
				sprite.frames = frames;

				if (spriteMeta.animations != null)
				{
					for (anim in spriteMeta.animations)
					{
						if (anim.indices != null)
						{
							sprite.animation.addByIndices(anim.name, anim.prefix, anim.indices, "", anim.frameRate, anim.loop);
						}
						else
						{
							sprite.animation.addByPrefix(anim.name, anim.prefix, anim.frameRate, anim.loop);
						}
					}
				}
			}
			else
			{
				sprite.loadGraphic(spriteMeta.assetPath);
			}

			sprite.x = spriteMeta.position.x;
			sprite.y = spriteMeta.position.y;

			if (spriteMeta.scale != null)
				sprite.scale.set(spriteMeta.scale.x, spriteMeta.scale.y);

			if (spriteMeta.angle != null)
				sprite.angle = spriteMeta.angle;

			add(sprite);
			spritesMap.set(spriteMeta.name, sprite);
		}

		onEvent("create");
	}

	override function destroy()
	{
		super.destroy();
		spritesMap = null;
		state = null;
		_listeners = null;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		onEvent("update");
	}

	/**
	 * Triggers actions for any listeners associated with the given event.
	 * @param eventName The name of the event to trigger (e.g., "beat", "update").
	 * @param beat The current beat number, if relevant for the event.
	 */
	public function onEvent(eventName:String, ?beat:Int):Void
	{
		for (listener in _listeners)
		{
			if (listener.event != eventName)
				continue;

			// If a beat is provided, temporarily add it to the state for evaluation.
			if (beat != null)
				state.set("_beat", beat);

			// Evaluate the condition using the new PredicateEvaluator
			final conditionMet = PredicateEvaluator.evaluate(listener.condition, this.state);

			// Clean up the temporary state variable.
			if (beat != null)
				state.remove("_beat");

			if (!conditionMet)
				continue;

			// All conditions passed, execute actions
			for (action in listener.actions)
			{
				switch (action.type)
				{
					case "play_animation":
						if (action.sprite != null && action.values != null)
						{
							final sprite = spritesMap.get(action.sprite);
							if (sprite != null)
							{
								final animName = action.values[0];
								final force = action.force == true;
								sprite.animation.play(animName, force);
							}
						}
					case "state_change":
						if (action.stateChange != null)
						{
							final change = action.stateChange;
							switch (change.changeType)
							{
								case "SET":
									state.set(change.stateKey, change.value);
								case "INCREMENT":
									if (state.exists(change.stateKey))
										state.set(change.stateKey, state.get(change.stateKey) + change.value);
								case "TOGGLE":
									if (state.exists(change.stateKey) && Std.isOfType(state.get(change.stateKey), Bool))
										state.set(change.stateKey, !state.get(change.stateKey));
								// "CALL_SYSTEM_FUNCTION" would be implemented here if needed
								default: // Do nothing for unknown change types
							}
						}
				}
			}
		}
	}
}
