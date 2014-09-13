package net.natpat.utils;

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import net.natpat.Assets;

/**
 * ...
 * @author Nathan Patel
 */
class Sfx 
{
	
	 var sound:Sound;
	
	 var soundChannel:SoundChannel;
	
	 var soundTransform:SoundTransform;
	
	 var position:Float;
	
	 var loop:Bool;
	
	/**
	 * Create a new sound object, 
	 * @param	soundFile
	 */
	public function new(soundFile:Dynamic, loop:Bool = false) 
	{
		//NEED TO WORK OUT HOW TO DO THIS IN HAXE!
		//sound = new soundFile;
		//soundChannel = new SoundChannel();
		position = 0;
		soundTransform = new SoundTransform();
	}
	
	public function play(boolloop:Bool = false):Void
	{
		loop = boolloop;
		soundChannel = sound.play(position, 0);
		soundChannel.soundTransform = soundTransform;
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
		soundTransform.volume = volume;
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