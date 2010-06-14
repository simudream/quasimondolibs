package com.quasimondo.geom
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Stage;

	public class CompoundShape extends GeometricShape implements IIntersectable, ICountable, IPolygonHelpers
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
			if ( shape is CompoundShape )
			{
				for ( var i:int = 0; i < CompoundShape(shape).shapeCount; i++ )
				{
					shapes.push( CompoundShape(shape).getShapeAt(i)); 
				}
			} else {
				shapes.push( shape );
			}
		}
		
		public function clear():void
		{
			shapes.length = 0;
		}
		
		public function get shapeCount():int
		{
			return shapes.length;
		}
		
		public function get pointCount():int
		{
			var c:int = 0;
			for ( var i:int = 0; i < shapes.length; i++ )
			{
				c += ICountable(shapes[i]).pointCount;
			}
			return c;
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
		
		public function addPointAtClosestSide( p:Vector2 ):void
		{
			var closestPoly:Polygon;
			var closestDistance:Number = Number.MAX_VALUE;
			
			for each ( var shape:GeometricShape in shapes )
			{
				if ( shape is Polygon )
				{
					var d:Number = Polygon(shape).squaredDistanceToPoint(p);
					if ( d < closestDistance )
					{
						closestDistance = d;
						closestPoly = Polygon(shape);
					}
				}
			}
			
			if ( closestPoly != null ) closestPoly.addPointAtClosestSide( p );
		}
		
		public function detangle():void
		{
			for each ( var shape:GeometricShape in shapes )
			{
				if ( shape is IPolygonHelpers ) IPolygonHelpers(shape).detangle();
			}
		}
		
		public function fractalize( factor:Number = 0.5, range:Number = 0.5, minSegmentLength:Number = 2, iterations:int = 1 ):void
		{
			for each ( var shape:GeometricShape in shapes )
			{
				if ( shape is IPolygonHelpers ) IPolygonHelpers(shape).fractalize(factor,range,minSegmentLength,iterations);
			}
		}
		
		public function getPointAt( index:int ):Vector2
		{
			var l:int = pointCount;
			index = int(((index % l) + l )% l);
			var c:int = 0;
			for ( var i:int = 0; i < shapes.length; i++ )
			{
				if ( index >= ICountable(shapes[i]).pointCount )
				{
					index -= ICountable(shapes[i]).pointCount;
				} else {
					return ICountable(shapes[i]).getPointAt( index );
				}
			}
			return null;
		}
		
		override public function clone( deepClone:Boolean = true ):GeometricShape
		{
			var shape:CompoundShape = new CompoundShape();
			for ( var i:int = 0; i < shapes.length; i++ )
			{
				shape.addShape( shapes[i].clone( deepClone ) );
			}
			return shape;
		}
		
		override public function get type():String
		{
			return "CompoundShape";
		}
	}
}