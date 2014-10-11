package net.natpat.utils;


/**
 * ...
 * @author Nathan Patel
 */
class Animation
{
	public var frames:Array<FrameData>;
	public var repeatable:Bool;
	public var name:String;
	public var length:Int;

	public function new(name:String, frames:Array<FrameData>, repeatable:Bool)
	{
		this.name = name;
		this.frames = frames;
		this.repeatable = repeatable;
		length = frames.length;
	}
}