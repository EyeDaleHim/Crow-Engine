package lime._internal.backend.native;

import haxe.Timer;
import haxe.Int64;

import lime.math.Vector4;
import lime.media.openal.AL;
import lime.media.openal.ALBuffer;
import lime.media.openal.ALSource;
import lime.media.vorbis.VorbisFile;
import lime.media.AudioBuffer;
import lime.media.AudioSource;
import lime.utils.UInt8Array;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(lime.media.AudioBuffer)
class NativeAudioSource {
	private static var STREAM_BUFFER_SIZE:Int = 16000;
	//#if (native_audio_buffers && !macro)
	//private static var STREAM_NUM_BUFFERS:Int = Std.parseInt(haxe.macro.Compiler.getDefine("native_audio_buffers"));
	//#else
	private static var STREAM_NUM_BUFFERS:Int = 16;
	//#end
	private static var STREAM_TIMER_FREQUENCY:Int = 100;

	private var buffers:Array<ALBuffer>;
	private var bufferDatas:Array<UInt8Array>;
	private var bufferTimeBlocks:Array<Float>;
	private var bufferLoops:Int;
	private var queuedBuffers:Int;
	private var canFill:Bool;

	private var length:Null<Float>;
	private var loopTime:Null<Float>;
	private var playing:Bool;
	private var loops:Int;
	private var position:Vector4;

	private var dataLength:Int;
	private var samples:Int;
	private var format:Int;
	private var completed:Bool;
	private var stream:Bool;

	private var handle:ALSource;
	private var parent:AudioSource;
	private var timer:Timer;
	private var streamTimer:Timer;
	private var disposed:Bool;
	private var safeEnd:Bool;

	public function new(parent:AudioSource) {
		this.parent = parent;
		position = new Vector4();
	}

	public function dispose():Void {
		disposed = true;

		if (handle != null) {
			AL.sourcei(handle, AL.BUFFER, null);
			AL.deleteSource(handle);
			handle = null;
		}

		if (buffers != null) {
			AL.deleteBuffers(buffers);
			buffers = null;
		}
	}

	public function init():Void {
		parent.buffer.initBuffer();

		disposed = (handle = AL.createSource()) == null;
		format = parent.buffer.__format;
		bufferLoops = 0;

		var vorbisFile = parent.buffer.__srcVorbisFile;
		if (stream = vorbisFile != null) {
			var pcmTotal = vorbisFile.pcmTotal();

			dataLength = Int64.toInt(pcmTotal * parent.buffer.channels * (Int64.ofInt(parent.buffer.bitsPerSample) / 8));
			samples = Int64.toInt(pcmTotal);

			buffers = new Array();
			bufferDatas = new Array();
			bufferTimeBlocks = new Array();
			for (i in 0...STREAM_NUM_BUFFERS) {
				buffers.push(AL.createBuffer());
				bufferDatas.push(new UInt8Array(STREAM_BUFFER_SIZE));
				bufferTimeBlocks.push(0);
			}
		}
		else {
			dataLength = parent.buffer.data.length;
			samples = Int64.toInt((Int64.make(0, dataLength) * 8) / (parent.buffer.channels * parent.buffer.bitsPerSample));

			if (!disposed) AL.sourcei(handle, AL.BUFFER, parent.buffer.__srcBuffer);
		}

		if (samples < 1 || Math.isNaN(samples) || !Math.isFinite(samples)) return dispose();
	}

	public function play():Void {
		if (playing || disposed) return;

		playing = true;
		setCurrentTime(completed ? 0 : getCurrentTime());
	}

	public function pause():Void {
		if (!(disposed = handle == null)) AL.sourcePause(handle);

		playing = false;
		stopStreamTimer();
		stopTimer();
	}

	public function stop():Void {
		if (playing && !(disposed = handle == null) && AL.getSourcei(handle, AL.SOURCE_STATE) == AL.PLAYING)
			AL.sourceStop(handle);

		bufferLoops = 0;
		playing = false;
		stopStreamTimer();
		stopTimer();
	}

	private function complete():Void {
		stop();

		completed = true;
		parent.onComplete.dispatch();
	}

