# List
* TODO: Use DynamicAccess for LogicState
    *  There are lots of reflections happening in our code, but DynamicAccess can abstract some of that.
* TODO: `Entity.hx` needs to be a simple container for data in general, as part of the ECS drive. Not just the game sprites.
    * This way, we can allow for things like cameras to be modified like an entity and apply components to it.
    * A big caveat is that this could make the line between what is an entity and what isn't, is the save data also an entity?
    * It's important to make clear and concrete distinctions regarding what counts an entity.