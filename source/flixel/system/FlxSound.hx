package flixel.system;

import flash.events.IEventDispatcher;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;
import flash.media.SoundMixer;
import openfl.Assets;
#if flash11
import flash.utils.ByteArray;
#end
#if (openfl >= "8.0.0")
import openfl.utils.AssetType;
#end
#if lime
import lime.media.AudioBuffer;
#if lime_vorbis
import lime.media.vorbis.VorbisFile;
#end
#end

/**
 * This is the universal flixel sound object, used for streaming, music, and sound effects.
 */
class FlxSound extends FlxBasic
{
	/**
	 * The x position of this sound in world coordinates.
	 * Only really matters if you are doing proximity/panning stuff.
	 */
	public var x:Float;

	/**
	 * The y position of this sound in world coordinates.
	 * Only really matters if you are doing proximity/panning stuff.
	 */
	public var y:Float;

	/**
	 * Whether or not this sound should be automatically destroyed when you switch states.
	 */
	public var persist:Bool;

	/**
	 * The ID3 song name. Defaults to null. Currently only works for streamed sounds.
	 */
	public var name(default, null):String;

	/**
	 * The ID3 artist name. Defaults to null. Currently only works for streamed sounds.
	 */
	public var artist(default, null):String;

	/**
	 * Wheter or not this sound is loaded yet.
	 */
	public var loaded(get, null):Bool;

	#if lime
	/**
	 * Stores the sound lime AudioBuffer if exists.
	 */
	public var buffer(get, null):AudioBuffer;

	#if lime_vorbis
	/**
	 * Stores the sound VorbisFile if exists.
	 */
	public var vorbis(get, null):VorbisFile;
	#end

	/**
	 * Stores for how much channels are in the loaded sound.
	 */
	public var channels(get, null):Int;

	/**
	 * Whether or not this sound is stereo instead of mono.
	 */
	public var stereo(get, null):Bool;
	#end

