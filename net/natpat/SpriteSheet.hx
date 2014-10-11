package net.natpat;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.BitmapFilter;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxe.Constraints.Function;
import net.natpat.utils.Animation;
import net.natpat.utils.GlowAnim;
import net.natpat.utils.FrameData;
/**
 * ...
 * @author Nathan Patel
 */

import flash.errors.Error;

class SpriteSheet 
{
private var width:Int;
private var height:Int;
private var offset:Point;

private var anims:Map<String, Animation>;

private var anim:Animation;
private var frame:Int;
private var fd:FrameData;
private var time:Float;

private var defaultAnim:Animation;

private var point:Point;
private var rect:Rectangle;

private var bitmapData:BitmapData;

public var masterScale:Float;

public function new(source:BitmapData, width:Int, height:Int, scale:Float = 1)
{
	this.width = width;
	this.height = height; 
	offset = new Point(0, 0);
	setOffset(0, 0);
	
	anims = new Map<String, Animation>();
	point = new Point();
	
	rect = new Rectangle();
	rect.width = width;
	rect.height = height;
	
	frame = 0;
	time = 0;
	
	bitmapData = source;
	
	addAnim("default", [[0, 0, 5]], true);
	setDefault("default");
	changeAnim("default");
	
	masterScale = scale;
}

public var currentAnim(get, null):String;
 	private function get_currentAnim():String
{
	return anim.name;
}

/**
 * Create a new animation.
 * @param	name	Name of new animation
 * @param	frames	A 2D array - each frame is a array of length 3 or containing x, y, frame length
 * 			and an optional callback when the frame ENDS. The callback should return a string, which
 * 			is the next animation to play. If null, the animation will keep playing.
 */
public function addAnim(name:String, frames:Array<Array<Dynamic>>, repeatable:Bool = true ):Void
{
	var frameVec:Array<FrameData> = new Array<FrameData>();
	
	for (i in 0...frames.length)
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
	time -= fd.time;
	frame++;
	
	if (frame >= anim.length)
	{
		if (anim.repeatable) frame = 0;
		else 		 changeToDefault();
	}
	
	//This should be at the bottom, as fd does not change and changeAnim will muck things up.
	if (fd.callback != null)
	{
		var newAnim:String = fd.callback();
		if (newAnim != null) changeAnim(newAnim);
	}
	}
}


public function render(buffer:BitmapData, x:Int, y:Int, zoom:Bool = false, zoomRatio:Float = 1, centre:Bool = true, otherWay:Bool = false ):Void
{
	if (anim == null) return;
	
	if (anim.frames.length == 0) return;
	
	if (masterScale != 1) zoom = true;
	
	var m:Matrix = new Matrix();
	
	var renderbd:BitmapData;
	var r:Rectangle = new Rectangle();
	
	fd = anim.frames[frame];
	point.x = x;
	point.y = y;
	if (Std.is(anim , GlowAnim))
	{
		var ganim = cast(anim, GlowAnim);
		r.x = fd.x * ganim.newW;
		r.y = fd.y * ganim.newH;
		
		r.width = ganim.newW;
		r.height = ganim.newH;
		
		renderbd = ganim.bd;
	}
	else
	{
		r.x = fd.x * width  - width + offset.x;
		r.y = fd.y * height - height + offset.y;
		r.width = width;
		r.height = height;
		
		renderbd = bitmapData;
	}
	
	point.x -= GV.camera.x - (GC.SCREEN_WIDTH / 2 * GV.zoom);
	point.y -= GV.camera.y - (GC.SCREEN_HEIGHT / 2 * GV.zoom);
	point.x *= 1 /  GV.zoom;
	point.y *= 1 / GV.zoom;
	
	if (zoom)
	{
		var scale:Float = 1 / (zoomRatio * (GV.zoom - 1) + 1);
		
		scale *= masterScale;
		
		r.width *= scale;
		r.height *= scale;
		
		if (centre)
		{
			point.x -= r.width / 2;
			point.y -= r.height / 2;
		}
		
		m.translate( -r.x - r.width / 2, -r.y - r.height / 2);
		m.scale(scale * (otherWay ? -1 : 1), scale);
		m.translate(r.width / 2 * scale * (otherWay ? -1 : 1), r.height / 2 * scale);
		
		m.translate(point.x, point.y);
		
		r.x = point.x;
		r.y = point.y;
		
		buffer.draw(renderbd, m, null, null, r, true);
	}
	else
	{
		if (centre)
		{
			point.x -= r.width / 2;
			point.y -= r.height / 2;
		}
		buffer.copyPixels(renderbd, r, point, null, null, true);
	}
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

public function getWidth():Int
{
	return Std.int(width * masterScale * (masterScale == 1 ? 1 : GV.zoom));
}


public function getHeight():Int
{
	return Std.int(height * masterScale * (masterScale == 1 ? 1 : GV.zoom));
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

private function changeAnimByObject(newAnim:Animation):Void
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
	var strip:BitmapData = new BitmapData(Std.int(width * extraSpaceMult * oldAnim.length), Std.int(height * extraSpaceMult), true, 0);
	var newW:Int = Std.int(width * extraSpaceMult);
	var newH:Int = Std.int(height * extraSpaceMult);
	var glowOffset:Point = new Point((width - newW)/2, (height - newH)/2);
	
	var r:Rectangle = new Rectangle(0, 0, width, height);
	var p:Point = glowOffset.clone();
	p.x *= -1;
	p.y *= -1;
	
	
	for ( i in 0...oldAnim.length)
	{
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