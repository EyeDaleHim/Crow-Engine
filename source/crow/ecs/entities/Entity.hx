package crow.ecs.entities;

import crow.ecs.components.BaseComponent;
import crow.ecs.components.BaseComponent.ComponentTrait;
import crow.ecs.components.BaseComponent.IComponent;
import crow.ecs.components.PositionComponent;
import crow.ecs.managers.ComponentTable;
import crow.logics.dependencies.LogicState;
import crow.assets.metadata.game.EntityMetadata;
import flixel.util.FlxColor;
import crow.utils.ColorData;

using Lambda;

/**
 * A data-driven game object that can be animated and controlled through JSON metadata.
 * It acts as a container for sprites and manages its own state and event-based logic.
 */
class Entity extends FlxSpriteContainer implements IComponentActor
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
	 * Components attached to this entity.
	 */
	public var components:Array<IComponent> = [];

	/**
	 * A list of tags associated with this entity.
	 * Tags can be used for filtering and targeting entities in logic.
	 */
	public var tags:Array<String> = [];

	/**
	 * The internal state for the entity's logic.
	 */
	public var logicState:LogicState = new LogicState("entity");

	public function new(?x:Float = 0.0, ?y:Float = 0.0, inputFile:String, ?overrideMetadata:EntityMetadata, ?initialState:Dynamic)
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

		if (initialState != null)
		{
			for (field in Reflect.fields(initialState))
			{
				logicState.set(field, Reflect.field(initialState, field));
			}
		}

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

		if (metadata.components != null)
		{
			for (componentMeta in metadata.components)
			{
				var component = ComponentTable.fromMetadata(componentMeta, this);
				addComponent(component);
			}
		}
	}

	/**
	 * Gets the component of this type. If there are multiple components 
	 * of the same type, the first one is used.
	 * 
	 * @return The component. Can be null.
	 */
	public function getComponentByType(type:Class<IComponent>):IComponent
	{
		for (component in components)
		{
			if (Std.isOfType(component, type))
			{
				return component;
			}
		}
		return null;
	}

	/**
	 * Gets all components of this type.
	 * 
	 * @return An array of components. Can be empty.
	 */
	public function getComponentsByType(type:Class<IComponent>, ?filter:IComponent->Bool):Array<IComponent>
	{
		var result:Array<IComponent> = [];
		for (component in components)
		{
			if (Std.isOfType(component, type))
			{
				result.push(cast component);
			}
		}
		return result;
	}

	/**
	 * Gets the component of this name. If there are multiple components 
	 * of the same name, the first one is used.
	 * 
	 * @return The component. Can be null.
	 */
	public function getComponentByName(name:String):IComponent
	{
		for (component in components)
		{
			if (component.name == name)
			{
				return component;
			}
		}
		return null;
	}

	/**
	 * Gets all components of this name.
	 * 
	 * @return An array of components. Can be empty.
	 */
	public function getComponentsByName(name:String, ?filter:IComponent->Bool):Array<IComponent>
	{
		var result:Array<IComponent> = components.filter((component) ->
		{
			return component.name == name && (filter == null || filter(component));
		});

		return result;
	}

	/**
	 * Adds a component to this entity.
	 * 
	 * If the component has the `Single` trait, and a component of the same type already exists,
	 * the new component will not be added.
	 * 
	 * If the component has the `Replace` trait, and a component of the same type already exists,
	 * the existing component will be removed before the new one is added.
	 * 
	 * If the component has the `Multi` trait, it will always be added.
	 * 
	 * @param component The component to add.
	 */
	public function addComponent(component:IComponent):Void
	{
		final trait = component.trait;

		if (trait.has(ComponentTrait.Single) || trait.has(ComponentTrait.Replace))
		{
			final type = Type.getClass(component);
			final existing = getComponentByType(type);

			if (existing != null)
			{
				if (trait.has(ComponentTrait.Single))
				{
					// Don't add, as a component of this type already exists.
					return;
				}
				else if (trait.has(ComponentTrait.Replace))
				{
					// Remove the existing component before adding the new one.
					removeComponent(existing);
				}
				component.destroy();
				return;
			}
		}

		this.components.push(component);
	}

	/**
	 * Adds multiple components to this entity.
	 * @param components The components to add.
	 * @param filter The optional filter to apply. If a component passes the filter, it will be added.
	 */
	public function addComponents(components:Array<IComponent>, ?filter:IComponent->Bool):Void
	{
		final filtered = filter == null ? components : components.filter(filter);

		for (component in filtered)
		{
			addComponent(component);
		}
	}

	/**
	 * Removes a component from this entity.
	 * @param component The component to remove.
	 */
	public function removeComponent(component:IComponent):Void
	{
		if (component == null)
		{
			return;
		}

		if (this.components.indexOf(component) != -1)
		{
			this.components.remove(component);
			component.entity = null; // Detach from entity
		}
	}

	/**
	 * Removes multiple components from this entity. 
	 * @param components The components to remove.
	 * @param filter The optional filter to apply to the components. If a component passes the filter, it will be removed.
	 */
	public function removeComponents(components:Array<IComponent>, ?filter:IComponent->Bool):Void
	{
		final filtered = filter == null ? components : components.filter(filter);

		for (component in filtered)
		{
			removeComponent(component);
		}
	}

	public function removeComponentsByType(type:Class<IComponent>, ?filter:IComponent->Bool):Void
	{
		final filtered = filter == null ? components : components.filter(filter);

		for (component in filtered)
		{
			if (Std.isOfType(component, type))
			{
				removeComponent(component);
			}
		}
	}

	public function updateLayoutTargetPosition():Void
	{
		if (layoutTarget == null)
			return;

		final layoutMeta = metadata.layoutTarget;
		if (layoutMeta == null)
			return;

		final offsetX = layoutMeta.position?.x ?? 0.0;
		final offsetY = layoutMeta.position?.y ?? 0.0;

		this.x = layoutTarget.x + offsetX;
		this.y = layoutTarget.y + offsetY;

		if (layoutMeta.relativeToCenter?.x == true)
			this.x = layoutTarget.x + (layoutTarget.width / 2) - (this.width / 2);
		if (layoutMeta.relativeToCenter?.y == true)
			this.y = layoutTarget.y + (layoutTarget.height / 2) - (this.height / 2);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// TODO: Don't call every frame
		updateLayoutTargetPosition();
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
