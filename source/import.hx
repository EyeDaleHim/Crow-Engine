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
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxImageFrame;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxContainer.FlxTypedContainer;

using flixel.math.FlxMath;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxMatrix;

import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;

import flixel.text.FlxText;

import flixel.tweens.FlxTween.FlxTweenManager;

import flixel.ui.FlxBar;

import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxPool;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;

import states.MainState;

import backend.Assets;

import backend.ui.Style;
import backend.ui.Box;
import backend.ui.Button;

import system.DataManager;

import system.data.ChartData;
import system.data.SongDisplayData;
import system.data.SongMetadata;
import system.data.WeekMetadata;
import system.data.WeekGlobalMetadata;

import system.music.Music;
import system.music.Conductor;

import objects.notes.Note;
import objects.notes.StrumNote;

import objects.sprites.Alphabet;
import objects.sprites.Character;
import objects.sprites.NoteSprite;
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

import haxe.Json;

import haxe.io.Bytes;
import haxe.io.Path;

using StringTools;
using Lambda;
using Math;
#if !macro
using Utilities;
#end
using flixel.util.FlxColorTransformUtil;