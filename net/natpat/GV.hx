package net.natpat;
import flash.display.Stage;
import flash.events.Event;
import flash.geom.Point;
import flash.display.BitmapData;
import flash.display.Bitmap;
/**
 * ...
 * @author Nathan Patel
 */
class GV 
{
	/**
	 * Reference to the stage
	 */
	public static var stage:Stage;
	
	/**
	 * The bitmapData for the screen.
	 */
	public static var screen:BitmapData;
	
	/**
	 * Milliseconds elapsed since last frame
	 */
	public static var _elapsed:Float = 0;
	
	public static var elapsed(get, never):Float;
	
	/**
	 * Factor to multiply elapsed by to give the illusion of speeding up
	 */
	public static var timeFactor:Float = 1;
	
	/**
	 * The camera point. Use it as you will
	 */
	public static var camera:Point = new Point();
	
	/**
	 * The number of seconds elapsed adjusted by timeFactor
	 */
	public static function get_elapsed():Float
	{
		return _elapsed * timeFactor;
	}
	
	/**
	 * The actual time elapsed in seconds
	 */
	public static function actualElapsed():Float
	{
		return _elapsed;
	}
	
	/**
	 * The frame rate currently running at
	 */
	public static function frameRate():Float
	{
		return 1 / _elapsed;
	}
	
	/**
	 * Using math random, gives a random number between 0 and limit.
	 * @param	limit	The limit for the number.
	 * @return	Random number between 0 and limit
	 */
	public static function rand(limit:Int):Int
	{
		return Std.int(Math.random() * limit);
	}
	
	/**
	 * Finds the angle (in degrees) from point 1 to point 2.
	 * @param	x1		The first x-position.
	 * @param	y1		The first y-position.
	 * @param	x2		The second x-position.
	 * @param	y2		The second y-position.
	 * @return	The angle from (x1, y1) to (x2, y2).
	 */
	public static function angle(x1:Float, y1:Float, x2:Float, y2:Float):Float
	{
		var a:Float = Math.atan2(y2 - y1, x2 - x1) * DEG;
		return a < 0 ? a + 360 : a;
	}
	
	// Used for rad-to-deg and deg-to-rad conversion.
	/** @ */ public static var  DEG:Float = -180 / Math.PI;
	/** @ */ public static var  RAD:Float = Math.PI / -180;
	
	public static function pointInRect(x:Int, y:Int, xRect:Int, yRect:Int, width:Int, height:Int):Bool
	{
		return (x > xRect &&
				x < xRect + width &&
				y > yRect &&
				y < yRect + height);
	}
	
	public static function intersects(x1:Int, y1:Int, width1:Int, height1:Int,
									  x2:Int, y2:Int, width2:Int, height2:Int):Bool
	{
		if (x1 > x2 + width2) return false;
		if (x2 > x1 + width1) return false;
		if (y1 > y2 + height2) return false;
		if (y2 > y1 + height1) return false;
		return true;
	}
	
	 static var duration:Float;
	 static var intensity:Float;
	 static var offset:Point;
	
	public static function shake(duration:Float, intensity:Float):Void
	{
		GV.duration = duration;
		GV.intensity = intensity;
		offset = new Point(0, 0);
		stage.addEventListener(Event.ENTER_FRAME, shakeUpdate);
	}
	
	 static function shakeUpdate(e:Event):Void
	{
		camera.x -= offset.x;
		camera.y -= offset.y;
		
		duration -= elapsed;
		if (duration < 0)
		{
			stage.removeEventListener(Event.ENTER_FRAME, shakeUpdate);
			return;
		}
		offset.x = Math.random() * intensity - (intensity / 2);
		offset.y = Math.random() * intensity - (intensity / 2);
		camera.x += offset.x;
		camera.y += offset.y;
	}
	
	//Shouldn't have to be used in haxe!
	/*public static function loadBitmapDataFromSource(source:Dynamic):BitmapData
	{
		if (Type.getClass(source) == "Class") return Bitmap(new source).bitmapData;
		if (Type.getClass(source) == "BitmapData") return source;
		return null;
	}*/
}