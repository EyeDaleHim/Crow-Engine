#if !macro
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxSubState;

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
import flixel.group.FlxSpriteGroup;
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
import flixel.tweens.FlxEase;

import flixel.input.mouse.FlxMouseEvent;

import flixel.ui.FlxBar;

import flixel.util.typeLimit.OneOfTwo;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxPool;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;

import states.*;

import states.editors.*;
import states.menus.*;
import states.options.*;

import substates.*;

import backend.Constants;

import backend.ui.*;
import backend.ui.Button.ButtonStyle;
import backend.ui.Stepper.StepperStyle;
import backend.ui.List.ItemStyle;

import system.api.Discord;

import system.assets.Assets;

import system.WeekManager;

import system.data.AnimationData;
import system.data.ChartData;
import system.data.CharacterData;
import system.data.SongData;
import system.data.PointData;
import system.data.WeekMetadata;

import system.gameplay.Chart;
import system.gameplay.Rating;

import system.input.*;
import system.input.Controls.ActionArgs;
import system.input.Controls.Control;

import system.music.Music;
import system.music.Conductor;

import utils.logs.Logs;

import objects.characters.*;

import objects.game.*;

import objects.notes.*;

import objects.sprites.*;

import objects.stages.*;
import objects.stages.stage_data.*;
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
using utils.ObjectUtils;
using utils.StringUtils;
using utils.ValidateUtils;
#end
using flixel.util.FlxColorTransformUtil;