package gear.entities;

import gear.assets.metadata.game.EntityMetadata;
import flixel.util.FlxColor;
import gear.utils.ColorData;

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

	public function new(?x:Float = 0.0, ?y:Float = 0.0, inputFile:String)
	{
		final jsonContent = FlxG.assets.getTextUnsafe(Path.join(['entities', '$inputFile.json']));
		final metadata:EntityMetadata = Json.parse(JsonComment.removeComments(jsonContent));

		super(x, y);

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
				case ANIMATED_TEXT:
					createAnimatedText(object.data);
				case NESTED_ENTITY:
					createNestedEntity(object.data);
			}
		}
	}

	override function destroy()
	{
		super.destroy();
		spritesMap = null;
	}

	private function createSprite(spriteMeta:SpriteObjectData, ?parentContainer:FlxSpriteContainer):Void
	{
		final sprite = new FlxSprite();

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
									sprite.animation.addByIndices(anim.name, anim.prefix, anim.indices, "", anim.frameRate, anim.loop);
								}
								else
								{
									sprite.animation.addByPrefix(anim.name, anim.prefix, anim.frameRate, anim.loop);
								}
							}

							if (spriteMeta.startingAnimation != null)
							{
								sprite.animation.play(spriteMeta.startingAnimation);
							}
						}
					}
				case "graphic":
					trace(spriteMeta.method);
					trace(spriteMeta.method.color);
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
			sprite.scale.set(spriteMeta.scale.x ?? 1.0, spriteMeta.scale.y ?? 1.0);

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

		if (textMeta.fieldWidth != null)
		{
			if (textMeta.fieldWidth == -1)
				textObj.fieldWidth = FlxG.width;
			else
				textObj.fieldWidth = textMeta.fieldWidth;
		}

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
