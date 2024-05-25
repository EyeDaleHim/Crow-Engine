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
import flixel.group.FlxContainer;
import flixel.group.FlxContainer.FlxTypedContainer;

import flixel.input.keyboard.FlxKey;

using flixel.math.FlxMath;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxMatrix;

import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;

import flixel.text.FlxText;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenManager;

import flixel.input.mouse.FlxMouseEvent;

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

import states.editors.CharacterEditorGroup;
import states.editors.ChartEditorGroup;
import states.editors.StageEditorGroup;
import states.editors.ScreenEditorState;

import backend.ui.Style;
import backend.ui.Box;
import backend.ui.Button;
import backend.ui.Checkbox;

import system.assets.Assets;

import system.DataManager;

import system.gameplay.Chart;

import system.data.AnimationData;
import system.data.ChartData;
import system.data.CharacterData;
import system.data.SongData;
import system.data.PointData;
import system.data.WeekMetadata;

import system.music.Music;
import system.music.Conductor;

import objects.characters.Bopper;
import objects.characters.Character;

import objects.notes.Note;
import objects.notes.StrumNote;

import objects.sprites.Alphabet;
import objects.sprites.NoteSprite;

import objects.stages.Prop;

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