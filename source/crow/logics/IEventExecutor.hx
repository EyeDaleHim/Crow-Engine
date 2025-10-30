package crow.logics;

import crow.entities.managers.TimerManager;
import crow.entities.managers.TweenManager;

interface IEventExecutor
{
    public var timerManager:TimerManager;
    public var tweenManager:TweenManager;

    public var nextScenes:Array<String>;

	public var logicState:Map<String, Dynamic>;

    public var music:Music;

    public function switchScene(sceneName:String):Bool;

    public function onEvent(eventName:String, ?args:Map<String, Dynamic>):Void;

	public function removeListenersByTag(tag:String):Void;
}