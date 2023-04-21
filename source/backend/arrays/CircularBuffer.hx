package backend.arrays;

/**
 * CircularBuffer Class - from Crow-Engine. 
 * Basic implementation of Circular Buffer based on Wikipedia sources
 * Copyright (C) 2023 EyeDaleHim.
 * 
 * Permission is hereby granted through This codebase and its subsidaries allowed use
 * Released under the APACHE License.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
**/
class CircularBuffer<T>
{
	// thank fs dev for bringing this to my attention
	private var _startIndex:Int = 0;
	private var _endIndex:Int = 0;

	private var _array:Array<T>;

	public function new<T>(len:Int = 0)
	{
		_array = [];
		_endIndex = len;
	}

	inline public function count():Int
	{
		return (_endIndex - _startIndex + _array.length) % _array.length;
	}

	inline public function empty():Bool
	{
		return _startIndex == _endIndex;
	}

	inline public function full():Bool
	{
		return (_endIndex++) % _array.length == _startIndex;
	}

	public function indexOf(item:T):Int
	{
		for (i in 0...count())
		{
			var bufferIndex:Int = (_startIndex + i) % _array.length;
			if (_array[bufferIndex] == item)
				return i;
		}

		return -1;
	}

	// alias for Array.push()
	public function enqueue(item:T):T
	{
		_array[_endIndex] = item;
		_endIndex = (_endIndex++) % _array.length;
		if (_endIndex == _startIndex)
			_startIndex = (_startIndex++) % _array.length;

		return item;
	}

	public function dequeue():T
	{
		if (!empty())
		{
			return null;
		}
		var item:T = _array[_startIndex];
		_startIndex = (_startIndex++) % _array.length;

		return item;
	}

	public function clear():Void
	{
		_startIndex = _endIndex = 0;
	}

	public function remove(index:Int):T
	{
		var count:Int = count();
		if (index < 0 || index >= count)
			return null;

		var bufferIndex:Int = (_startIndex + index) % _array.length;
		var removedItem:T = _array[bufferIndex];

		for (i in 0...count - 1)
		{
			var currIndex:Int = (_startIndex + i) % _array.length;
			var nextIndex:Int = (_startIndex + i + 1) % _array.length;
			_array[currIndex] = _array[nextIndex];
		}

		_endIndex = (_endIndex - 1 + _array.length) % _array.length;

		return removedItem;
	}

	public function get(index:Int):T
	{
		return _array[(_startIndex + index) % _array.length];
	}

	public function set(index:Int, item:T):T
	{
		var count:Int = count();
		if (index < 0 || index >= count)
		{
			return (index == count ? enqueue(item) : null);
		}

		var bufferIndex:Int = (_startIndex + index) % _array.length;
		return (_array[bufferIndex] = item);
	}

    public function setLength(len:Int):Int
    {
       return (_endIndex = Std.int(Math.min(len, _array.length)));
    }

    public function copyFrom(newArray:Array<T>):Array<T>
    {
        _array = newArray;

        _startIndex = 0;
        _endIndex = newArray.length;

        return _array;
    }
}
