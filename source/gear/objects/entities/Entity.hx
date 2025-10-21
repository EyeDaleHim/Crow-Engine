package gear.objects.entities;

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

	public function new(inputFile:String)
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

			if (listener.condition != null)
			{
				// Condition: beat_modulo
				if (listener.condition.type == "beat_modulo")
				{
					if (beat == null || listener.condition.value == null || beat % listener.condition.value[0] != listener.condition.value[1])
						continue;
				}

				// Condition: checkState
				if (listener.condition.checkState != null)
				{
					var stateVar = listener.condition.checkState;
					var expected = true;
					if (stateVar.startsWith("!"))
					{
						stateVar = stateVar.substring(1);
						expected = false;
					}

					if (state.get(stateVar) != expected)
						continue;
				}
			}

			// All conditions passed, execute actions
			for (action in listener.actions)
			{
				// Action: play_animation
				if (action.type == "play_animation" && action.sprite != null && action.values != null)
				{
					final sprite = spritesMap.get(action.sprite);
					if (sprite != null)
					{
						final animName = action.values[0];
						final force = action.force == true;
						sprite.animation.play(animName, force);
					}
				}

				// Action: stateChange
				if (action.stateChange != null && action.values != null)
				{
					final stateVar = action.values[0];
					switch (action.stateChange)
					{
						case "toggle_bool":
							if (state.exists(stateVar) && Std.isOfType(state.get(stateVar), Bool))
								state.set(stateVar, !state.get(stateVar));
					}
				}
			}
		}
	}
}