	private function readVorbisFileBuffer(vorbisFile:VorbisFile, length:Int, end:Float = 0):UInt8Array {
		#if lime_vorbis
		var readMax = STREAM_NUM_BUFFERS - 1, read = STREAM_NUM_BUFFERS - queuedBuffers, step = read, buffer = bufferDatas[readMax];
		var sec = vorbisFile.timeTell();
		while(step < readMax) {
			bufferTimeBlocks[read] = bufferTimeBlocks[++step];
			bufferDatas[read] = bufferDatas[step];
			read++;
		}

		bufferTimeBlocks[readMax] = sec;
		bufferDatas[readMax] = buffer;
		step = 0;

		while(step < length) {
			readMax = 4096;

			if (readMax > (read = length - step)) readMax = read;
			if (end > 0 && readMax > (read = Std.int((end / 1000 - sec) * parent.buffer.sampleRate))) readMax = read;

			if (readMax > 0 && (read = vorbisFile.read(buffer.buffer, step, readMax)) > 0) {
				step += read;
				sec += read / parent.buffer.sampleRate;
			}
			else if (loops > 0) {
				bufferLoops++;
				vorbisFile.timeSeek(sec = (loopTime != null ? Math.max(0, loopTime / 1000) : 0));
			}
			else {
				safeEnd = true;
				resetTimer(Std.int((getLength() - (sec * 1000)) / getPitch()));
				break;
			}
		}
		return buffer;
		#else
		return null;
		#end
	}

	private function fillBuffers(buffers:Array<ALBuffer>):Void {
		#if lime_vorbis
		if (buffers.length < 1 || parent == null || parent.buffer == null) return dispose();

		var vorbisFile = parent.buffer.__srcVorbisFile;
		if (vorbisFile == null) return dispose();

		var position = vorbisFile.pcmTell(), samples = samples;
		if (length != null) samples = Int64.toInt(Int64.fromFloat((length + parent.offset) / 1000 * parent.buffer.sampleRate));
		if (position >= samples && loops < 1) return;

		var numBuffers = 0, size = 0, data;
		for (buffer in buffers) {
			if (loops < 1 && position >= samples) break;
			position += (size = (data = readVorbisFileBuffer(vorbisFile, STREAM_BUFFER_SIZE, length)).length);
			AL.bufferData(buffer, format, data, size, parent.buffer.sampleRate);
			numBuffers++;
		}

		AL.sourceQueueBuffers(handle, numBuffers, buffers);

		if (playing && AL.getSourcei(handle, AL.SOURCE_STATE) == AL.STOPPED) {
			AL.sourcePlay(handle);
			resetTimer(Std.int((getLength() - getCurrentTime()) / getPitch()));
		}
		#end
	}

	// Timers
	inline function stopStreamTimer():Void if (streamTimer != null) streamTimer.stop();

	#if !lime_vorbis inline #end private function resetStreamTimer():Void {
		stopStreamTimer();

