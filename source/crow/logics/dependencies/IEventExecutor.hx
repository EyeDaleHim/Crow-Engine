package crow.logics.dependencies;

import crow.ds.orderedmap.OrderedStringMap;
import crow.ecs.systems.BaseSystem;
import crow.ecs.managers.TimerManager;
import crow.ecs.managers.TweenManager;

interface IEventExecutor
{
    public var timerManager:TimerManager;
    public var tweenManager:TweenManager;

    public var nextScenes:Array<String>;

	public var logicState:LogicState;

    public var music:Music;

    public var soundInstances:Map<String, FlxSound>;

    public var entities:OrderedStringMap<Entity>;
    public var systems:Array<BaseSystem>;

    public function switchScene(sceneName:String):Bool;

    public function onEvent(eventName:String, ?localState:LogicState):Void;

	public function removeListenersByTag(tag:String):Void;
}