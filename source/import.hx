#if (!flash && !macro)
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxSubState;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;

import gear.assets.AssetCache;
import gear.assets.AssetHistory;
import gear.assets.Assets;
import gear.assets.Bundle;

import gear.states.internals.InitState;
import gear.states.internals.MainState;
#end

import haxe.io.Path;

using StringTools;