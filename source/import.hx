#if !macro
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;

import flixel.effects.FlxFlicker;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxImageFrame;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

using flixel.math.FlxMath;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;

import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;

import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxTimer;

import states.MainState;

import system.Assets;

import system.music.Music;
import system.music.Conductor;

import objects.sprites.Alphabet;
#end

import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.Sprite;

import openfl.events.Event;
import openfl.events.KeyboardEvent;

import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import openfl.geom.Point;

import openfl.media.Sound;

import openfl.Lib;

import sys.FileSystem;
import sys.io.File;

import haxe.io.Bytes;

using StringTools;
using Math;