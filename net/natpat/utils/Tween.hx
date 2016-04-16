package net.natpat.utils;

import net.natpat.GV;
/**
 * ...
 * @author Nathan Patel
 */
class Tween 
{
	
	private static var tween:Tween = null;
	
	public static function addTween(newTween:Tween):Void
	{
		newTween.next = tween;
		newTween.prev = null;
		if (newTween.next != null) newTween.next.prev = newTween;
		tween = newTween;
	}
	
	private static function removeTween(t:Tween):Void
	{
		if (tween == t)
			tween = t.next;
		if (t.prev != null)
			t.prev.next = t.next;
		if (t.next != null)
			t.next.prev = t.prev;
	}
	
	public static function update():Void
	{
		var t:Tween = tween;
		var elapsed:Float = GV.elapsed;
		while (t != null)
		{
			if (!t.enabled)
			{
				t = t.next;
				continue;
			}
			t.time += elapsed;
            t.func(t.ease(t.time/t.length));
			if (t.repeatable)
			{
				while (t.time > t.length)
				{
					t.time -= t.length;
					if(t.callback != null) t.callback();
				}
			}
			
			if (t.time >= t.length)
			{
				t.time = t.length;
				if (t.callback != null) t.callback();
				removeTween(t);
			}
			t = t.next;
		}
	}

	private var time:Float = 0;

	private var func:Float->Void = null;
	private var callback:Void->Void = null;
	
	private var length:Float;
	private var ease:Float->Float;
	private var repeatable:Bool;

	private var next:Tween;
	private var prev:Tween;

	private var enabled:Bool;
	private var started:Bool;
	
	public function new(length:Float, ?ease:Float->Float = null, ?repeatable:Bool = false)
	{
		(ease == null) ? this.ease = Ease.none : this.ease = ease;
		
		this.length = length;
        this.repeatable = repeatable;
		
		started = false;
		enabled = true;
	}
	
	public function onTick(func:Float->Void):Void
	{
		this.func = func;
	}
	
	public function onComplete(callback:Void->Void):Void
	{
		this.callback = callback;
	}
	
	public function start():Void
	{
		if(!started)
			addTween(this);
	}
	
	public function stop():Void
	{
		removeTween(this);
	}
	
	public function disable(id:Int):Void
	{
		enabled = false;
	}
	
	public function enable(id:Int):Void
	{
		enabled = true;
	}

}