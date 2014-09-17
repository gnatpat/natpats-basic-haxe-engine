package net.natpat.particles;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.natpat.GV;
import net.natpat.GC;

/**
 * Particle emitter used for emitting and rendering particle sprites.
 * Good rendering performance with large amounts of particles.
 */
class Emitter
{
	public var x:Int = 0;
	public var y:Int = 0;
	
	public var particleCount(get, never):UInt;
	
	/**
	 * Constructor. Sets the source image to use for newly added particle types.
	 * @param	source			Source image.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 */
	public function new(source:BitmapData, frameWidth = 0, frameHeight = 0) 
	{
		setSource(source, frameWidth, frameHeight);
	}
	
	/**
	 * Changes the source image to use for newly added particle types.
	 * @param	source			Source image.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 */
	public function setSource(source:BitmapData, frameWidth = 0, frameHeight = 0):Void
	{
		this.source = source;
		width = source.width;
		height = source.height;
		frameWidth = frameWidth != 0 ? frameWidth : width;
		frameHeight = frameHeight != 0 ? frameHeight : height;
		frameCount = Std.int(width / frameWidth) * Std.int(height / frameHeight);
		frame = new Rectangle(0, 0, frameWidth, frameHeight);
	}
	
	public function setFrameLength(length:Float, range:Float, reverseChance:Float = 0)
	{
		frameLength = length;
		frameLengthRange = range;
		this.reverseChance = reverseChance;
	}
	
	public function startEmitting():Void
	{
		timer = 0;
		timeToGetTo = 0;
		emitOnTimer = true;
	}
	
	public function stopEmitting():Void
	{
		emitOnTimer = false;
	}
	
	public function update():Void 
	{
		if (emitOnTimer)
		{
			timer += GV.elapsed;
			while (timer > timeToGetTo)
			{
				emit();
				timer -= timeToGetTo;
				timeToGetTo = time + timeRange * Math.random();
			}
		}
		
		
		// quit if there are no particles
		if (particle == null) return;
		
		// particle info
		var e:Float = GV.elapsed,
			p:Particle = particle,
			n:Particle;
		
		// loop through the particles
		while (p != null)
		{
			// update time scale
			p.time += e;
			
			// remove on time-out
			if (p.time >= p.duration)
			{
				if (p.next != null) p.next.prev = p.prev;
				if (p.prev != null) p.prev.next = p.next;
				else particle = p.next;
				n = p.next;
				p.next = cache;
				p.prev = null;
				cache = p;
				p = n;
				_particleCount --;
				continue;
			}
			
			// get next particle
			p = p.next;
		}
	}
	
	/** @ Renders the particles. */
	public function render():Void 
	{
		// quit if there are no particles
		if (particle == null) return;
		
		// get rendering position
		point.x = x;
		point.y = y;
		
		// particle info
		var t:Float, td:Float,
			p:Particle = particle,
			rect:Rectangle;
		
		// loop through the particles
		while (p!= null)
		{
			// get time scale
			t = p.time / p.duration;
			
			// get position
			td = (ease == null) ? t : ease(t);
			pp.x = p.x + p.xVel * td;
			pp.y = p.y + p.yVel * td + p.gravity * td * td;
			
			// get frame
			var frameOn = Std.int(p.time / p.frameLength) % frameCount;
			frameOn = p.reversed ? frameCount - frameOn - 1 : frameOn;
			frame.x = frame.width * frameOn;
			frame.y = Std.int(frame.x / width) * frame.height;
			frame.x %= width;
			// draw particle
			if (buffer!= null)
			{
				// get alpha
				var alphaT:Float = (alphaEase == null) ? t : alphaEase(t);
				tint.alphaMultiplier = alpha + alphaRange * alphaT;
				
				// get color
				td = (colorEase == null) ? t : colorEase(t);
				tint.redMultiplier = red + redRange * td;
				tint.greenMultiplier = green + greenRange * td;
				tint.blueMultiplier  = blue + blueRange * td;
				
				//apply changes
				buffer.fillRect(bufferRect, 0);
				buffer.copyPixels(source, frame, GC.ZERO);
				buffer.colorTransform(bufferRect, tint);
				
				var sizeT:Float = (sizeEase == null) ? t : sizeEase(t);
				var scale:Float = size + sizeRange * sizeT;
				if (scale != 1)
				{
					GV.screen.copyPixels(scaleBitmapData(buffer, scale), sizeBufferRect, pp, null, null, true);
				}
				else
				{
					// draw particle
					GV.screen.copyPixels(buffer, bufferRect, pp, null, null, true);
				}
			}
			else GV.screen.copyPixels(source, frame, pp, null, null, true);
			
			// get next particle
			p = p.next;
		}
	}
	
