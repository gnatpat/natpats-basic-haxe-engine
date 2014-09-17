package net.natpat.particles;

/**
 * ...
 * @author Nathan Patel
 */
@:publicFields
 class Particle 
{
	
	 var x:Int;
	 var y:Int;
	 var xVel:Float;
	 var yVel:Float;
	
	 var time:Float;
	 var duration:Float;
	
	 var gravity:Float;
	
	 var next:Particle;
	 var prev:Particle;
	 
	 var reversed:Bool;
	 var frameLength:Float;
	
	public function new() 
	{
		
	}
	
}
