package com.quasimondo.geom
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Stage;

	public class CompoundShape extends GeometricShape implements IIntersectable
	{
		private var shapes:Vector.<GeometricShape>;
		
		public static function fromPolygons( polygons:Vector.<Polygon> ):CompoundShape
		{
			var result:CompoundShape = new CompoundShape();
			for each ( var poly:Polygon in polygons )
			{
				result.addShape( poly );
			}
			return result;
		}
		
		public function CompoundShape()
		{
			super();
			shapes = new Vector.<GeometricShape>();
		}
		
		public function addShape( shape:GeometricShape ):void
		{
			shapes.push( shape );
		}
		
		public function clear():void
		{
			shapes.length = 0;
		}
		
		public function get count():int
		{
			return shapes.length;
		}
		
		public function getShapeAt( index:int ):GeometricShape
		{
			return shapes[index];
		}
		
		override public function draw( canvas:Graphics ):void
		{
			for ( var i:int = 0; i < shapes.length; i++ )
			{
				shapes[i].draw( canvas );
			}
		}
		
		override public function isInside( p:Vector2, includeVertices:Boolean = true ):Boolean
		{
			var inside:Boolean = false;
			for each ( var shape:GeometricShape in shapes )
			{
				inside = ( inside != shape.isInside( p, includeVertices ));
			}
			/*
			// this is yet a dirty hack
			var hack:Shape = new Shape();
			hack.graphics.beginFill(0);
			draw( hack.graphics );
			hack.graphics.endFill();
			stageHack.addChild(hack);
			var result:Boolean = hack.hitTestPoint( p.x, p.y, true );
			stageHack.removeChild(hack);
			*/
			return inside;
		}

		public function intersect ( that:IIntersectable ):Intersection 
		{
			return Intersection.intersect( this, that );
		};
	}
}