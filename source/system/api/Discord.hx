package system.api;

import lime.app.Application;
#if cpp
import hxdiscord_rpc.Discord as DiscordRPC;
import hxdiscord_rpc.Types;
import sys.thread.Thread;
#end

class Discord
{
	private static var _revokeLoop:Bool = false;

	public static function init():Void
	{
		#if cpp
		var handlers:DiscordEventHandlers = DiscordEventHandlers.create();
		handlers.ready = cpp.Function.fromStaticFunction(onReady);
		handlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		handlers.errored = cpp.Function.fromStaticFunction(onError);
		DiscordRPC.Initialize("866034469772591104", cpp.RawPointer.addressOf(handlers), 1, null);

		// Daemon Thread
		Thread.create(function()
		{
			while (true)
			{
				if (_revokeLoop)
					break;

				#if DISCORD_DISABLE_IO_THREAD
				DiscordRPC.UpdateConnection();
				#end
				DiscordRPC.RunCallbacks();
			}
		});
		

		Application.current.onExit.add(function(exitCode)
		{
			DiscordRPC.Shutdown();
		}, true, 4000);
		#end
	}

	#if cpp
	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		var requestPtr:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(request).ptr;

		if (Std.parseInt(cast(requestPtr.discriminator, String)) != 0)
			Sys.println('(DiscordRPC) Connected to User (${cast (requestPtr.username, String)}#${cast (requestPtr.discriminator, String)})');
		else
			Sys.println('(DiscordRPC) Connected to User (${cast (requestPtr.username, String)})');

		var discordPresence:DiscordRichPresence = DiscordRichPresence.create();
		discordPresence.details = "Menu";
		discordPresence.largeImageKey = "icon512";
		DiscordRPC.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));

		_revokeLoop = true;
	}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		Sys.println('DiscordRPC: Disconnected ($errorCode: ${cast (message, String)})');
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		Sys.println('DiscordRPC: Error ($errorCode: ${cast (message, String)})');
	}
	#end
}
