package crow.assets;

import haxe.CallStack;
import flixel.system.frontEnds.AssetFrontEnd;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;
import crow.assets.AssetHistory;
import crow.assets.AssetCache;
import crow.assets.AssetPaths;
import crow.assets.AssetContext;
import lime.app.Future;
import lime.app.Promise;
#if USE_TEXTURE
import openfl.display3D.textures.RectangleTexture;
#end
import crow.assets.stitching.AtlasStitchData;
import crow.assets.stitching.StitchedAtlas;
class Assets
{
	public static final classExclusions:Array<String> = [
		'flixel',
		'flixel.system.frontEnds.AssetFrontEnd',
		#if cpp
		"crow.assets.Assets", "crow.assets.AssetHistory"
		#elseif hl
		"crow.assets.$Assets", "crow.assets.$AssetHistory", "crow.assets.Assets", "crow.assets.AssetHistory"
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

			if (AssetContext.enforceAssetContext)
			{
				var foundInContext:Bool = false;
				for (context in contexts)
				{
					if (context.findAsset(id))
					{
						foundInContext = true;
						break;
					}
				}
				if (!foundInContext)
				{
					trace('ASSET - Blocked orphaned asset load: $id (enforceAssetContext is true)');
					return null;
				}
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

					if (canUseCache)
						cache.set(id, textAsset);

					pushHistory(textAsset != null ? IO_SUCCESS : FAILURE, TEXT, AssetPaths.from(id, type));
					return textAsset;
				case BINARY:
					var binaryAsset:haxe.io.Bytes = null;
					#if ASSETS_PACKAGING
					binaryAsset = Main.bundle.getBytes(path);
					#else
					binaryAsset = sys.io.File.getBytes(path);
					#end

					if (canUseCache)
						cache.set(id, binaryAsset);

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
						graphic = FlxG.bitmap.add(bitmap, false, path);
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
		final rawAtlasData:AtlasStitchData = Json.parse(JsonComment.removeComments(FlxG.assets.getTextUnsafe(path)));

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
			if (FlxG.assets.exists(entry.path, entry.type))
			{
				FlxG.assets.getAssetUnsafe(entry.path, entry.type, true);
			}
			else
			{
				trace('CONTEXT - Asset not found: ${AssetPaths.from(entry.path, entry.type)}');
			}
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
		#if SBS_SPARROW
		final path = Path.join(['textures', '$id.sbs']);
		if (!FlxG.assets.exists(path))
		{
			return null;
		}

		final sbsBytes = FlxG.assets.getBytesUnsafe(path);
		final frames = crow.assets.format.BinarySparrow.parse(sbsBytes);
		#else
		final xmlPath:String = Path.join(['textures', '$id.xml']);

		if (!FlxG.assets.exists(id, IMAGE) || !FlxG.assets.exists(xmlPath, TEXT))
		{
			return null;
		}

		final graphic = FlxG.assets.getBitmapDataUnsafe(id, true);
		final xml = FlxG.assets.getTextUnsafe(xmlPath, true);
		final frames = FlxAtlasFrames.fromSparrow(graphic, xml);
		#end

		return frames;
	}

	public function json(id:String):Dynamic
	{
		try
		{
			final path = '$id.${AssetPaths.jsonExt}';

			#if JSON_TO_MESSAGEPACK
			final msgpBytes = FlxG.assets.getBytesUnsafe(path);
			if (msgpBytes == null)
			{
				return null;
			}
			return crow.assets.format.MessagePack.parse(msgpBytes);
			#else
			final jsonString = FlxG.assets.getTextUnsafe(path);
			if (jsonString == null)
			{
				return null;
			}
			return Json.parse(JsonComment.removeComments(jsonString));
			#end
		}
		catch (e)
		{
			trace(e.message);
			return null;
		}

		throw "Not implemented";
	}

	// equivalent to FileSystem.isDirectory and/or Bundle.isDirectory
	public function isList(path:String):Bool
	{
		#if macro
		return sys.FileSystem.isDirectory(path);
		#elseif ASSETS_PACKAGING
		return Main.bundle.isDirectory(path);
		#end

		throw "Not implemented";
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

	/**
	 * Asynchronously loads all assets within a context.
	 * Returns a Future that completes when all assets are loaded.
	 */
	public function loadContextAsync(fileInput:String, ?reload:Bool = false):Future<AssetContext>
	{
		var promise = new Promise<AssetContext>();

		var context = findContext(fileInput);
		if (context != null && !reload)
		{
			return Future.withValue(context);
		}

		context = new AssetContext(fileInput);
		contexts.push(context);

		var assetsToLoad = context.entries.length;
		var completedCount = 0;

		if (assetsToLoad == 0)
		{
			promise.complete(context);
			return promise.future;
		}

		for (entry in context.entries)
		{
			// We use OpenFL/Lime's async methods here
			var loadTask:Future<Dynamic> = switch (entry.type)
			{
				case IMAGE: BitmapData.loadFromFile(entry.path);
				case SOUND: Sound.loadFromFile(entry.path);
				case FONT: Font.loadFromFile(entry.path);
				case TEXT: lime.utils.Assets.loadText(entry.path);
				case BINARY: lime.utils.Assets.loadBytes(entry.path);
				default: Future.withValue(null);
			}

			loadTask.onComplete(function(asset:Dynamic)
			{
				if (asset != null)
				{
					if (entry.type == FONT)
						Font.registerFont(asset);
					cache.set(entry.path, asset);
					pushHistory(IO_SUCCESS, entry.type, entry.path);
				}

				completedCount++;
				if (completedCount == assetsToLoad)
				{
					promise.complete(context);
				}
			});

			loadTask.onError(function(err)
			{
				trace('Async Load Error: $err for ${entry.path}');
				pushHistory(FAILURE, entry.type, entry.path);

				// Even on failure, we increment to avoid hanging the whole process
				completedCount++;
				if (completedCount == assetsToLoad)
				{
					promise.complete(context);
				}
			});
		}

		return promise.future;
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
