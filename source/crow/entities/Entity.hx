package crow.entities;

import crow.logics.LogicState;
import crow.assets.metadata.game.EntityMetadata;
import flixel.util.FlxColor;
import crow.utils.ColorData;

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
	 * The metadata for this entity.
	 */
	public var metadata:EntityMetadata;

	/**
	 * The internal object for layouts to use as reference, if applicable.
	 * 
	 * Layouts will use this for positioning, size, and alignment, instead of 
	 * the entity's own properties. The entity itself will be locked to this object, 
	 * depending on the metadata.
	 * 
	 * This is useful if the entity has a lot of changing parts which doesn't play
	 * well with layouts that are usually static.
	 */
	public var layoutTarget:FlxObject;

	/**
	 * A map of sprites belonging to this entity, accessible by name.
	 */
	public var spritesMap:Map<String, FlxSprite> = [];

	/**
	 * A map of sprites that contain the reference to their metadata, accessible by name.
	 */
	public var membersMetricsMap:Map<String, Dynamic> = [];

	/**
	 * A list of tags associated with this entity.
	 * Tags can be used for filtering and targeting entities in logic.
	 */
	public var tags:Array<String> = [];

	/**
	 * The internal state for the entity's logic.
	 */
	public var logicState:LogicState = new LogicState();

	public function new(?x:Float = 0.0, ?y:Float = 0.0, inputFile:String, ?overrideMetadata:EntityMetadata)
	{
		super(x, y);

		final metadata:EntityMetadata = Main.assets.json(Path.join(['entities', inputFile]));
		if (metadata == null)
		{
			trace('Error: Entity metadata file not found or empty: $inputFile');
			this.entityName = 'failed_to_load_entity_$ID';
			return;
		}

		this.metadata = metadata;
		if (overrideMetadata != null)
		{
			final fields = Reflect.fields(overrideMetadata);
			for (field in fields)
			{
				final value = Reflect.field(overrideMetadata, field);
				if (value != null)
					Reflect.setField(this.metadata, field, value);
			}
		}

		this.entityName = metadata.name;

		if (metadata.visible != null)
		{
			this.visible = metadata.visible;
		}

		for (object in metadata.objects)
		{
			switch (object.type)
			{
				case SPRITE:
					createSprite(object.data);
				case TEXT:
					// TODO: Handle text objects
				case ANIMATED_TEXT:
					createAnimatedText(object.data);
				case NESTED_ENTITY:
					createNestedEntity(object.data);
			}
		}

		if (metadata.layoutTarget != null)
		{
			this.layoutTarget = new FlxObject();
			this.layoutTarget.debugBoundingBoxColor = FlxColor.PURPLE;
			if (metadata.layoutTarget.position != null)
			{
				if (metadata.layoutTarget.position.x != null)
					this.layoutTarget.x = this.x + metadata.layoutTarget.position.x;
				if (metadata.layoutTarget.position.y != null)
					this.layoutTarget.y = this.y + metadata.layoutTarget.position.y;
			}
			if (metadata.layoutTarget.width != null)
				this.layoutTarget.width = metadata.layoutTarget.width;
			if (metadata.layoutTarget.height != null)
				this.layoutTarget.height = metadata.layoutTarget.height;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (layoutTarget != null)
		{
			if (metadata.layoutTarget.relativeToCenter != null)
			{
				if (metadata.layoutTarget.relativeToCenter.x == true)
					this.x = layoutTarget.x + (layoutTarget.width / 2) - (this.width / 2);
				else if (metadata.layoutTarget.position.x != null)
					this.x = layoutTarget.x;

				if (metadata.layoutTarget.relativeToCenter.y == true)
					this.y = layoutTarget.y + (layoutTarget.height / 2) - (this.height / 2);
				else if (metadata.layoutTarget.position.y != null)
					this.y = layoutTarget.y;
			}
			else if (metadata.layoutTarget.position != null)
			{
				if (metadata.layoutTarget.position.x != null)
					this.x = metadata.layoutTarget.position.x + metadata.layoutTarget.position.x;
				if (metadata.layoutTarget.position.y != null)
					this.y = metadata.layoutTarget.position.y + metadata.layoutTarget.position.y;
			}
		}
	}

	override function draw()
	{
		super.draw();

		if (layoutTarget != null && exists && alive && visible)
		{
			layoutTarget.draw();
		}
	}

	override function destroy()
	{
		if (layoutTarget != null)
		{
			layoutTarget.destroy();
			layoutTarget = null;
		}

		super.destroy();
		spritesMap = null;
	}

	private function createSprite(spriteMeta:SpriteObjectData, ?parentContainer:FlxSpriteContainer):Void
	{
		final sprite = new FlxSprite();
		membersMetricsMap.set(spriteMeta.name, spriteMeta);

		if (spriteMeta.method != null)
		{
			switch (spriteMeta.method.type)
			{
				case "simple":
					if (spriteMeta.method.path != null)
						sprite.loadGraphic(spriteMeta.method.path);

				case "atlas":
					if (spriteMeta.method.path != null)
					{
						final frames = Main.assets.frames(spriteMeta.method.path);
						sprite.frames = frames;

						if (spriteMeta.animations != null)
						{
							for (anim in spriteMeta.animations)
							{
								if (anim.indices != null)
								{
									sprite.animation.addByIndices(anim.name, anim.prefix, anim.indices, "", anim.frameRate, anim.loop ?? true);
								}
								else
								{
									sprite.animation.addByPrefix(anim.name, anim.prefix, anim.frameRate, anim.loop ?? true);
								}
							}

							if (spriteMeta.startingAnimation != null)
							{
								sprite.animation.play(spriteMeta.startingAnimation);
								sprite.updateHitbox();
							}
						}
					}
				case "graphic":
					final color:FlxColor = ColorData.fromDynamic(spriteMeta.method.color) ?? FlxColor.WHITE;

					var width = spriteMeta.method.width ?? 1;
					if (width == -1)
						width = FlxG.width;
					var height = spriteMeta.method.height ?? 1;
					if (height == -1)
						height = FlxG.height;
					sprite.makeGraphic(width, height, color);
			}
		}

		if (spriteMeta.position != null)
		{
			sprite.x = spriteMeta.position.x ?? 0.0;
			sprite.y = spriteMeta.position.y ?? 0.0;
		}

		if (spriteMeta.scale != null)
		{
			sprite.scale.set(spriteMeta.scale.x ?? 1.0, spriteMeta.scale.y ?? 1.0);
			sprite.updateHitbox();
		}

		if (spriteMeta.scrollFactor != null)
			sprite.scrollFactor.set(spriteMeta.scrollFactor.x ?? 1.0, spriteMeta.scrollFactor.y ?? 1.0);

		if (spriteMeta.angle != null)
			sprite.angle = spriteMeta.angle ?? 1.0;

		(parentContainer ?? this).add(sprite);
		spritesMap.set(spriteMeta.name, sprite);
	}

	private function createAnimatedText(textMeta:AnimatedTextObjectData, ?parentContainer:FlxSpriteContainer):Void
	{
		final textObj = new AnimatedText(textMeta.position?.x ?? 0.0, textMeta.position?.y ?? 0.0, textMeta.font, textMeta.text);
		membersMetricsMap.set(textMeta.name, textMeta);

		if (textMeta.fieldWidth != null)
			textObj.fieldWidth = textMeta.fieldWidth;

		if (textMeta.alignment != null)
			textObj.alignment = textMeta.alignment;

		if (textMeta.scrollFactor != null)
			textObj.scrollFactor.set(textMeta.scrollFactor.x ?? 1.0, textMeta.scrollFactor.y ?? 1.0);

		(parentContainer ?? this).add(textObj);
		spritesMap.set(textMeta.name, textObj);
	}

	private function createNestedEntity(entityMeta:NestedEntityObjectData):Void
	{
		final nestedEntity = new Entity(0, 0, entityMeta.entityFile);
		membersMetricsMap.set(entityMeta.name, entityMeta);

		if (entityMeta.position != null)
		{
			nestedEntity.x = entityMeta.position.x ?? 0.0;
			nestedEntity.y = entityMeta.position.y ?? 0.0;
		}

		if (entityMeta.scale != null)
			nestedEntity.scale.set(entityMeta.scale.x ?? 1.0, entityMeta.scale.y ?? 1.0);

		if (entityMeta.scrollFactor != null)
			nestedEntity.scrollFactor.set(entityMeta.scrollFactor.x ?? 1.0, entityMeta.scrollFactor.y ?? 1.0);

		add(nestedEntity);

		// Add the nested entity's sprites to the parent's map for easy access.
		for (spriteName in nestedEntity.spritesMap.keys())
		{
			spritesMap.set(spriteName, nestedEntity.spritesMap.get(spriteName));
		}
	}
}
