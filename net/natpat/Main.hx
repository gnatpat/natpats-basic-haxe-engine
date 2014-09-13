package net.natpat;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;


import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.display.StageDisplayState;

/**
 * ...
 * @author Nathan Patel
 */

class Main extends Sprite 
{
	var game:GameManager;
		
		/**
	 * Time at the beginning of the previous frame
	 */
	var prevTime:Int;
	
	var currentTime:Int;
	
	var inited:Bool;

	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;

		// (your code here)
		
		//Set GV.stage to the stage, for easier access
		GV.stage = stage;
		
		game = new GameManager(stage.stageWidth, stage.stageHeight);
		
		//Add the game bitmap to the screen
		addChild(game.bitmap);
		
		//Create the main game loop
		addEventListener(Event.ENTER_FRAME, run);
		Input.setupListeners();
		stage.align = StageAlign.TOP_LEFT;
		stage.quality = StageQuality.HIGH;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.displayState = StageDisplayState.NORMAL;
	}
	
	 function run(e:Event):Void
	{
		//Works out GV.elapsed, or how many milliseconds have passed since the last frame
		currentTime = flash.Lib.getTimer();
		GV._elapsed = (currentTime - prevTime) / 1000;
		prevTime = currentTime;
		
		game.update();
		game.render();
		
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
