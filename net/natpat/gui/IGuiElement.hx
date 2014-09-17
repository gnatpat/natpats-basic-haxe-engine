package net.natpat.gui;
import openfl.display.BitmapData;


/**
 * ...
 * @author Nathan Patel
 */
interface IGuiElement
{
	function render(buffer:BitmapData):Void;
	
	function update():Void;
	
	function add():Void;
	
	function remove():Void;
	
}

