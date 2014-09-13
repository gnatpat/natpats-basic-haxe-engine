package net.natpat;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.BitmapFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
/**
 * ...
 * @author Nathan Patel
 */
class SpriteSheet 
{
	 var width:Int;
	 var height:Int;
	 var offset:Point;
	
	 var anims:Object;
	
	 var anim:Animation;
	 var frame:Int;
	 var fd:FrameData;
	 var time:Float;
	
	 var defaultAnim:Animation;
	
	 var point:Point;
	 var rect:Rectangle;
	
	 var buffer:BitmapData;
	
	 var bitmapData:BitmapData;
	
	public function new(source:*, width:Int, height:Int)
	{
		this.width = width;
		this.height = height; 
		offset = new Point(0, 0);
		
		anims = new Object();
		point = new Point();
		
		rect = new Rectangle();
		rect.width = width;
		rect.height = height;
		
		frame = 0;
		time = 0;
		
		buffer = GV.screen;
		
		bitmapData = GV.loadBitmapDataFromSource(source);
		
		addAnim("default", [[0, 0, 5]], true);
		setDefault("default");
		changeAnim("default");
	}
	
	/**
	 * Create a new animation.
	 * @param	name	Name of new animation
	 * @param	frames	A 2D array - each frame is a array of length 3 or containing x, y, frame length
	 * 					and an optional callback when the frame ENDS. The callback should return a string, which
	 * 					is the next animation to play. If null, the animation will keep playing.
	 */
	public function addAnim(name:String, frames:Array, repeatable:Bool = true ):Void
	{
		var frameVec:Array<FrameData> = new Array<FrameData>(frames.length, true);
		
		for (var i:Int = 0; i < frames.length; i++)
		{
			var fd:FrameData = new FrameData(frames[i][0], frames[i][1], frames[i][2]);
			if (frames[i].length == 4)
			{
				fd.setCallback(frames[i][3]);
			}
			
			frameVec[i] = fd;
		}
		
		var newAnim:Animation = new Animation(name, frameVec, repeatable); 
		anims[name] = newAnim;
	}
	
	public function update():Void
	{
		if (anim == null) return;
		
		if (anim.frames.length == 0) return;
		
		fd = anim.frames[frame];
		
		time += GV.elapsed;
		if (time > fd.time)
		{
			time -= fd.time
			frame++;
			
			if (frame >= anim.length)
			{
				if (anim.repeatable) frame = 0;
				else 				 changeToDefault();
			}
			
			//This should be at the bottom, as fd does not change and changeAnim will muck things up.
			if (fd.callback != null)
			{
				var newAnim:String = fd.callback();
				if (newAnim != null) changeAnim(newAnim);
			}
		}
	}
	
	public function render(x:Int, y:Int):Void
	{
		if (anim == null) return;
		
		if (anim.frames.length == 0) return;
		
		if (anim is GlowAnim)
		{
			fd = anim.frames[frame];
		
			point.x = x;
			point.y = y;
			
			point = point.add(GlowAnim(anim).offset);
			
			rect.x = fd.x * GlowAnim(anim).newW;
			rect.y = fd.y * GlowAnim(anim).newH;
			
			rect.width = GlowAnim(anim).newW;
			rect.height = GlowAnim(anim).newH;
			
			buffer.copyPixels(GlowAnim(anim).bd, rect, point, null, null, true);
			
			rect.width = width;
			rect.height = height;
			return;
		}
		
		fd = anim.frames[frame];
		
		point.x = x;
		point.y = y;
		
		rect.x = fd.x * width  - width + offset.x;
		rect.y = fd.y * height - height + offset.y;
		
		buffer.copyPixels(bitmapData, rect, point, null, null, true);
	}
	
	public function setWidth(width:Int):Void
	{
		this.width = width;
		rect.width = width;
	}
	
	public function setHeight(height:Int):Void
	{
		this.height = height;
		rect.height = height;
	}
	
	public function changeAnim(name:String):Void
	{
		var newAnim:Animation = anims[name];
		if (newAnim == null) throw new Error("Animation with name " + name + " does not exist!");
		changeAnimByObject(newAnim);
	}
	
	public function changeToDefault():Void
	{
		changeAnimByObject(defaultAnim);
	}
	
	 function changeAnimByObject(newAnim:Animation):Void
	{
		frame = 0;
		time = 0;
		anim = newAnim;
	}
	
	public function setOffset(x:Int, y:Int):Void
	{
		if (x <= 0) x += width;
		if (y <= 0) y += height;
		offset.x = x;
		offset.y = y;
	}
	
	public function setDefault(name:String):Void
	{
		defaultAnim = anims[name];
	}
	
	
	public function filterAnim(name:String, filter:BitmapFilter, extraSpaceMult:Float = 1.5):Void
	{
		var oldAnim:Animation = anims[name];
		var strip:BitmapData = new BitmapData(width * extraSpaceMult * oldAnim.length, height * extraSpaceMult, true, 0);
		var newW:Int = width * extraSpaceMult;
		var newH:Int = height * extraSpaceMult;
		var glowOffset:Point = new Point((width - newW)/2, (height - newH)/2);
		
		var r:Rectangle = new Rectangle(0, 0, width, height);
		var p:Point = glowOffset.clone();
		p.x *= -1;
		p.y *= -1;
		
		
		for (var i:Int = 0; i < oldAnim.length; i++)
		{
			trace(r.width);
			trace(r.height);
			r.x = oldAnim.frames[i].x * width - width + offset.x;
			r.y = oldAnim.frames[i].y * height - height + offset.y;
			strip.copyPixels(bitmapData, r, p);
			p.x += newW;
			
			oldAnim.frames[i].x = i;
			
			oldAnim.frames[i].y = 0;
		}
		
		strip.applyFilter(strip, strip.rect, GC.ZERO, filter);
		
		var glow:GlowAnim = new GlowAnim(strip, glowOffset, newW, newH);
		glow.frames = oldAnim.frames;
		glow.length = oldAnim.length;
		glow.name = oldAnim.name;
		glow.repeatable = oldAnim.repeatable;
		
		anims[name] = glow;
	}
}

}


 class FrameData
{
public var x:Int;
public var y:Int;
public var time:Float;
public var callback:Function;

public function FrameData(x:Int, y:Int, time:Float)
{
	this.x = x;
	this.y = y;
	this.time = time;
	callback = null;
}

public function setCallback(callback:Function):Void
{
	this.callback = callback;
}
}

 class Animation
{
public var frames:Array<FrameData>;
public var repeatable:Bool;
public var name:String;
public var length:Int;

public function Animation(name:String, frames:Array<FrameData>, repeatable:Bool)
{
	this.name = name;
	this.frames = frames;
	this.repeatable = repeatable;
	length = frames.length;
}
}

import flash.display.BitmapData;
import flash.geom.Point;

 class GlowAnim extends Animation
{

public var bd:BitmapData;
public var offset:Point;
public var newW:Int;
public var newH:Int;

public function GlowAnim(bd:BitmapData, offset:Point, newW:Int, newH:Int)
{
	super(null, new Array<FrameData>(), true);
	this.bd = bd;
	this.offset = offset;
	this.newW = newW;
	this.newH = newH;
}