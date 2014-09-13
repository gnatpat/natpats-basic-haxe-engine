package net.natpat;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import net.natpat.utils.Key;

/**
 * ...
 * @author Nathan Patel
 */
class Input
{
	
	public static var mousePressed:Bool = false;
	public static var mouseReleased:Bool = false;
	public static var mouseDown:Bool = false;
	
	public function new() 
	{
		
	}
	
	public static function setupListeners():Void
	{
		//Adds keyboard listeners
		GV.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressedEvent);
		GV.stage.addEventListener(KeyboardEvent.KEY_UP,   keyReleasedEvent);
		GV.stage.addEventListener(MouseEvent.MOUSE_DOWN,  mousePressedEvent);
		GV.stage.addEventListener(MouseEvent.MOUSE_UP,    mouseReleasedEvent);
	}
	
	 static function keyPressedEvent(e:KeyboardEvent):Void
	{
		var keyCode:Int = e.keyCode;
		
		if (keyCode < 0 || keyCode > 255) return;
		
		keysDown[keyCode] = true;
		keysPressed[noOfKeysPressed] = keyCode;
		noOfKeysPressed++;
	}
	
	 static function keyReleasedEvent(e:KeyboardEvent):Void
	{
		var keyCode:Int = e.keyCode;
		
		if (keyCode < 0 || keyCode > 255) return;
		
		keysDown[keyCode] = false;
		keysReleased[noOfKeysReleased] = keyCode;
		noOfKeysReleased++;
	}
	
	public static function keyDown(keyCode:Int):Bool
	{
		if (keyCode < 0 || keyCode > 255) return false;
		return keysDown[keyCode];
	}
	
	public static function keyPressed(keyCode:Int):Bool
	{
		if (keyCode < 0 || keyCode > 255) return false;
		for (i in 0...noOfKeysPressed)
		{
			if (keysPressed[i] == keyCode)
			{
				return true;
			}
		}
		return false;
	}
	
	public static function keyReleased(keyCode:Int):Bool
	{
		if (keyCode < 0 || keyCode > 255) return false;
		for (i in 0...noOfKeysReleased)
		{
			if (keysReleased[i] == keyCode)
			{
				return true;
			}
		}
		return false;
	}
	
	 static function mousePressedEvent(e:MouseEvent):Void
	{
		mousePressed = true;
		mouseDown = true;
	}
	
	 static function mouseReleasedEvent(e:MouseEvent):Void
	{
		mouseReleased = true;
		mouseDown = false;
	}
	
	public static function get_mouseX():Int
	{
		return Std.int(GV.stage.mouseX);
	}
	
	public static function get_mouseY():Int
	{
		return Std.int(GV.stage.mouseY);
	}
	
	
	public static function update():Void
	{
		if (mousePressed) {
			mousePressed = false;
		}
		if (mouseReleased) {
			mouseReleased = false;
		}
		while (noOfKeysPressed > 0)
		{
			noOfKeysPressed--;
			keysPressed[noOfKeysPressed] = 0;
		}
		while (noOfKeysReleased > 0)
		{
			noOfKeysReleased--;
			keysPressed[noOfKeysReleased] = 0;
		}
	}
	
	 static var keysDown:Array<Bool> = new Array<Bool>();
	 static var keysPressed:Array<Int> = new Array<Int>();
	 static var keysReleased:Array<Int> = new Array<Int>();
	 static var noOfKeysPressed:Int = 0;
	 static var noOfKeysReleased:Int = 0;
	 static var i:Int;
	 
	 public static var mouseX(get, never):Int;
	 public static var mouseY(get, never):Int;
}
