package gear.assets;

import haxe.CallStack;
import flixel.system.frontEnds.AssetFrontEnd;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;
import gear.assets.AssetHistory;
import gear.assets.AssetCache;
import gear.assets.AssetPaths;
import gear.assets.AssetContext;
import gear.assets.stitching.AtlasStitchData;
import gear.assets.stitching.StitchedAtlas;

class Assets
{
	public static final classExclusions:Array<String> = [
		'flixel',
		#if cpp
		"gear.assets.Assets", "gear.assets.AssetHistory"
		#elseif hl
		"gear.assets.$Assets", "gear.assets.$AssetHistory"
		#end
	];

	public var history:Array<AssetHistory>;
	public var cache:AssetCache;
	public var contexts:Array<AssetContext>;
	public var stitches:Array<StitchedAtlas>;

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
			if (className != null && !classExclusions.contains(className))
			{
				return className;
			}
		}

		return "unknown";
	}

	public function new():Void
	{
		history = [];
		contexts = [];
		stitches = [];
		cache = new AssetCache();

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
		assets.isLocal = (id, ?type, canCache = true) ->
		{
			if (StringTools.startsWith(id, "flixel/") || StringTools.contains(id, ':'))
			{
				return oldLocal(id, type, canCache);
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
		assets.getAssetUnsafe = (id, type, canCache = true) ->
		{
			if (AssetContext.dirtyContexts)
			{
				checkOrphanedAssets();
				AssetContext.dirtyContexts = false;
			}

			if (StringTools.startsWith(id, "flixel/") || StringTools.contains(id, ':'))
			{
				return oldGet(id, type, canCache);
			}

			final canUseCache = canCache && cache.enabled;
			final path = AssetPaths.from(id, type);

			if (canUseCache && cache.has(id))
			{
				pushHistory(CACHE_FETCH, type, path);
				return cache.get(id);
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
						graphic = FlxG.bitmap.add(bitmap, false, id);
						if (canUseCache)
							cache.set(id, bitmap);
					}

					pushHistory(graphic != null ? IO_SUCCESS : FAILURE, IMAGE, path);
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
						cache.set(id, sound);
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
						cache.set(id, font);
						Font.registerFont(font);
					}
					pushHistory(font != null ? IO_SUCCESS : FAILURE, FONT, path);
					font;
			}

			return asset;
		};
	}

	/**
	 * Loads the stitched atlas metadata. This does not load the atlas itself.
	 */
	public function loadStitchedAtlas(atlasInput:String):AtlasStitchData
	{
		final path = Path.join([AssetContext.contextDirectory, '$atlasInput.json']);
		final rawAtlasData:AtlasStitchData = Json.parse(FlxG.assets.getTextUnsafe(path));

		return rawAtlasData;
	}

	public function loadContext(fileInput:String, ?reload:Bool = false):AssetContext
	{
		var context = findContext(fileInput);
		if (context != null && !reload)
		{
			trace('CONTEXT - Used existing context: $fileInput');
			return context;
		}

		trace('CONTEXT - Loaded new context: $fileInput');
		context = new AssetContext(fileInput);
		contexts.push(context);

		for (entry in context.entries)
		{
			FlxG.assets.getAsset(entry.path, entry.type, true);
		}

		return context;
	}

	public function unloadContext(fileInput:String):Void
	{
		for (context in contexts)
		{
			if (context.name == fileInput)
			{
				AssetContext.dirtyContexts = true;
				trace('CONTEXT - Unloaded context: $fileInput');
				contexts.remove(context);
			}
		}
	}

	public function unloadAllContexts():Void
	{
		// unloading every context implies clearing the cache
		cache.clear();
		contexts = [];
	}

	public function findContext(fileInput:String):AssetContext
	{
		// Why am I finding the context this way again???
		for (context in contexts)
		{
			if (context.name == fileInput)
			{
				return context;
			}
		}

		return null;
	}

	public function frames(id:String):FlxAtlasFrames
	{
		final xmlPath:String = Path.join(['textures', id + '.xml']);
		if (!FlxG.assets.exists(id, IMAGE) || !FlxG.assets.exists(xmlPath, TEXT))
		{
			return null;
		}

		final graphic = FlxG.assets.getBitmapDataUnsafe(id, true);
		final xml = FlxG.assets.getTextUnsafe(xmlPath, true);
		final frames = FlxAtlasFrames.fromSparrow(graphic, xml);

		return frames;
	}

	// equivalent to FileSystem.isDirectory and/or Bundle.isDirectory
	public function isList(path:String):Bool
	{
		#if macro
		return sys.FileSystem.isDirectory(path);
		#elseif ASSETS_PACKAGING
		return Main.bundle.isDirectory(path);
		#else
		return FileSystem.isDirectory(path);
		#end
	}

	public function list(path:String):Array<String>
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

	public function exists(path:String):Bool
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

	private function checkOrphanedAssets():Void
	{
		var orphanedAssets:Array<String> = [];
		@:privateAccess
		for (assetId in cache._cache.keys())
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
			cache.remove(orphanedId);
		}
	}

	private function pushHistory(context:LoadContext, type:FlxAssetType, filePath:String):Void
	{
		history.push(new AssetHistory(context, type, getCallerClassName(), filePath));
	}
}
