package net.natpat.gui;

import flash.text.TextField;
import flash.text.TextFormat;
import net.natpat.GV;
import net.natpat.GC;
import flash.text.AntiAliasType;
import net.natpat.Input;
import net.natpat.gui.IGuiElement;
import flash.text.TextFieldType;

/**
 * ...
 * @author Nathan Patel
 */
class InputBox implements IGuiElement
{
	
	public var inputField:TextField;
	
	 var textForm:TextFormat;
	
	public var defaultText:String;
	
	 var xCentre:Bool = false;
	 var yCentre:Bool = false;
	
	public var x(get, set):Int;
	public var y(get, set):Int;
	
	public var text(get, never):String;
	
	public function new(x:Int, y:Int, defaultText:String = "", width:Int = 200, height:Int = 30, size:Int = 18) 
	{
		inputField = new TextField();
		
		textForm = new TextFormat("default", size, 0xff000000);
		inputField.defaultTextFormat = textForm;
		
		inputField.x = x == -1? (GC.SCREEN_WIDTH - width) / 2 : x;
		inputField.y = y == -1? (GC.SCREEN_HEIGHT - height) / 2 : y;
		
		if (x == -1)
		{
			xCentre = true;
		}
		if (y == -1)
		{
			yCentre = true;
		}
		
		inputField.width = width;
		inputField.height = height;
		
		inputField.border = true;
		inputField.type = TextFieldType.INPUT;
		inputField.text = defaultText;
		inputField.background = true;
		inputField.antiAliasType = AntiAliasType.ADVANCED;
		inputField.sharpness = 400;
		
		this.defaultText = defaultText;
	}
	
	public function get_x():Int
	{
		return Std.int(inputField.x);
	}
	
	public function get_y():Int
	{
		return Std.int(inputField.y);
	}
	
	public function set_x(_x:Int):Int
	{
		return Std.int(inputField.x = _x);
	}
	
	public function set_y(_y:Int):Int
	{
		return Std.int(inputField.y = _y);
	}
	
	public function get_text():String
	{
		return inputField.text;
	}
	
	public function render():Void 
	{
		
	}
	
	public function update():Void 
	{
		if (inputField.text == "" && GV.stage.focus != inputField)
		{
			inputField.text = defaultText;
		}
		if (inputField.text == defaultText)
		{
			inputField.textColor = 0x999999;
			if (GV.stage.focus == inputField) {
				inputField.text = "";
				inputField.textColor = 0x000000;
			}
		} 
		else
		{
			inputField.textColor = 0x000000;
		}
		
		if (xCentre)
		{
			inputField.x = (GC.SCREEN_WIDTH - inputField.width) / 2;
		}
		if (yCentre)
		{
			inputField.y = (GC.SCREEN_HEIGHT - inputField.height) / 2;
		}
		
	}
	
	public function add():Void 
	{
		GV.stage.addChild(inputField);
	}
	
	public function remove():Void 
	{
		GV.stage.removeChild(inputField);
	}
}