package net.natpat.utils;

/**
 * ...
 * @author Nathan Patel
 */
class PerformanceManager
{

	private static var _fps:Int = 0;
	private static var _fpsTimer:Float = 0;
	private static var _lastSecFPS:Int = 0;
	public static var fps(get, never):Int;
	
	public function new() 
	{
		
	}
	
	public static function update():Void
	{
		updateFPS();
	}
	
	private static function updateFPS():Void
	{
		_fps++;
		_fpsTimer += GV._elapsed;
		while (_fpsTimer >= 1)
		{
			_lastSecFPS = _fps;
			_fpsTimer -= 1;
			_fps = 0;
		}
	}
	
	private static function get_fps():Int
	{
		return _lastSecFPS;
	}
}