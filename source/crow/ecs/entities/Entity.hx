package crow.ecs.entities;

import crow.ecs.components.PositionComponent;
import crow.ecs.components.BaseComponent;
import crow.ecs.components.ModelComponent;
import crow.ecs.components.BaseComponent.ComponentTrait;
import crow.ecs.components.BaseComponent.IComponent;
import crow.ecs.managers.ComponentTable;
import crow.logics.dependencies.LogicState;
import crow.assets.metadata.game.EntityMetadata;
import flixel.util.FlxColor;
import crow.utils.ColorData;

using Lambda;

/**
 * A data-driven game object that can be animated and controlled through JSON metadata.
 * It acts as a logical container for components and manages its own state and event-based logic.
 */
class Entity extends FlxObject implements IComponentActor
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
	public var logicState:LogicState = new LogicState();

	public function new(?x:Float = 0.0, ?y:Float = 0.0, inputFile:String, ?overrideMetadata:EntityMetadata, ?initialState:Dynamic)
	{
		super();

		final metadata:EntityMetadata = Main.assets.json(Path.join(['entities', inputFile]));
		if (metadata == null)
		{
			trace('Error: Entity metadata file not found or empty: $inputFile');
			this.entityName = 'failed_to_load_entity_$ID';
			return;
		}

		addComponent(new PositionComponent(this, x, y));
		addComponent(new ModelComponent(this));

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
		final model = getModel();
		if (model != null)
		{
			model.x = x;
			model.y = y;
		}

		if (initialState != null)
		{
			for (field in Reflect.fields(initialState))
			{
				logicState.set(field, Reflect.field(initialState, field));
			}
		}

		if (metadata.visible != null)
		{
			model.visible = this.visible = metadata.visible;
		}

		if (metadata.layoutTarget != null)
		{
			this.layoutTarget = new FlxObject();
			this.layoutTarget.debugBoundingBoxColor = FlxColor.PURPLE;
			if (metadata.layoutTarget.position != null)
			{
				if (model != null)
				{
					this.layoutTarget.x = model.x + (metadata.layoutTarget.position.x ?? 0);
					this.layoutTarget.y = model.y + (metadata.layoutTarget.position.y ?? 0);
				}
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

		// After all components are added, initialize the model
		model.init(this);
		_isInit = true;
	}

	override function initVars():Void
	{
		// Don't initialize FlxObject initVars()
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

	/**
	 * Gets the model from the ModelComponent, if it exists.
	 * @return The model. Can be null.
	 */
	public function getModel():Model
	{
		final modelComp = getComponentByType(ModelComponent);
		if (modelComp != null)
		{
			return (cast modelComp : ModelComponent).model;
		}
		return null;
	}

	override function update(elapsed:Float)
	{
		#if FLX_DEBUG
		FlxBasic.visibleCount++;
		#end

		final model = getModel();
		if (model != null)
		{
			// TODO: Don't call every frame
			if (layoutTarget != null && metadata.layoutTarget != null)
			{
				getModel().updateLayoutTargetPosition(layoutTarget, metadata.layoutTarget);
			}

			model.update(elapsed);
		}
	}

	override function draw()
	{
		if (layoutTarget != null && exists && alive && visible)
		{
			layoutTarget.draw();
		}

		final model = getModel();
		if (model != null)
		{
			model.visible = this.visible;
			if (model.exists && model.alive && model.visible)
			{
				model.draw();
			}
		}
	}

	override function destroy()
	{
		if (layoutTarget != null)
		{
			layoutTarget.destroy();
			layoutTarget = null;
		}

		final model = getModel();
		if (model != null)
		{
			model.destroy();
		}

		super.destroy();
	}

	// prevent dumb crash
	private var _isInit:Bool = false;

	// maybe have an EntitySystem or the state itself to have the
	// model sync with this entity's data? 

	override function set_x(value:Float):Float
	{
		if (!_isInit)
			return super.set_x(value);

		throw "Use the model's PositionComponent instead";
	}

	override function set_y(value:Float):Float
	{
		if (!_isInit)
			return super.set_y(value);

		throw "Use the model's PositionComponent instead";
	}
}