	/**
	 * Defines the motion range for a particle type.
	 * @param	name			The particle type.
	 * @param	angle			Launch Direction.
	 * @param	distance		Distance to travel.
	 * @param	duration		Particle duration.
	 * @param	angleRange		Random amount to add to the particle's direction.
	 * @param	distanceRange	Random amount to add to the particle's distance.
	 * @param	durationRange	Random amount to add to the particle's duration.
	 * @param	ease			Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setMotion(angle:Float, distance:Float, duration:Float, angleRange:Float = 0, distanceRange:Float = 0, durationRange:Float = 0, ease:Float->Float = null):Emitter
	{
		this.angle = angle * GV.RAD;
		this.distance = distance;
		this.duration = duration;
		this.angleRange = angleRange * GV.RAD;
		this.distanceRange = distanceRange;
		this.durationRange = durationRange;
		this.ease = ease;
		return this;
	}
	
	/**
	 * Sets the gravity range for a particle type.
	 * @param	name			The particle type.
	 * @param	gravity			Gravity amount to affect to the particle y velocity.
	 * @param	gravityRange	Random amount to add to the particle's gravity.
	 * @return	This ParticleType object.
	 */
	public function setGravity(gravity:Float = 0, gravityRange:Float = 0):Emitter
	{
		this.gravity = gravity;
		this.gravityRange = gravityRange;
		return this;
	}
	
	/**
	 * Sets the alpha range of the particle type.
	 * @param	name		The particle type.
	 * @param	start		The starting alpha.
	 * @param	finish		The finish alpha.
	 * @param	ease		Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setAlpha(start:Float = 1, finish:Float = 0, ease:Float->Float = null):Emitter
	{
		start = start < 0 ? 0 : (start > 1 ? 1 : start);
		finish = finish < 0 ? 0 : (finish > 1 ? 1 : finish);
		alpha = start;
		alphaRange = finish - start;
		alphaEase = ease;
		createBuffer();
		return this;
	}
	
	/**
	 * Sets the color range of the particle type.
	 * @param	name		The particle type.
	 * @param	start		The starting color.
	 * @param	finish		The finish color.
	 * @param	ease		Optional easer function.
	 * @return	This ParticleType object.
	 */
	public function setColor(start:UInt = 0xFFFFFF, finish:UInt = 0, ease:Float->Float = null):Emitter
	{
		start &= 0xFFFFFF;
		finish &= 0xFFFFFF;
		red = (start >> 16 & 0xFF) / 255;
		green = (start >> 8 & 0xFF) / 255;
		blue = (start & 0xFF) / 255;
		redRange = (finish >> 16 & 0xFF) / 255 - red;
		greenRange = (finish >> 8 & 0xFF) / 255 - green;
		blueRange = (finish & 0xFF) / 255 - blue;
		colorEase = ease;
		createBuffer();
		return this;
	}
	
	public function setSizeChange(start:Float = 1, finish:Float = 0, ease:Float->Float = null):Emitter
	{
		start = start < 0 ? 0 : start;
		finish = finish < 0 ? 0 : finish;
		size = start;
		sizeRange = finish - start;
		sizeEase = ease;
		createBuffer();
		return this;
	}
	
	
	public function setEmitTime(time:Float, timeRange:Float):Emitter
	{
		this.time = time;
		this.timeRange = timeRange;
		return this;
	}
	
