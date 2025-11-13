package crow.logics.dependencies;

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

    public var entities:Map<String, Entity>;

    public function switchScene(sceneName:String):Bool;

    public function onEvent(eventName:String, ?localState:LogicState):Void;

	public function removeListenersByTag(tag:String):Void;
}