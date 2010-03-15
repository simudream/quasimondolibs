package com.quasimondo.delaunay
{
	import com.quasimondo.geom.ConvexPolygon;
	import com.quasimondo.geom.Vector2;
	
	import flash.display.Graphics;
	
	public class VoronoiRegion
	{
		public var p:DelaunayNode;
		public var polygon:ConvexPolygon;
		
  		public function VoronoiRegion( $p:DelaunayNode ):void
		{
			update( $p ); 
		}
		
		public function update( $p:DelaunayNode):void
		{ 
			p = $p;
			polygon = new ConvexPolygon();
		}
		
		public function addPoint( p:Vector2 ):void
		{
			polygon.addPoint( p );
		}
		
		public function draw( g:Graphics):void
		{ 
			polygon.draw( g );
		}
		
	}
}