	/**
	 * Emits a particle.
	 * @param	name		Particle type to emit.
	 * @param	x			X point to emit from.
	 * @param	y			Y point to emit from.
	 * @return
	 */
	public function emit(x:Int = 0, y:Int = 0):Particle
	{
		var p:Particle;
		
		if (cache != null)
		{
			p = cache;
			cache = p.next;
		}
		else p = new Particle();
		p.next = particle;
		p.prev = null;
		if (p.next != null) p.next.prev = p;
		
		p.time = 0;
		p.duration = duration + durationRange * Math.random();
		var a:Float = angle + angleRange * Math.random(),
			d:Float = distance + distanceRange * Math.random();
		p.xVel = Math.cos(a) * d;
		p.yVel = Math.sin(a) * d;
		p.x = this.x + x;
		p.y = this.y + y;
		p.gravity = gravity + gravityRange * Math.random();
		p.reversed = (Math.random() < reverseChance);
		p.frameLength = frameLength + Math.random() * frameLengthRange;
		_particleCount ++;
		return (particle = p);
	}
	
	
	/** @ Creates the buffer if it doesn't exist. */
	 function createBuffer():Void
	{
		if (buffer != null) return;
		buffer = new BitmapData(Std.int(frame.width), Std.int(frame.height), true, 0);
		bufferRect = buffer.rect;
		sizeBuffer = new BitmapData(Std.int(frame.width), Std.int(frame.height), true, 0);
		sizeBufferRect = sizeBuffer.rect;
	}
	
	 function scaleBitmapData(bitmapData:BitmapData, scale:Float):BitmapData 
	{
		var width:Int = bitmapData.width;
		var height:Int = bitmapData.height;
		sizeBuffer.fillRect(sizeBufferRect, 0);
		var matrix:Matrix = new Matrix();
		matrix.translate( -width / 2, -height / 2);
		matrix.scale(scale, scale);
		matrix.translate(width / 2, height / 2);
		sizeBuffer.draw(bitmapData, matrix, null, null, null, true);
		return sizeBuffer;
	}
	
	/**
	 * Amount of currently existing particles.
	 */
	public function get_particleCount():UInt { return _particleCount; }
	
	// Particle information.
	/** @ */  var particle:Particle;
	/** @ */  var cache:Particle;
	/** @ */  var _particleCount:UInt = 0;
	
	// Source information.
	/** @ */  var source:BitmapData;
	/** @ */  var width:UInt;
	/** @ */  var height:UInt;
	/** @ */  var frameWidth:UInt;
	/** @ */  var frameHeight:UInt;
	/** @ */  var frameCount:UInt;
	/** @ */  var frame:Rectangle;
	
	//Frame length info
	/** @ */  var frameLength:Float = 0.1;
	/** @ */  var frameLengthRange:Float = 0;
	/** @ */  var reverseChance = 0.0;
	
	
	// Drawing information.
	/** @ */  var pp:Point = new Point();
	/** @ */  var point:Point = new Point();
	/** @ */  var tint:ColorTransform = new ColorTransform();
	
	// Motion information.
	/** @ */  var angle:Float;
	/** @ */  var angleRange:Float;
	/** @ */  var distance:Float;
	/** @ */  var distanceRange:Float;
	/** @ */  var duration:Float;
	/** @ */  var durationRange:Float;
	/** @ */  var ease:Float->Float;
	
	// Gravity information.
	/** @ */  var gravity:Float = 0;
	/** @ */  var gravityRange:Float = 0;
	
	// Alpha information.
	/** @ */  var alpha:Float = 1;
	/** @ */  var alphaRange:Float = 0;
	/** @ */  var alphaEase:Float->Float;
	
	// Color information.
	/** @ */  var red:Float = 1;
	/** @ */  var redRange:Float = 0;
	/** @ */  var green:Float = 1;
	/** @ */  var greenRange:Float = 0;
	/** @ */  var blue:Float = 1;
	/** @ */  var blueRange:Float = 0;
	/** @ */  var colorEase:Float->Float;
	
	// Size information.
	/** @ */  var size:Float = 1;
	/** @ */  var sizeRange:Float = 0;
	/** @ */  var sizeEase:Float->Float;
	
	//Time information.
	/** @ */  var time:Float = 0;
	/** @ */  var timeRange:Float = 0;
	/** @ */  var timer:Float;
	/** @ */  var timeToGetTo:Float;
	/** @ */  var emitOnTimer:Bool = false;
	
	// Buffer information.
	/** @ */  var sizeBuffer:BitmapData;
	/** @ */  var sizeBufferRect:Rectangle;
	// Buffer information.
	/** @ */  var buffer:BitmapData;
	/** @ */  var bufferRect:Rectangle;
}