	/**
	 * Stores the average wave amplitude of both stereo channels.
	 */
	public var amplitude(#if flash default #elseif lime get #end, null):Float;

	/**
	 * Just the amplitude of the left stereo channel.
	 */
	public var amplitudeLeft(#if flash default #elseif lime get #end, null):Float;

	/**
	 * Just the amplitude of the left stereo channel.
	 */
	public var amplitudeRight(#if flash default #elseif lime get #end, null):Float;

	/**
	 * Whether to call `destroy()` when the sound has finished playing.
	 */
	public var autoDestroy:Bool;

	/**
	 * Tracker for sound complete callback. If assigned, will be called
	 * each time when sound reaches its end.
	 */
	public var onComplete:Void->Void;

	/**
	 * Pan amount. -1 = full left, 1 = full right. Proximity based panning overrides this.
	 */
	public var pan(get, set):Float;

	/**
	 * Whether or not the sound is currently playing.
	 */
	public var playing(get, never):Bool;

	/**
	 * Set volume to a value between 0 and 1 to change how this sound is.
	 */
	public var volume(get, set):Float;

	#if FLX_PITCH
	/**
	 * Set pitch, which also alters the playback speed. Default is 1.
	 */
	public var pitch(get, set):Float;
	
	/**
	 * Alters the pitch of the sound depends on the current FlxG.timeScale. Default is true.
	 */
	public var timeScaleBased:Bool = true;
	#end

	/**
	 * The position in runtime of the music playback in milliseconds.
	 * If set while paused, changes only come into effect after a `resume()` call.
	 */
	public var time(get, set):Float;

	/**
	 * The length of the sound in milliseconds.
	 * @since 4.2.0
	 */
	public var length(get, never):Float;

	/**
	 * The sound group this sound belongs to
	 */
	public var group(default, set):FlxSoundGroup;

	/**
	 * Whether or not this sound should loop.
	 */
	public var looped(default, set):Bool;

	/**
	 * In case of looping, the point (in milliseconds) from where to restart the sound when it loops back
	 * @since 4.1.0
	 */
	public var loopTime(default, set):Float = 0.0;

	/**
	 * At which point to stop playing the sound, in milliseconds.
	 * If not set / `null`, the sound completes normally.
	 * @since 4.2.0
	 */
	public var endTime(default, set):Null<Float>;

	/**
	 * The tween used to fade this sound's volume in and out (set via `fadeIn()` and `fadeOut()`)
	 * @since 4.1.0
	 */
	public var fadeTween:FlxTween;

	/**
	 * Internal tracker for a Flash sound object.
	 */
	@:allow(flixel.system.frontEnds.SoundFrontEnd.load)
	var _sound:Sound;

	/**
	 * Internal tracker for a Flash sound channel object.
	 */
	var _channel:SoundChannel;

	/**
	 * Internal tracker for a Flash sound transform object.
	 */
	var _transform:SoundTransform;

	/**
	 * Internal tracker for whether the sound is paused or not (not the same as stopped).
	 */
	var _paused:Bool;

	/**
	 * Internal tracker for volume.
	 */
	var _volume:Float;

	/**
	 * Internal tracker for amplitudeLeft.
	 */
	var _amplitudeLeft:Float = 0.0;

	/**
	 * Internal tracker for amplitudeRight.
	 */
	var _amplitudeRight:Float = 0.0;

	/**
	 * Internal tracker for sound last position on when amplitude was used.
	 */
	var _amplitudeTime:Float = 0.0;

	/**
	 * Internal tracker for amplitude update debounce.
	 */
	var _amplitudeUpdate:Bool = false;

	/**
	 * Internal tracker for sound channel position.
	 */
	var _time:Float = 1.0;

	/**
	 * Internal tracker for sound length, so that length can still be obtained while a sound is paused, because _sound becomes null.
	 */
	var _length:Float = 0;

	#if FLX_PITCH
	/**
	 * Internal tracker for real pitch.
	 */
	var _realPitch:Float = 1.0;

	/**
	 * Internal tracker for pitch.
	 */
	var _pitch:Float = 1.0;

	/**
	 * Internal tracker for FlxG.timeScale adjustment.
	 */
	var _timeScaleAdjust:Float = 1.0;
	#end

	/**
	 * Internal tracker for total volume adjustment.
	 */
	var _volumeAdjust:Float = 1.0;

	/**
	 * Internal tracker for the sound's "target" (for proximity and panning).
	 */
	var _target:FlxObject;

	/**
	 * Internal tracker for the maximum effective radius of this sound (for proximity and panning).
	 */
	var _radius:Float;

	/**
	 * Internal tracker for whether to pan the sound left and right. Default is false.
	 */
	var _proximityPan:Bool;

	/**
	 * Helper var to prevent the sound from playing after focus was regained when it was already paused.
	 */
	var _alreadyPaused:Bool = false;

	/**
	 * The FlxSound constructor gets all the variables initialized, but NOT ready to play a sound yet.
	 */
	public function new()
	{
		super();
		reset();
	}

	/**
	 * An internal function for clearing all the variables used by sounds.
	 */
	function reset():Void
	{
		destroy();

		x = 0;
		y = 0;

		_time = 0;
		_paused = false;
		_volume = 1.0;
		_volumeAdjust = 1.0;
		_pitch = 1.0;
		_realPitch = 1.0;
		_timeScaleAdjust = 1.0;
		_amplitudeLeft = 0.0;
		_amplitudeRight = 0.0;
		_amplitudeUpdate = true;
		looped = false;
		loopTime = 0.0;
		endTime = 0.0;
		_target = null;
		_radius = 0;
		_proximityPan = false;
		visible = false;
		amplitude = 0;
		amplitudeLeft = 0;
		amplitudeRight = 0;
		autoDestroy = false;

		if (_transform == null)
			_transform = new SoundTransform();
		_transform.pan = 0;
	}

	override public function destroy():Void
	{
		_transform = null;
		exists = false;
		active = false;
		_target = null;
		name = null;
		artist = null;

		if (_channel != null)
		{
			_channel.removeEventListener(Event.SOUND_COMPLETE, stopped);
			#if !flash
			_channel.removeEventListener(Event.SOUND_LOOP, ev_looped);
			#end
			_channel.stop();
			_channel = null;
		}

		if (_sound != null)
		{
			_sound.removeEventListener(Event.ID3, gotID3);
			_sound = null;
		}

		onComplete = null;

		super.destroy();
	}

	/**
	 * Handles fade out, fade in, panning, proximity, and amplitude operations each frame.
	 */
	override public function update(elapsed:Float):Void
	{	
		if (!playing)
			return;

		#if FLX_PITCH
		var timeScaleTarget:Float = timeScaleBased ? FlxG.timeScale : 1.0;
		if (_timeScaleAdjust != timeScaleTarget) {
			_timeScaleAdjust = timeScaleTarget;
			pitch = _pitch;
			if (_channel == null) return;
		}
		if (_realPitch > 0) _time = _channel.position;
		#else
		_time = _channel.position;
		#end

		_amplitudeUpdate = true;

		var radialMultiplier:Float = 1.0;

		// Distance-based volume control
		if (_target != null)
		{
			var targetPosition = _target.getPosition();
			radialMultiplier = targetPosition.distanceTo(FlxPoint.weak(x, y)) / _radius;
			targetPosition.put();
			radialMultiplier = 1 - FlxMath.bound(radialMultiplier, 0, 1);

			if (_proximityPan)
			{
				var d:Float = (x - _target.x) / _radius;
				_transform.pan = FlxMath.bound(d, -1, 1);
			}
		}

		_volumeAdjust = radialMultiplier;
		updateTransform();

		#if flash
		if (_transform.volume > 0)
		{
			amplitudeLeft = _channel.leftPeak / _transform.volume;
			amplitudeRight = _channel.rightPeak / _transform.volume;
			amplitude = (amplitudeLeft + amplitudeRight) * 0.5;
		}
		else
		{
			amplitudeLeft = 0;
			amplitudeRight = 0;
			amplitude = 0;
		}
		#end

		#if flash
		if (endTime != null && _time >= endTime)
			stopped();
		#end
	}

	override public function kill():Void
	{
		super.kill();
		cleanup(false);
	}

	/**
	 * One of the main setup functions for sounds, this function loads a sound from an embedded MP3.
	 *
	 * @param	EmbeddedSound	An embedded Class object representing an MP3 file.
	 * @param	Looped			Whether or not this sound should loop endlessly.
	 * @param	AutoDestroy		Whether or not this FlxSound instance should be destroyed when the sound finishes playing.
	 * 							Default value is false, but `FlxG.sound.play()` and `FlxG.sound.stream()` will set it to true by default.
	 * @param	OnComplete		Called when the sound finished playing
	 * @return	This FlxSound instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadEmbedded(EmbeddedSound:FlxSoundAsset, Looped:Bool = false, AutoDestroy:Bool = false, ?OnComplete:Void->Void):FlxSound
	{
		if (EmbeddedSound == null)
			return this;

		cleanup(true);

		if ((EmbeddedSound is Sound))
		{
			_sound = EmbeddedSound;
		}
		else if ((EmbeddedSound is Class))
		{
			_sound = Type.createInstance(EmbeddedSound, []);
		}
		else if ((EmbeddedSound is String))
		{
			if (Assets.exists(EmbeddedSound, AssetType.SOUND) || Assets.exists(EmbeddedSound, AssetType.MUSIC))
				_sound = Assets.getSound(EmbeddedSound);
			else
				FlxG.log.error('Could not find a Sound asset with an ID of \'$EmbeddedSound\'.');
		}

		// NOTE: can't pull ID3 info from embedded sound currently
		return init(Looped, AutoDestroy, OnComplete);
	}

	/**
	 * One of the main setup functions for sounds, this function loads a sound from a URL.
	 *
	 * @param	SoundURL		A string representing the URL of the MP3 file you want to play.
	 * @param	Looped			Whether or not this sound should loop endlessly.
	 * @param	AutoDestroy		Whether or not this FlxSound instance should be destroyed when the sound finishes playing.
	 * 							Default value is false, but `FlxG.sound.play()` and `FlxG.sound.stream()` will set it to true by default.
	 * @param	OnComplete		Called when the sound finished playing
	 * @param	OnLoad			Called when the sound finished loading.
	 * @return	This FlxSound instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadStream(SoundURL:String, Looped:Bool = false, AutoDestroy:Bool = false, ?OnComplete:Void->Void, ?OnLoad:Void->Void):FlxSound
	{
		cleanup(true);

		_sound = new Sound();
		_sound.addEventListener(Event.ID3, gotID3);
		var loadCallback:Event->Void = null;
		loadCallback = function(e:Event)
		{
			(e.target : IEventDispatcher).removeEventListener(e.type, loadCallback);
			// Check if the sound was destroyed before calling. Weak ref doesn't guarantee GC.
			if (_sound == e.target)
			{
				_length = _sound.length;
				if (OnLoad != null)
					OnLoad();
			}
		}
		// Use a weak reference so this can be garbage collected if destroyed before loading.
		_sound.addEventListener(Event.COMPLETE, loadCallback, false, 0, true);
		_sound.load(new URLRequest(SoundURL));

		return init(Looped, AutoDestroy, OnComplete);
	}

	#if flash11
	/**
	 * One of the main setup functions for sounds, this function loads a sound from a ByteArray.
	 *
	 * @param	Bytes 			A ByteArray object.
	 * @param	Looped			Whether or not this sound should loop endlessly.
	 * @param	AutoDestroy		Whether or not this FlxSound instance should be destroyed when the sound finishes playing.
	 * 							Default value is false, but `FlxG.sound.play()` and `FlxG.sound.stream()` will set it to true by default.
	 * @return	This FlxSound instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadByteArray(Bytes:ByteArray, Looped:Bool = false, AutoDestroy:Bool = false, ?OnComplete:Void->Void):FlxSound
	{
		cleanup(true);

		_sound = new Sound();
		_sound.addEventListener(Event.ID3, gotID3);
		_sound.loadCompressedDataFromByteArray(Bytes, Bytes.length);

		return init(Looped, AutoDestroy, OnComplete);
	}
	#end

	function init(Looped:Bool = false, AutoDestroy:Bool = false, ?OnComplete:Void->Void):FlxSound
	{
		looped = Looped;
		autoDestroy = AutoDestroy;
		updateTransform();
		exists = true;
		onComplete = OnComplete;
		#if FLX_PITCH
		pitch = 1;
		#end
		if (_sound != null) {
			#if flash
			_length = _sound.length;
			#else
			makeChannel();
			#end
		}
		else
			_length = 0;

		endTime = _length;
		return this;
	}

	#if !flash
	function makeChannel()
	@:privateAccess {
		var source = new lime.media.AudioSource(_sound.__buffer);
		source.gain = 0;

		_length = source.length;
		_channel = new SoundChannel(null, _transform);
		_channel.__source = source;
		_channel.__source.onComplete.add(_channel.source_onComplete);
		_channel.__source.onLoop.add(_channel.source_onLoop);
		_channel.__isValid = true;

		SoundMixer.__registerSoundChannel(_channel);
	}
	#end

	/**
	 * Call this function if you want this sound's volume to change
	 * based on distance from a particular FlxObject.
	 *
	 * @param	X			The X position of the sound.
	 * @param	Y			The Y position of the sound.
	 * @param	TargetObject		The object you want to track.
	 * @param	Radius			The maximum distance this sound can travel.
	 * @param	Pan			Whether panning should be used in addition to the volume changes.
	 * @return	This FlxSound instance (nice for chaining stuff together, if you're into that).
	 */
	public function proximity(X:Float, Y:Float, TargetObject:FlxObject, Radius:Float, Pan:Bool = true):FlxSound
	{
		x = X;
		y = Y;
		_target = TargetObject;
		_radius = Radius;
		_proximityPan = Pan;
		return this;
	}

	/**
	 * Call this function to play the sound - also works on paused sounds.
	 *
	 * @param   ForceRestart   Whether to start the sound over or not.
	 *                         Default value is false, meaning if the sound is already playing or was
	 *                         paused when you call play(), it will continue playing from its current
	 *                         position, NOT start again from the beginning.
	 * @param   StartTime      At which point to start playing the sound, in milliseconds.
	 * @param   EndTime        At which point to stop playing the sound, in milliseconds.
	 *                         If not set / `null`, the sound completes normally.
	 */
	public function play(ForceRestart:Bool = false, StartTime:Float = 0.0, ?EndTime:Float):FlxSound
	{
		if (!exists)
			return this;

		if (ForceRestart)
			cleanup(false, true);
		else if (playing) // Already playing sound
			return this;

		endTime = EndTime;
		if (_paused)
			resume();
		else
			startSound(StartTime);
		
		return this;
	}

	/**
	 * Unpause a sound. Only works on sounds that have been paused.
	 */
	public function resume():FlxSound
	{
		if (_paused) startSound(_time);
		return this;
	}

	/**
	 * Call this function to pause this sound.
	 */
	public function pause():FlxSound
	{
		if (!playing)
			return this;

		_time = _channel.position;
		_paused = true;
		cleanup(false, false);
		return this;
	}

	/**
	 * Call this function to stop this sound.
	 */
	public inline function stop():FlxSound
	{
		cleanup(autoDestroy, true);
		return this;
	}

	/**
	 * Helper function that tweens this sound's volume.
	 *
	 * @param	Duration	The amount of time the fade-out operation should take.
	 * @param	To			The volume to tween to, 0 by default.
	 */
	public inline function fadeOut(Duration:Float = 1, ?To:Float = 0, ?onComplete:FlxTween->Void):FlxSound
	{
		if (fadeTween != null)
			fadeTween.cancel();
		fadeTween = FlxTween.num(volume, To, Duration, {onComplete: onComplete}, volumeTween);

		return this;
	}

	/**
	 * Helper function that tweens this sound's volume.
	 *
	 * @param	Duration	The amount of time the fade-in operation should take.
	 * @param	From		The volume to tween from, 0 by default.
	 * @param	To			The volume to tween to, 1 by default.
	 */
	public inline function fadeIn(Duration:Float = 1, From:Float = 0, To:Float = 1, ?onComplete:FlxTween->Void):FlxSound
	{
		if (!playing)
			play();

		if (fadeTween != null)
			fadeTween.cancel();

		fadeTween = FlxTween.num(From, To, Duration, {onComplete: onComplete}, volumeTween);
		return this;
	}

	function volumeTween(f:Float):Void
	{
		volume = f;
	}

	/**
	 * Returns the currently selected "real" volume of the sound (takes fades and proximity into account).
	 *
	 * @return	The adjusted volume of the sound.
	 */
	public inline function getActualVolume():Float
	{
		return _volume * _volumeAdjust;
	}
	
	/**
	 * Returns the currently selected "real" pitch of the sound.
	 *
	 * @return	The adjusted pitch of the sound.
	 */
	public inline function getActualPitch():Float
	{
		return _realPitch;//Math.max(0, _pitch * _timeScaleAdjust);
	}

	/**
	 * Helper function to set the coordinates of this object.
	 * Sound positioning is used in conjunction with proximity/panning.
	 *
	 * @param        X        The new x position
	 * @param        Y        The new y position
	 */
	public inline function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		x = X;
		y = Y;
	}

	/**
	 * Call after adjusting the volume to update the sound channel's settings.
	 */
	@:allow(flixel.system.FlxSoundGroup)
	function updateTransform():Void
	{
		if (_transform == null) cleanup(true);
		_transform.volume = #if FLX_SOUND_SYSTEM (FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume * #end
			(group != null ? group.volume : 1) * _volume * _volumeAdjust;

		if (_channel != null)
			_channel.soundTransform = _transform;
	}

	/**
	 * An internal helper function used to attempt to start playing
	 * the sound and populate the _channel variable.
	 */
	function startSound(StartTime:Float):Void
	{
		if (_sound == null) return;

		_paused = false;
		_time = StartTime;
		#if flash
		_channel = _sound.play(_time, 0, _transform);
		#else
		@:privateAccess if (_channel == null || !_channel.__isValid || _channel.__source.__backend == null) makeChannel();
		#end

		if (_channel != null)
		{

			#if FLX_PITCH
			_timeScaleAdjust = timeScaleBased ? FlxG.timeScale : 1.0;
			_realPitch = -1.0;
			pitch = _pitch;
			#end

			#if !flash
			@:privateAccess{
				_channel.soundTransform = _transform;
				_channel.__source.__backend.playing = true;
				_channel.__source.offset = 0;
				_channel.__source.currentTime = Std.int(_time);
				_channel.__lastPeakTime = 0;
				_channel.__leftPeak = 0;
				_channel.__rightPeak = 0;
			}
			looped = looped;
			_amplitudeTime = -1;
			_channel.addEventListener(Event.SOUND_LOOP, ev_looped);
			#end
			_channel.addEventListener(Event.SOUND_COMPLETE, stopped);

			active = true;
		}
		else
		{
			exists = false;
			active = false;
		}
	}

	/**
	 * An internal helper functions used to help Flash
	 * clean up finished sounds or restart looped sounds.
	 */
	function stopped(?_):Void
	{
		if (onComplete != null)
			onComplete();

		if (looped)
		{
			cleanup(false);
			play(false, loopTime, endTime);
		}
		else
			cleanup(autoDestroy);
	}

	#if !flash
	function ev_looped(?_):Void
	{
		if (onComplete != null)
			onComplete();

		if (!looped)
		{
			cleanup(autoDestroy);
		}
		else
			_channel.loops = 999;
	}
	#end

	/**
	 * An internal helper function used to help Flash clean up (and potentially re-use) finished sounds.
	 * Will stop the current sound and destroy the associated SoundChannel, plus,
	 * any other commands ordered by the passed in parameters.
	 *
	 * @param  destroySound    Whether or not to destroy the sound. If this is true,
	 *                         the position and fading will be reset as well.
	 * @param  resetPosition   Whether or not to reset the position of the sound.
	 */
	function cleanup(destroySound:Bool, resetPosition:Bool = true):Void
	{
		if (destroySound)
		{
			reset();
			return;
		}

		if (_channel != null)
		{
			_channel.removeEventListener(Event.SOUND_COMPLETE, stopped);
			#if flash
			_channel.stop();
			_channel = null;
			#else
			_channel.removeEventListener(Event.SOUND_LOOP, ev_looped);
			@:privateAccess{
				if (_channel.__isValid) {
					if (resetPosition) _channel.__source.stop();
					else _channel.__source.pause();
				}
			}
			#end
		}

		active = false;

		if (resetPosition)
		{
			_time = 0;
			_paused = false;
		}
	}

	/**
	 * Internal event handler for ID3 info (i.e. fetching the song name).
	 */
	function gotID3(_):Void
	{
		name = _sound.id3.songName;
		artist = _sound.id3.artist;
		_sound.removeEventListener(Event.ID3, gotID3);
	}

	#if FLX_SOUND_SYSTEM
	@:allow(flixel.system.frontEnds.SoundFrontEnd)
	function onFocus():Void
	{
		if (!_alreadyPaused)
			resume();
	}

	@:allow(flixel.system.frontEnds.SoundFrontEnd)
	function onFocusLost():Void
	{
		_alreadyPaused = _paused;
		pause();
	}
	#end

	function set_group(group:FlxSoundGroup):FlxSoundGroup
	{
		if (this.group != group)
		{
			var oldGroup:FlxSoundGroup = this.group;

			// New group must be set before removing sound to prevent infinite recursion
			this.group = group;

			if (oldGroup != null)
				oldGroup.remove(this);

			if (group != null)
				group.add(this);

			updateTransform();
		}
		return group;
	}

	inline function get_playing():Bool
		@:privateAccess return _channel != null #if !flash && _channel.__isValid && _channel.__source.playing #end;

	inline function get_volume():Float
		return _volume;

	function set_volume(Volume:Float):Float {
		_volume = FlxMath.bound(Volume, 0, 1);
		updateTransform();
		return _volume;
	}

	inline function get_loaded():Bool
		return #if lime buffer != null #else _sound != null #end;

	#if lime
	inline function get_buffer():AudioBuffer
		@:privateAccess return (_sound != null) ? _sound.__buffer : null;

	#if lime_vorbis
	inline function get_vorbis():VorbisFile
		@:privateAccess return (buffer != null) ? buffer.__srcVorbisFile : null;
	#end

	#if !flash
	function update_amplitude():Void @:privateAccess {
		if (_channel == null || _time == _amplitudeTime || !_amplitudeUpdate) return;
		_channel.__updatePeaks();

		_amplitudeUpdate = false;
		_amplitudeLeft = _channel.__leftPeak;
		_amplitudeRight = _channel.__rightPeak;
		_amplitudeTime = _time;
	}

	inline function get_amplitudeLeft():Float {
		update_amplitude();
		return _amplitudeLeft;
	}

	inline function get_amplitudeRight():Float {
		update_amplitude();
		return _amplitudeRight;
	}

	inline function get_amplitude():Float {
		update_amplitude();
		return if (stereo) (_amplitudeLeft + _amplitudeRight) * 0.5; else _amplitudeLeft;
	}
	#end

	inline function get_channels():Int
		@:privateAccess return (buffer != null) ? buffer.channels : 0;

	inline function get_stereo():Bool
		return channels > 1;
	#end

	#if FLX_PITCH
	inline function get_pitch():Float
		return _pitch;

	function set_pitch(v:Float):Float {
		var adjusted:Float = FlxMath.bound(v * _timeScaleAdjust, 0);
		if (_channel != null && _realPitch != adjusted) {
			if ((_channel.pitch = adjusted) > 0 && _realPitch <= 0) {
				_realPitch = adjusted;
				time = _time;
			}
			else
				_realPitch = adjusted;
		}
		return _pitch = FlxMath.bound(v, 0);
	}
	#end

	inline function set_looped(v:Bool):Bool {
		#if !flash
		if (playing) {
			if (v) _channel.loops = 999;
			else _channel.loops = 0;
		}
		#end
		return looped = v;
	}

	inline function set_loopTime(v:Float):Float {
		#if !flash
		if (playing) _channel.loopTime = v;
		#end
		return loopTime = v;
	}

	inline function set_endTime(v:Null<Float>):Null<Float> {
		#if !flash
		if (playing) {
			if (v != null && v > 0) _channel.endTime = v;
			else _channel.endTime = null;
		}
		#end
		return endTime = v;
	}

	inline function get_pan():Float
		return _transform.pan;

	inline function set_pan(pan:Float):Float
		return _transform.pan = pan;

	inline function get_time():Float
		return (playing && _realPitch > 0) ? _time = _channel.position : _time;

	function set_time(time:Float):Float @:privateAccess {
		time = FlxMath.bound(time, 0, length - 1);
		if (_channel != null && _realPitch > 0) {
			#if flash
			cleanup(false, true);
			startSound(time);
			#else
			if (!_channel.__isValid) {
				cleanup(false, true);
				startSound(time);
			}
			else if (playing) {
				_channel.__source.offset = 0;
				_channel.__source.currentTime = Std.int(time);
			}
			#end
		}
		return _time = time;
	}

	inline function get_length():Float
		return _length;

	override public function toString():String {
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("playing", playing),
			LabelValuePair.weak("time", _time),
			LabelValuePair.weak("length", length),
			LabelValuePair.weak("volume", volume)#if FLX_PITCH,
			LabelValuePair.weak("pitch", pitch)
			#end
		]);
	}
}
