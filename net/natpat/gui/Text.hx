package net.natpat.gui;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.filters.GlowFilter;
import flash.filters.BitmapFilterQuality;
import openfl.filters.BitmapFilter;
import flash.utils.ByteArray;
import net.natpat.gui.IGuiElement;
import net.natpat.GV;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import net.natpat.GC;
import flash.text.TextFieldType;

/**
 * Quick and dirty rendering of the text to the screen
 * 
 * TO USE MAKE SURE THE EMBED STATEMENT BELOW LINKS TO THE CORRECT FONT
 * @author Nathan Patel
 */
class Text implements IGuiElement
{
	/*[Embed(source = "../utils/Volter__28Goldfish_29.ttf", embedAsCFF="false", fontFamily = 'default', mimeType='application/x-font')]
	 static const VISITOR_FONT:Class;*/
	
	/**
	 * The font to assign to new Text objects.
	 */
	public static var font:String = "default";
	
	/**
	 * The font GC.SIZE to assign to new Text objects. If using Visitor set to a multiple of 13!
	 */
	public static var SIZE:UInt = 18;
	
	/**
	 * x location of the text
	 */
	public var x:Float;
	
	/**
	 * y location of the text
	 */
	public var y:Float;
	
	/**
	 * Colour of the text
	 */
	public var colour:UInt;
	
	/**
	 * The place on the bitmap data to take the Thing's graphic from
	 */
	public var clipRectangle:Rectangle;
	
	 var xCentre:Bool = false;
	 var yCentre:Bool = false;
	/**
	 * A component with dynamic text.
	 * @param	x				x location of component
	 * @param	y				y location of component
	 * @param	_getTextString	Function that returns the string to display
	 * @param	... args		Arguments to pass to the function
	 */
	public function new(x:Int, y:Int, text:String, size:Int = 16, colour:UInt = 0xff000000)
	{
		this.x = x;
		this.y = y;
		
		originalCoords = new Point(x, y);
		
		if (x == -1)
		{
			xCentre = true;
		}
		if (y == -1)
		{
			yCentre = true;
		}
		
		//Gets the font and GC.SIZE from the static variables and puts them into local ones, so the font and GC.SIZE are "saved"
		_font = font;
		_SIZE = SIZE;
		
		//Create the text format.
		_form = new TextFormat(_font, size, colour);
		
		//Set the TextField to use embedded fonts, so we can use Visitor
		//_field.embedFonts = true;
		
		//Set the antiAlias type to Advanced, so we can set sharpness so the font isn't yucky and blurry
		_field.antiAliasType = AntiAliasType.ADVANCED;
		_field.sharpness = 400;
		
		//Set the text in the text field.
		_field.text = _text = text;
		
		//Set the width and height for rendering
		_width = 4;
		_height = 4;
		
		//Create a new bitmap data for rendering the textField to
		unscaledBitmapData = new BitmapData(_width, _height, true, 0);
		bitmapData = new BitmapData(1, 1);
		
		clipRectangle = unscaledBitmapData.rect;
		//Update the text object
		updateGraphic();
	}
	
	public function drawOutline(colour:UInt = 0xff000000):Void
	{
		//Add the black outline
		var outline:GlowFilter = new GlowFilter();
		outline.blurX = outline.blurY = 1.6;
		outline.color = colour;
		outline.quality = 1;
		outline.strength = 250;
	
		var filterArray:Array<BitmapFilter> = new Array<BitmapFilter>();
		filterArray.push(outline);
		_field.filters = filterArray;
		updateGraphic();
	}
	
	public function setScale(s:Int):Void
	{
		scale = s;
		updateGraphic();
	}
	
	public function set_text(newText:String):String
	{
		_field.text = _text = newText;
		updateGraphic();
		return newText;
	}
	
	public function get_text():String
	{
		
		return _field.text;
	}
	
	public function updateGraphic():Void
	{
		//Set the textField's formatter to _form
		_field.setTextFormat(_form);
		
		//For testing purposes, set _textWidth and height to how big the text field actually needs to be
		_textWidth = Std.int(_field.textWidth + 4);
		_textHeight = Std.int(_field.textHeight + 8);
		
		_width = _textWidth;
		_height = _textHeight;
		
		unscaledBitmapData = new BitmapData(_width, _height, true, 0);
		
		//Set the text field's width and height to width and height so edges of text doesn't get clipped off
		_field.width = _width;
		_field.height = _height;
		
		//Finally, draw the text field to bitmapData
		unscaledBitmapData.draw(_field);
		
		var matrix:Matrix = new Matrix();
		matrix.scale(scale, scale);

		bitmapData = new BitmapData(unscaledBitmapData.width * scale, unscaledBitmapData.height * scale, true, 0x000000);
		bitmapData.draw(unscaledBitmapData, matrix, null, null, null, false);
		
		clipRectangle = bitmapData.rect;
		
		this.x = xCentre? (GC.SCREEN_WIDTH - bitmapData.width) / 2 : this.x;
		this.y = yCentre? (GC.SCREEN_HEIGHT - bitmapData.height) / 2 : this.y;
	}
	
	public function render(buffer:BitmapData):Void
	{
		if (bitmapData == null) return; 
		renderLocation.x = x;
		renderLocation.y = y;
		buffer.copyPixels(bitmapData, clipRectangle, renderLocation, null, null, true);
	}
	
	public function update():Void
	{
		if (xCentre)
		{
			x = (GC.SCREEN_WIDTH - bitmapData.width) / 2;
		}
		if (yCentre)
		{
			y = (GC.SCREEN_HEIGHT - bitmapData.height) / 2;
		}
		
	}
	
	public function add():Void
	{
		updateGraphic();
	}
	
	public function remove():Void
	{
	}
	
	public function get_width():Int
	{
		return bitmapData.width;
	}
	
	public function get_height():Int
	{
		return bitmapData.height;
	}
	
	var _field:TextField = new TextField();
	var _width:UInt;
	var _height:UInt;
	var _textWidth:UInt;
	var _textHeight:UInt;
	var _form:TextFormat;
	var _text:String;
	var _font:String;
	var _SIZE:UInt;
	var scale = 1;
    var renderLocation:Point = new Point();
    var unscaledBitmapData:BitmapData;
    var bitmapData:BitmapData;
    var originalCoords:Point;
    var text(get, set):String;
    public var width(get, never):Int;
    public var height(get, never):Int;
}