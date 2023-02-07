package music;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.util.FlxSort;
import states.PlayState;
import objects.character.Character;

// please place this somewhere more appropriate ty
class EventManager
{
	public var spawnedEvents:Array<String> = [];
	public var eventList:EventInfo = [];

	public function new(song:String, overrideEvents:Bool = false)
	{
		if (overrideEvents) // fancy term for "hardcode"
		{
			switch (song)
			{
				case 'bopeebo':
					{
						var beat:Int = 0;

						while (Conductor.crochet * beat <= FlxG.sound.music.length)
						{
							if (beat % 8 == 7)
								spawnEvent({strumTime: Conductor.crochet * beat, eventName: 'Play Animation', arguments: ['player', 'hey', '0']});

							beat += 8;
						}
					}
				case 'milf':
					{
						var beat = 168;

						while (beat < 200)
						{
							spawnEvent({
								eventName: 'Camera Beat',
								strumTime: Conductor.crochet * beat,
								arguments: ['world&spl-0.015', 'hud&spl-0.03']
							});

							beat++;
						}
					}
			}
		}

		var beat:Int = 4;

		if (Settings.getPref('camZoom', true))
		{
			while (Conductor.crochet * beat <= FlxG.sound.music.length)
			{
				if (beat % 4 == 0)
					spawnEvent({strumTime: Conductor.crochet * beat, eventName: 'Camera Beat', arguments: ['world&spl-0.015', 'hud&spl-0.03']});

				beat++;
			}
		}

		eventList.sort(function(f1, f2)
		{
			return FlxSort.byValues(FlxSort.ASCENDING, f1.strumTime, f2.strumTime);
		});
	}

	public function spawnEvent(event:EventData)
	{
		switch (event.eventName) {}

		if (!spawnedEvents.contains(event.eventName))
			spawnedEvents.push(event.eventName);

		eventList.push(event);

		eventList[eventList.indexOf(event)].id = eventList.indexOf(event);
	}

	public function triggerEvent(event:EventData)
	{
		var gameInstance:PlayState = PlayState.current;

		switch (event.eventName)
		{
			case 'Camera Beat':
				{
					var camMapping:Map<String, FlxCamera> = ['world' => gameInstance.gameCamera, 'hud' => gameInstance.hudCamera];
					for (args in event.arguments)
					{
						var split:Array<String> = args.split('&spl-');

						if (camMapping.exists(split[0]))
						{
							camMapping[split[0]].zoom += Math.isNaN(Std.parseFloat(split[1])) ? 0.03 : Std.parseFloat(split[1]);
							if (!camMapping[split[0]].attributes.exists('zoomLerping'))
							{
								camMapping[split[0]].attributes.set('zoomLerping', true);
								if (!camMapping[split[0]].attributes.exists('zoomLerpValue'))
									camMapping[split[0]].attributes.set('zoomLerpValue', 1.0);
							}
						}
					}
				}
			case 'Play Animation':
				{
					var charMapping:Map<String, Array<Character>> = [
						'player' => gameInstance.playerList,
						'opponent' => gameInstance.opponentList,
						'spectator' => gameInstance.spectatorList
					];

					var character:Character = null;

					if (charMapping.exists(event.arguments[0]))
						character = charMapping[event.arguments[0]][
							Std.int(Math.min(Std.parseInt(event.arguments[2]), charMapping[event.arguments[0]].length))
						];

					if (character != null)
					{
						character.playAnim(event.arguments[1], true);
						character.forceIdle = true;
					}
				}
			case 'Change Stage':
				{}
		}

		if (eventList.contains(event))
			eventList.splice(eventList.indexOf(event), 1);
	}
}

typedef EventInfo = Array<EventData>;

typedef EventData =
{
	@:optional var id:Int;
	var strumTime:Float;
	var eventName:String;
	var arguments:Array<Dynamic>;
}
