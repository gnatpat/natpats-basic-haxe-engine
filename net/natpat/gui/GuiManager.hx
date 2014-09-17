package net.natpat.gui;


import net.natpat.gui.IGuiElement;
import openfl.display.BitmapData;

/**
 * ...
 * @author Nathan Patel
 */
class GuiManager 
{
	
	
	 static var elements:Array<IGuiElement> = new Array<IGuiElement>();
	
	public function new() 
	{
		
	}
	
	public static function add(element:IGuiElement, depth:Int = 0):IGuiElement
	{
		if (depth == 0)
		{
			elements.push(element);
		} 
		else if (depth == -1)
		{
			elements.unshift(element);
		}
		element.add();
		return element;
	}
	
	public static function remove(element:IGuiElement):IGuiElement
	{
		var index:Int = elements.indexOf(element);
		if (index == -1)
		{
			trace("No element to remove");
			return element;
		}
		elements[index].remove();
		elements.splice(index, 1);
		return element;
	}
	
	public static function update():Void
	{
		for (i in 0...elements.length)
		{
			elements[i].update();
		}
	}
	
	public static function render(buffer:BitmapData):Void
	{
		for (i in 0...elements.length)
		{
			elements[i].render(buffer);
		}
	}
	
	 static var i:Int;
	
}
