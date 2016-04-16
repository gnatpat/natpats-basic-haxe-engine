package net.natpat;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import net.natpat.gui.Button;
import net.natpat.gui.InputBox;
import net.natpat.particles.Emitter;
import net.natpat.utils.PerformanceManager;
import net.natpat.utils.Sfx;
import net.natpat.utils.Timer;
import net.natpat.utils.Tween;
import openfl.geom.Point;

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
	public var screen:BitmapData;
	
	public var guiBuffer:BitmapData;
	
	private var fps:Text = new Text(10, 10, "");
	
	public function new(stageWidth:Int, stageHeight:Int) 
	{
		GC.SCREEN_WIDTH = stageWidth;
		GC.SCREEN_HEIGHT = stageHeight;
		
		screen = new BitmapData(stageWidth, stageHeight, false, 0x000000);
		
		guiBuffer = new BitmapData(stageWidth, stageHeight, true, 0);
		
		bitmap = new Bitmap(screen);
		
		GV.screen = screen;
		
		#if debug
			var timer = new Timer(1, 0);
			timer.onTick(function() {
				fps.set_text("" + PerformanceManager.fps + " fps");
			});
			timer.start();
			GuiManager.add(fps);
		#end
	}
	
	public function render():Void
	{
		screen.lock();
		
		//Render the background
		screen.fillRect(new Rectangle(0, 0, screen.width, screen.height), 0xffffff);
		guiBuffer.fillRect(guiBuffer.rect, 0);
		
		GuiManager.render(guiBuffer);
		screen.draw(guiBuffer);
		
		screen.unlock();
	}
	
	public function update():Void
	{
		PerformanceManager.update();
		GuiManager.update();
		
		Tween.update();
		Timer.update();
		
		Input.update();
	}
	
}