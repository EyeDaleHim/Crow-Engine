package crow.logics.dependencies;

import crow.entities.managers.TimerManager;
import crow.entities.managers.TweenManager;

interface IEventExecutor
{
    public var timerManager:TimerManager;
    public var tweenManager:TweenManager;

    public var nextScenes:Array<String>;

	public var logicState:LogicState;

    public var music:Music;

    public function switchScene(sceneName:String):Bool;

    public function onEvent(eventName:String, ?args:LogicState):Void;

	public function removeListenersByTag(tag:String):Void;
}