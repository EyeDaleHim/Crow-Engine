package gear.entities;

import gear.assets.metadata.game.EntityMetadata;
import flixel.util.FlxColor;

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

		for (spriteMeta in metadata.sprites)
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
						final color:FlxColor = (spriteMeta.method.color != null) ? spriteMeta.method.color : FlxColor.MAGENTA;
						sprite.makeGraphic(spriteMeta.method.width ?? 1, spriteMeta.method.height ?? 1, color);
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
