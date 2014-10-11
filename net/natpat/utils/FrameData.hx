package net.natpat.utils;
import haxe.Constraints.Function;

/**
 * ...
 * @author Nathan Patel
 */
class FrameData
{
	public var x:Int;
	public var y:Int;
	public var time:Float;
	public var callback:Void->Dynamic;

	public function new(x:Int, y:Int, time:Float)
	{
		this.x = x;
		this.y = y;
		this.time = time;
		callback = null;
	}

	public function setCallback(callback:Void->Dynamic):Void
	{
		this.callback = callback;
	}
}