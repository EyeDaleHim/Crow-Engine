package crow.ecs.entities;

import crow.ecs.components.ModelComponent;
import crow.assets.metadata.game.EntityMetadata;
import flixel.util.FlxColor;
import crow.utils.ColorData;


/**
 * The visual representation of an Entity.
 * 
 * This class is responsible for creating and managing all visual elements
 * (sprites, text, nested entities) based on an Entity's metadata. It is
 * separated from the Entity class to enforce a separation of concerns, where
 * Entity handles data and logic, and Model handles the view.
 */
class Model extends FlxSpriteContainer
{
	/**
	 * A map of sprites belonging to this entity, accessible by name.
	 */
	public var spritesMap:Map<String, FlxSprite> = [];

	/**
	 * A map of sprites that contain the reference to their metadata, accessible by name.
	 */
	public var membersMetricsMap:Map<String, Dynamic> = [];

	public function new(?x:Float = 0, ?y:Float = 0)
	{
		super(x, y);
	}

	public function init(entity:Entity)
	{
		for (object in entity.metadata.objects)
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
	}

	override function destroy()
	{
		super.destroy();
		spritesMap = null;
		membersMetricsMap = null;
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
		final nestedEntity = new Entity(entityMeta.position?.x ?? 0.0, entityMeta.position?.y ?? 0.0, entityMeta.entityFile);
		final nestedModel = (cast nestedEntity.getComponentByType(ModelComponent):ModelComponent).model;
		membersMetricsMap.set(entityMeta.name, entityMeta);

		if (entityMeta.scale != null)
			nestedModel.scale.set(entityMeta.scale.x ?? 1.0, entityMeta.scale.y ?? 1.0);

		if (entityMeta.scrollFactor != null)
			nestedModel.scrollFactor.set(entityMeta.scrollFactor.x ?? 1.0, entityMeta.scrollFactor.y ?? 1.0);

		add(nestedModel);
	}

	public function updateLayoutTargetPosition(layoutTarget:FlxObject, layoutMeta:LayoutTargetData):Void
	{
		if (layoutTarget == null || layoutMeta == null)
			return;

		final offsetX = layoutMeta.position?.x ?? 0.0;
		final offsetY = layoutMeta.position?.y ?? 0.0;

		this.x = layoutTarget.x + offsetX;
		this.y = layoutTarget.y + offsetY;

		if (layoutMeta.relativeToCenter?.x == true)
		{
			this.x = layoutTarget.x + (layoutTarget.width / 2) - (this.width / 2);
		}
		if (layoutMeta.relativeToCenter?.y == true)
		{
			this.y = layoutTarget.y + (layoutTarget.height / 2) - (this.height / 2);
		}
	}
}