		#if lime_vorbis
		streamTimer = new Timer(STREAM_TIMER_FREQUENCY);
		streamTimer.run = streamTimer_onRun;
		#end
	}

	inline function stopTimer():Void if (timer != null) timer.stop();

	private function resetTimer(timeRemaining:Float):Void {
		stopTimer();

		if (timeRemaining <= 30) {
			timer_onRun();
			return;
		}
		timer = new Timer(timeRemaining);
		timer.run = timer_onRun;
	}

	// Event Handlers
	private function streamTimer_onRun():Void {
		#if lime_vorbis
		var vorbisFile;
		if (disposed = (handle == null) || (vorbisFile = parent.buffer.__srcVorbisFile) == null) return;

		var processed = AL.getSourcei(handle, AL.BUFFERS_PROCESSED);
		if (processed > 0) {
			fillBuffers(AL.sourceUnqueueBuffers(handle, processed));
			queuedBuffers = AL.getSourcei(handle, AL.BUFFERS_QUEUED);
			if ((canFill = !canFill) && (!safeEnd || loops > 0) && queuedBuffers < STREAM_NUM_BUFFERS)
				fillBuffers([buffers[++queuedBuffers - 1]]);
		}
		#end
	}

	private function timer_onRun():Void {
		if (!safeEnd && bufferLoops <= 0) {
			var ranOut = false;
			#if lime_vorbis
			var vorbisFile = parent.buffer.__srcVorbisFile;
			if (stream) {
				if (vorbisFile == null) return dispose();
				var samples = samples;
				if (length != null) samples = Int64.toInt(Int64.fromFloat((length + parent.offset) / 1000 * parent.buffer.sampleRate));
				ranOut = vorbisFile.pcmTell() >= samples || queuedBuffers < 3;
			}
			#end

			if (!ranOut) {
				var timeRemaining = (getLength() - getCurrentTime()) / getPitch();
				if (timeRemaining > 100 && AL.getSourcei(handle, AL.SOURCE_STATE) == AL.PLAYING) {
					resetTimer(timeRemaining);
					return;
				}
			}
		}
		safeEnd = false;

		if (loops <= 0) {
			complete();
			return;
		}

		if (bufferLoops > 0) {
			loops -= bufferLoops;
			bufferLoops = 0;
			parent.onLoop.dispatch();
			return;
		}

		loops--;
		setCurrentTime(loopTime != null ? Math.max(0, loopTime) : 0);
		parent.onLoop.dispatch();
	}

	// Get & Set Methods
	public function getCurrentTime():Float {
		if (completed) return getLength();
		else if (!disposed) {
			var time;
			if (stream) time = (bufferTimeBlocks[STREAM_NUM_BUFFERS - queuedBuffers] + AL.getSourcef(handle, AL.SEC_OFFSET));
			else time = samples / parent.buffer.sampleRate * (AL.getSourcei(handle, AL.BYTE_OFFSET) / dataLength);
			time -= parent.offset;

			if (time > 0) return time * 1000;
		}
		return 0;
	}

	public function setCurrentTime(value:Float):Float {
		if (disposed = (handle == null)) return value;

		var total = samples / parent.buffer.sampleRate * 1000;
		var time = Math.max(0, Math.min(total, value + parent.offset)), ratio = time / total;

		if (stream) {
			AL.sourceStop(handle);

			// uses the al queuedbuffers instead just incase if there is any unexpected repeated buffers
			AL.sourceUnqueueBuffers(handle, AL.getSourcei(handle, AL.BUFFERS_QUEUED));

			#if lime_vorbis
			var vorbisFile = parent.buffer.__srcVorbisFile;
			if (canFill = (vorbisFile != null)) {
				//var chunk = Std.int(Math.floor(samples * ratio / STREAM_BUFFER_SIZE) * STREAM_BUFFER_SIZE);
				vorbisFile.pcmSeek(Int64.fromFloat(samples * ratio));

				fillBuffers(buffers.slice(0, queuedBuffers = 3));
				//AL.sourcei(handle, AL.SAMPLE_OFFSET, Std.int((samples * ratio) - chunk));
				if (playing) resetStreamTimer();
			}
			#end
		}
		else {
			AL.sourceRewind(handle);
			AL.sourcei(handle, AL.BYTE_OFFSET, Std.int(dataLength * ratio));
		}

		if (playing) {
			var timeRemaining = (getLength() - time) / getPitch();
			if (completed = timeRemaining < 1) complete();
			else {
				AL.sourcePlay(handle);
				resetTimer(timeRemaining);
			}
		}

		return value;
	}

	public function getLength():Float {
		if (length != null) return length - parent.offset;
		return (samples / parent.buffer.sampleRate * 1000) - parent.offset;
	}

	public function setLength(value:Float):Float {
		if (value == length) return value;
		if (playing) {
			var timeRemaining = ((value - parent.offset) - getCurrentTime()) / getPitch();
			if (timeRemaining > 0) resetTimer(timeRemaining);
		}
		return length = value;
	}

	public function getPitch():Float {
		if (disposed) return 1;
		return AL.getSourcef(handle, AL.PITCH);
	}

	public function setPitch(value:Float):Float {
		if (disposed || value == AL.getSourcef(handle, AL.PITCH)) return value;
		AL.sourcef(handle, AL.PITCH, value);

		if (playing) {
			var timeRemaining = (getLength() - getCurrentTime()) / value;
			if (timeRemaining > 0) resetTimer(timeRemaining);
		}
		return value;
	}

	public function getGain():Float {
		if (disposed) return 1;
		return AL.getSourcef(handle, AL.GAIN);
	}

	public function setGain(value:Float):Float {
		if (!disposed) AL.sourcef(handle, AL.GAIN, value);
		return value;
	}

	inline public function getLoops():Int return loops;

	inline public function setLoops(value:Int):Int return loops = value;

	inline public function getLoopTime():Float return loopTime;

	inline public function setLoopTime(value:Float):Float return loopTime = value;

	#if emscripten
	inline public function getPosition():Vector4 return position;
	#else
	public function getPosition():Vector4 {
		if (!disposed) {
			var value = AL.getSource3f(handle, AL.POSITION);
			position.x = value[0];
			position.y = value[1];
			position.z = value[2];
		}
		return position;
	}
	#end

	public function setPosition(value:Vector4):Vector4 {
		position.x = value.x;
		position.y = value.y;
		position.z = value.z;
		position.w = value.w;

		if (!disposed) {
			AL.distanceModel(AL.NONE);
			AL.source3f(handle, AL.POSITION, position.x, position.y, position.z);
		}
		return position;
	}
}