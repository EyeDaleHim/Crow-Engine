package gear.assets;

import haxe.CallStack;
import flixel.system.frontEnds.AssetFrontEnd;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;
import gear.assets.AssetHistory;
import gear.assets.AssetCache;
import gear.assets.AssetPaths;

class Assets
{
	public static var history:Array<AssetHistory> = [];
	public static var cache:AssetCache = new AssetCache();
	public static var contexts:Array<AssetContext> = [];

	private static function getCallerClassName():String
	{
		var stack = CallStack.callStack();

		function getClassName(item:StackItem):String
		{
			switch (item)
			{
				case FilePos(s, _, _, _):
					return getClassName(s);
				case Module(m):
					return m;
				case Method(className, methodName):
					return className;
				default:
					return null;
			}
		}

		// Iterate through the stack to find the first class outside of the assets backend.
		for (item in stack)
		{
			final className = getClassName(item);
			if (className != null
				&& !StringTools.startsWith(className, 'flixel')
				&& !StringTools.startsWith(className, "gear.assets.Assets")
				&& !StringTools.startsWith(className, "gear.assets.AssetHistory"))
			{
				return className;
			}
		}

		return "unknown";
	}

	public static function init():Void
	{
		cache.enabled = true;
		final assets = FlxG.assets;

		final oldExists = assets.exists;
		assets.exists = (id, ?type) ->
		{
			if (StringTools.startsWith(id, "flixel/") || StringTools.contains(id, ':'))
			{
				return oldExists(id, type);
			}

			#if FLX_DEFAULT_SOUND_EXT
			// add file extension
			if (type == SOUND)
			{
				id = assets.addSoundExt(id);
			}
			#end

			return exists(AssetPaths.from(id, type));
		};

		final oldLocal = assets.isLocal;
		assets.isLocal = (id, ?type, cache = true) ->
		{
			if (StringTools.startsWith(id, "flixel/") || StringTools.contains(id, ':'))
			{
				return oldLocal(id, type, cache);
			}

			#if FLX_DEFAULT_SOUND_EXT
			// add file extension
			if (type == SOUND)
			{
				id = addSoundExt(id);
			}
			#end

			return true;
		};

		final oldGet = assets.getAssetUnsafe;
		assets.getAssetUnsafe = (id, type, cache = true) ->
		{
			if (AssetContext.dirtyContexts)
			{
				var orphanedAssets:Array<String> = [];
				@:privateAccess
				for (assetId in Assets.cache._cache.keys())
				{
					var foundInContext:Bool = false;
					for (context in contexts)
					{
						if (context.findAsset(assetId))
						{
							foundInContext = true;
							break;
						}
					}
					if (!foundInContext)
					{
						orphanedAssets.push(assetId);
					}
				}

				for (orphanedId in orphanedAssets)
				{
					Assets.cache.remove(orphanedId);
				}
				AssetContext.dirtyContexts = false;
			}

			if (StringTools.startsWith(id, "flixel/") || StringTools.contains(id, ':'))
			{
				return oldGet(id, type, cache);
			}

			final canUseCache = cache && Assets.cache.enabled;
			final path = AssetPaths.from(id, type);

			if (canUseCache && Assets.cache.has(id))
			{
				pushHistory(CACHE_FETCH, type, path);
				return Assets.cache.get(id);
			}

			final asset:Any = switch type
			{
				case TEXT:
					var textAsset:String = null;
					#if ASSETS_PACKAGING
					textAsset = Main.bundle.getString(AssetPaths.from(id, type));
					#else
					textAsset = sys.io.File.getContent(AssetPaths.from(id, type));
					#end

					pushHistory(textAsset != null ? IO_SUCCESS : FAILURE, TEXT, AssetPaths.from(id, type));
					return textAsset;
				case BINARY:
					var binaryAsset:haxe.io.Bytes = null;
					#if ASSETS_PACKAGING
					binaryAsset = Main.bundle.getBytes(path);
					#else
					binaryAsset = sys.io.File.getBytes(path);
					#end
					pushHistory(binaryAsset != null ? IO_SUCCESS : FAILURE, BINARY, path);
					return binaryAsset;

				// Get asset and set cache
				case IMAGE:
					var bitmap:BitmapData = null;
					#if ASSETS_PACKAGING
					var bytes = Main.bundle.getBytes(path);
					if (bytes != null)
						bitmap = BitmapData.fromBytes(bytes);
					#else
					try
					{
						bitmap = BitmapData.fromFile(path);
					}
					catch (e:Dynamic)
					{
						// Handle error, bitmap remains null
					}
					#end

					var graphic:FlxGraphic = null;
					if (bitmap != null)
					{
						graphic = FlxGraphic.fromBitmapData(bitmap, id);
					}

					if (canUseCache && bitmap != null)
					{
						Assets.cache.set(id, bitmap);
					}

					if (graphic != null)
					{
						FlxG.bitmap.addGraphic(graphic);
					}

					pushHistory(bitmap != null ? IO_SUCCESS : FAILURE, IMAGE, path);
					bitmap;
				case SOUND:
					var sound:Sound = null;
					#if ASSETS_PACKAGING
					var bytes = Main.bundle.getBytes(path);
					if (bytes != null)
						sound = Sound.fromAudioBuffer(lime.media.AudioBuffer.fromBytes(bytes));
					#else
					try
					{
						sound = Sound.fromFile(path);
					}
					catch (e:Dynamic)
					{
						// Handle error, sound remains null
					}
					#end
					if (canUseCache && sound != null)
					{
						Assets.cache.set(id, sound);
					}

					pushHistory(sound != null ? IO_SUCCESS : FAILURE, SOUND, path);
					sound;
				case FONT:
					var font:Font = null;
					#if ASSETS_PACKAGING
					var bytes = Main.bundle.getBytes(path);
					if (bytes != null)
						font = Font.fromBytes(bytes);
					#else
					try
					{
						font = Font.fromFile(path);
					}
					catch (e:Dynamic)
					{
						// Handle error, font remains null
					}
					#end
					if (canUseCache && font != null)
					{
						Assets.cache.set(id, font);
						Font.registerFont(font);
					}
					pushHistory(font != null ? IO_SUCCESS : FAILURE, FONT, path);
					font;
			}

			return asset;
		};
	}

