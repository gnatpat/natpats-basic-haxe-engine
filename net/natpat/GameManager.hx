package net.natpat;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import net.natpat.gui.Button;
import net.natpat.gui.InputBox;
import net.natpat.particles.Emitter;
import net.natpat.utils.Sfx;

import net.natpat.gui.Text;
import net.natpat.gui.GuiManager;
import net.natpat.utils.Ease;
import net.natpat.utils.Key;

/**
 * ...
 * @author Nathan Patel
 */
class GameManager 
{
	/**
	 * Bitmap and bitmap data to be drawn to the screen.
	 */
	public var bitmap:Bitmap;
	public static var renderer:BitmapData;
	
	public var text:Text = new Text(10, 10, "Hello, World!", 20, 0xff000000);
	public var emitter:Emitter = new Emitter(new BitmapData(4, 4, true, 0xffffffff));
	
	public var input:InputBox = new InputBox(10, 100, "", 200, 30, 18);
	
	public function new(stageWidth:Int, stageHeight:Int) 
	{
		GC.SCREEN_WIDTH = stageWidth;
		GC.SCREEN_HEIGHT = stageHeight;
		
		renderer = new BitmapData(stageWidth, stageHeight, false, 0x000000);
		
		bitmap = new Bitmap(renderer);
		
		GV.screen = renderer;
		
		GuiManager.add(text);
		GuiManager.add(input);
		
		emitter.setColor(0xff0000, 0x00cccc);
		emitter.setMotion(0, 125, 5, 360, 25, 0.5, Ease.quintOut);
		emitter.setAlpha(1, 0, Ease.cubeIn);
		emitter.setEmitTime(0.02, 0);
		emitter.setSizeChange(1, 0, Ease.quintIn);
		emitter.startEmitting();
	}
	
	public function render():Void
	{
		renderer.lock();
		
		//Render the background
		renderer.fillRect(new Rectangle(0, 0, renderer.width, renderer.height), 0xffffff);
		
		emitter.render();
		
		GuiManager.render();
		
		renderer.unlock();
	}
	
	public function update():Void
	{
		GuiManager.update();
		
		emitter.x = Input.mouseX;
		emitter.y = Input.mouseY;
		
		emitter.update();
		
		Input.update();
	}
	
}