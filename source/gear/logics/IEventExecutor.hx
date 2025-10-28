package gear.logics;

import gear.entities.managers.TimerManager;
import gear.entities.managers.TweenManager;

interface IEventExecutor
{
    public var timerManager:TimerManager;
    public var tweenManager:TweenManager;

    public function onEvent(eventName:String, ?args:Map<String, Dynamic>):Void;
}