	public static function loadContext(fileInput:String):AssetContext
	{
		final context = new AssetContext(fileInput);
		contexts.push(context);

		for (entry in context.entries)
		{
			for (file in entry.files)
			{
				FlxG.assets.getAssetUnsafe(file, entry.type);
			}
		}

		return context;
	}

	public static function unloadContext(fileInput:String):Void
	{
		for (context in contexts)
		{
			if (context.name == fileInput)
			{
				AssetContext.dirtyContexts = true;
				contexts.remove(context);
			}
		}
	}

	public static function unloadAllContexts():Void
	{
		for (context in contexts)
		{
			for (entry in context.entries)
			{
				for (file in entry.files)
				{
					if (cache.has(file))
					{
						cache.remove(file);
					}
				}
			}
		}
		contexts = [];
	}

	public static function frames(id:String):FlxAtlasFrames
	{
		if (!FlxG.assets.exists(id, IMAGE) && !FlxG.assets.exists(Path.join(['textures', id + '.xml']), null))
		{
			return null;
		}

		return FlxAtlasFrames.fromSparrow(id, 'assets/textures/$id.xml');
	}

	// equivalent to FileSystem.isDirectory and/or Bundle.isDirectory
	public static function isList(path:String):Bool
	{
		#if macro
		return sys.FileSystem.isDirectory(path);
		#elseif ASSETS_PACKAGING
		return Main.bundle.isDirectory(path);
		#else
		return FileSystem.isDirectory(path);
		#end
	}

	public static function list(path:String):Array<String>
	{
		var list:Array<String> = [];

		if (exists(path))
		{
			#if ASSETS_PACKAGING
			list = Main.bundle.readDirectory(path);
			#else
			list = FileSystem.readDirectory(path);
			#end
		}

		return list;
	}

	public static function exists(path:String):Bool
	{
		#if ASSETS_PACKAGING
		if (Main.bundle.exists(path))
		{
			return true;
		}

		if (Main.bundle.exists(AssetPaths.from(path, null)))
		{
			return true;
		}
		#else
		if (FileSystem.exists(path))
		{
			return true;
		}

		if (FileSystem.exists(AssetPaths.from(path, null)))
		{
			return true;
		}
		#end

		return false;
	}

	private static function pushHistory(context:LoadContext, type:FlxAssetType, filePath:String):Void
	{
		Assets.history.push(new AssetHistory(context, type, getCallerClassName(), filePath));
	}
}
