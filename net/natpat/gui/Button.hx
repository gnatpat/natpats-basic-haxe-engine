package net.natpat.gui; 

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import net.natpat.GV;
import net.natpat.Input;
/**
 * ...
 * @author Nathan Patel
 */
class Button implements IGuiElement 
{
	/**
	 * Function executed when the mouse is released over the button
	 */
	public var releasedFunction:Dynamic;
	
	/**
	 * Various rectangles, used for displaying various graphics
	 */
	var normalRect : Rectangle;
	var backRect : Rectangle;
	var overRect : Rectangle;
	var pressedRect : Rectangle;
	var releasedRect : Rectangle;
	
	/**
	 * Whether or not the button has a background, or the dynamic 'button' part
	 */
	 var hasBack:Bool = true;
	
	/**
	 * Whether or not the button has an icon, which is rendered over the back
	 */
	 var hasIcon:Bool = false;
	
	 var hasText:Bool = false;
	
	 var bitmapData:BitmapData;
	 var renderLocation:Point;
	 var textOverlay:Text;
	
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	
	 var clipRectangle:Rectangle;
	
	/**
	 * Constructor. Used to set the image, functions and position of the button.
	 * @param	x					X position of button
	 * @param	y					Y position of button
	 * @param	width				Width of the button
	 * @param	height				Height of the button
	 * @param	_releasedFunction	Function to be executed when mouse is released on button
	 * @param	backIndex			Index of the standard background
	 * @param	overIndex			Index of the image to be shown when the mouse is over the button
	 * @param	pressedIndex		Index of the image to be shown when the mouse is pressed on the button
	 * @param	releasedIndex		Index of the image to be shown when the mouse is released
	 * @param	imageIndex			Index of the icon for the button
	 * @param	asset				The name of the asset is Assets to use for this button
	 */
	 
	public function new(source:BitmapData, x:Int, y:Int, width:Int, height:Int, releasedFunction:Void->Void, backIndex:Int = -1, overIndex:Int = -1, pressedIndex:Int = -1, releasedIndex:Int = -1, imageIndex:Int = -1)
	{
		this.x = x;
		this.y = y;
		
		this.width = width;
		this.height = height;
		
		renderLocation = new Point(x, y);
		
		bitmapData = source;
		
		var bWidth:Int = bitmapData.width;
		
		//If the button has an icon, create a clip rectangle for it
		if (imageIndex != -1)
		{
			hasIcon = true;
			normalRect = new Rectangle((imageIndex % (bWidth / width)) * width, (Std.int(imageIndex / (bWidth / width))) * height, width, height);
		}
		
		//If the button doesn't have a back, don't create clip rectangles for them.
		if (backIndex == -1)
		{
			hasBack = false;
		}
		
		//Create clip rectangles for the rest of the back states.
		if (hasBack)
		{
			if (overIndex == -1)
			{
				overIndex = backIndex;
			}
			if (pressedIndex == -1)
			{
				pressedIndex = backIndex;
			}
			if (releasedIndex == -1)
			{
				releasedIndex = backIndex;
			}
			
			backRect = new Rectangle((backIndex % (bWidth / width)) * width, (Std.int(backIndex / (bWidth / width))) * height, width, height);
			overRect = new Rectangle((overIndex % (bWidth / width)) * width, (Std.int(overIndex / (bWidth / width))) * height, width, height);
			pressedRect = new Rectangle((pressedIndex % (bWidth / width)) * width, (Std.int(pressedIndex / (bWidth / width))) * height, width, height);
			releasedRect = new Rectangle((releasedIndex % (bWidth / width)) * width, (Std.int(releasedIndex / (bWidth / width))) * height, width, height);
			clipRectangle = backRect;
		}
		
		//Set released function
		this.releasedFunction = releasedFunction;
	}
	
	public function render(buffer:BitmapData):Void 
	{
		//If the button has a back render it
		if (hasBack)
		{
			buffer.copyPixels(bitmapData, clipRectangle, renderLocation, null, null, true);
		}
		//If the button has an icon render that too over the top. Fun.
		if (hasIcon)
		{
			buffer.copyPixels(bitmapData, normalRect, renderLocation, null, null, true);
		}
		if (hasText)
		{
			textOverlay.render(buffer);
		}
	}
	
	public function update():Void 
	{
		
		//Resets the clip rectangle
		clipRectangle = backRect;
		
		//If the mouse is over the button display funky graphics by changing the clip rectangle!
		if (GV.pointInRect(Input.mouseX, Input.mouseY, x, y, width, height))
		{
			if (Input.mouseDown)
			{
				clipRectangle = pressedRect;
			}
			else if (Input.mouseReleased)
			{
				clipRectangle = releasedRect;
				releasedFunction();
			}
			else
			{
				clipRectangle = overRect;
			}
		}
		
		renderLocation.x = x;
		renderLocation.y = y;
		
		if (hasText)
		{
			textOverlay.x = x + ((width - textOverlay.width) / 2);
			textOverlay.y = y + ((height - textOverlay.height) / 2) + 4;
		}
	}
	
	public function setText(text:String, textSize:Int = 18):Void
	{
		textOverlay = new Text(x, y, text, textSize);
		hasText = true;
	}
	
	public function add():Void 
	{
		
	}
	
	public function remove():Void 
	{
		
	}
	
}