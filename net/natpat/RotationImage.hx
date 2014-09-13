package net.natpat;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
/**
 * ...
 * @author Nathan Patel
 */
class RotationImage 
{
	
	 var bmp:Bitmap;
	 var bd:BitmapData;
	
	 var rotated:BitmapData;
	 var noOfFrames:Int;
	
	public var width:Int;
	public var height:Int;
	
	public var angle:Float = 0;
	
	 var frame:Int;
	 var rect:Rectangle;
	 var point:Point;
	
	public function new(source:Class, frames:Int = 36, smooth:Bool = false) 
	{
		bmp = (new source);
		bd = bmp.bitmapData;
		
		noOfFrames = frames;
		
		var oldW:Int = bd.width;
		var oldH:Int = bd.height;
		
		width = Math.ceil(oldW * 1.5);
		height = Math.ceil(oldH * 1.5);
		
		rotated = new BitmapData(frames * width, 400, true, 0);
		
		var m:Matrix = new Matrix();
		m.translate(-oldW/2, -oldH/2);
		for (var i:Int = 0; i < frames; i++)
		{
			m.translate(int(width / 2) + width * i, int(height / 2));
			rotated.draw(bd, m, null, null, null, smooth);
			m.translate( int(-(width / 2)) - (width * i), int(-(height / 2)));
			
			m.rotate(2 * Math.PI / frames);
		}
		
		rect = new Rectangle(0, 0, width, height);
		point = new Point();
	}
	
	public function render(x:Int, y:Int):Void
	{
		angle %= 360;
		if (angle < 0) angle += 360;
		frame = uint(noOfFrames * (angle / 360));
		
		rect.x = frame * width;
		point.x = x;
		point.y = y;
		
		GV.screen.copyPixels(rotated, rect, point, null, null, true);
	}
	
}