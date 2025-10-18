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

import flixel.group.FlxGroup;
import flixel.group.FlxContainer;

import flixel.math.FlxMath;

import flixel.sound.FlxSound;

import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;

import gear.assets.AssetCache;
import gear.assets.AssetHistory;
import gear.assets.Assets;
import gear.assets.Bundle;

import gear.music.Music;

import gear.states.internals.InitState;
import gear.states.internals.MainState;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import haxe.Json;
import haxe.io.Path;

using StringTools;