package com.quasimondo.delaunay
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	public class DelaunayNode
	{
		
		public var x:Number;
		public var y:Number;
		public var edge:DelaunayEdge;
		public var data:DelaunayNodeProperties;
		public var type:int;
		
		public var next:DelaunayNode;
		
		private var dx:Number;
		private var dy:Number;
		
		public function DelaunayNode( $x:Number, $y:Number, $data:DelaunayNodeProperties = null)
		{
			x = $x;
			y = $y
			data = $data
		}
		
		public function distanceTo( node:DelaunayNode ):Number
		{ 
		  	dx = node.x - x;
		    dy = node.y - y;
		    return Math.sqrt(dx*dx+dy*dy);
		}
		
		
		public function distance( px:Number, py:Number ):Number
		{ 
		  	dx = px - x;
		    dy = py - y;
		    return Math.sqrt(dx*dx+dy*dy);
		}
		
		public function squaredDistance( px:Number, py:Number ):Number
		{ 
		  	dx = px - x;
		    dy = py - y;
		    return dx*dx+dy*dy;
		}
		 
		public function draw( g:Graphics, fixedToo:Boolean = false, colorMap:BitmapData = null):void
		{
			if ( data != null )
			{
				data.draw( g, colorMap );
			} else {
				g.drawCircle( x,y,2);
			}
		}
		
		public function toString():String
		{
			return x+", "+y;
		}
		
	}
}