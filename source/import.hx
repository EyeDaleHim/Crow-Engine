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
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxContainer;
import flixel.group.FlxSpriteContainer;

import flixel.math.FlxMath;

import flixel.sound.FlxSound;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxTimer;

import gear.Main;

import gear.assets.AssetCache;
import gear.assets.AssetHistory;
import gear.assets.Assets;
import gear.assets.Bundle;

import gear.entities.Entity;

import gear.input.Input;

import gear.music.Music;

import gear.objects.ui.AnimatedText;

import gear.predicates.PredicateEvaluator;

import gear.states.internals.InitState;
import gear.states.internals.MainState;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import haxe.Json;
import haxe.io.Path;

import gear.utils.AxeData;
import gear.utils.JsonComment;

using StringTools;
using Lambda;