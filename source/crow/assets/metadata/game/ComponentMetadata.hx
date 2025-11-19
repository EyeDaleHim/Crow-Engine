package crow.assets.metadata.game;

typedef ComponentMetadata =
{
    /**
     * The name of the component to use.
     * 
     * If the component is not found, the component will default to "BaseComponent" which
     * by default only holds a component trait.
     */
    var name:String;

    /**
     * The id for the component to use, for easier identification.
     * 
     * Can be left blank to generate a random UUID.
     */
    var ?id:String;

    /**
     * The data for the component.
     */
    var struct:Dynamic;
};