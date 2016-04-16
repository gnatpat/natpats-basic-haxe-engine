package net.natpat.utils ;
import flash.events.TimerEvent;
import net.natpat.GV;
/**
 * ...
 * @author Nathan Patel
 */
class Timer 
{
	
	private static var _t:Timer;
	
	private static function addTimer(t:Timer):Void
	{
		t._next = _t;
		if (t._next != null)
			t._next._prev = t;
		_t = t;
	}
	
	private static function removeTimer(timer:Timer):Void
	{
		if (_t == timer)
			timer = _t._next;
		if (timer._next != null)
			timer._next._prev = timer._prev;
		if (timer._prev != null)
			timer._prev._next = timer._next;
	}
	
	public static function update():Void
	{
		var timer = _t;
		while (timer != null)
		{
			timer._time += GV.elapsed;
			while (timer._duration < timer._time)
			{
				timer._time -= timer._duration;
				timer._iteration++;
				if (timer._tick != null)
					timer._tick();
				if (timer._iteration == timer._repeatCount)
				{
					if(timer._complete != null)
						timer._complete();
					removeTimer(timer);
					break;
				}
			}
			timer = timer._next;
		}
	}
	
	private var _duration:Float = 0;
	private var _repeatCount:Int = 0;
	private var _iteration:Int = 0;
	private var _time:Float = 0;
	
	private var _complete:Void->Void;
	private var _tick:Void->Void;
	
	private var _prev:Timer;
	private var _next:Timer;
	
	private var _started:Bool = false;
	
	/**
	 * Create a new timer
	 * @param	duration 	Duration for each tick in seconds
	 * @param	repeatCount	0 is forever.
	 */
	public function new(duration:Float, repeatCount:Int) 
	{
		_duration = duration;
		_repeatCount = repeatCount;
	}
	
	public function onTick(callback:Void->Void):Void
	{
		_tick = callback;
	}
	
	public function onComplete(callback:Void->Void):Void
	{
		_complete = callback;
	}
	
	public function start():Void
	{
		if (_started)
			trace("Trying to restart an already started timer");
		else
			addTimer(this);
		_time = 0;
	}
	
	public function stop():Void
	{
		removeTimer(this);
	}
	
}