package net.natpat.utils;

import flash.display.BitmapData;
import flash.geom.Point;
import net.natpat.utils.Animation;

class GlowAnim extends Animation
{

	public var bd:BitmapData;
	public var offset:Point;
	public var newW:Int;
	public var newH:Int;

	public function new(bd:BitmapData, offset:Point, newW:Int, newH:Int)
	{
	super(null, new Array(), true);
	this.bd = bd;
	this.offset = offset;
	this.newW = newW;
	this.newH = newH;
	}
}