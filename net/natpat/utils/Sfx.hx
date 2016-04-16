package net.natpat.utils;

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import openfl.Assets;

/**
 * ...
 * @author Nathan Patel
 */
class Sfx 
{
	
	 var sound:Sound;
	
	 var soundChannel:SoundChannel;
	
	 var position:Float;
	
	 var loop:Bool;
	
	/**
	 * Create a new sound object, 
	 * @param	soundFile
	 */
	public function new(soundPath:String) 
	{
		sound = Assets.getSound(soundPath);
		position = 0;
	}
	
	public function play(?loop:Bool = false):Void
	{
		this.loop = loop;
		soundChannel = sound.play(position, 0);
		soundChannel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
	}
	
	public function pause():Void
	{
		position = soundChannel.position;
		soundChannel.stop();
	}
	
	public function stop():Void
	{
		soundChannel.stop();
		position = 0;
	}
	
	public function setVolume(volume:Float):Void
	{
		var st = soundChannel.soundTransform;
		st.volume = volume;
		soundChannel.soundTransform = st;
	}
	
	 function soundComplete(e:Event):Void
	{
		stop();
		if (loop)
		{
			play(true);
		}
	}
	
}