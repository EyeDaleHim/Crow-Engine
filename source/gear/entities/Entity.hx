package gear.entities;

import gear.assets.metadata.game.EntityMetadata;

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

			if (spriteMeta.scrollFactor != null)
				sprite.scrollFactor.set(spriteMeta.scrollFactor.x, spriteMeta.scrollFactor.y);

			if (spriteMeta.angle != null)
				sprite.angle = spriteMeta.angle;

			add(sprite);
			spritesMap.set(spriteMeta.name, sprite);
		}
	}

	override function destroy()
	{
		super.destroy();
		spritesMap = null;
	}
}
