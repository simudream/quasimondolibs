package com.quasimondo.geom
{
	import com.quasimondo.utils.MathUtils;
	
	import flash.display.Graphics;
	
	public class Circle extends GeometricShape implements IIntersectable
	{
		public static const HATCHING_MODE_SAWTOOTH:String = "SAWTOOTH";
		public static const HATCHING_MODE_ZIGZAG:String = "ZIGZAG";
		public static const HATCHING_MODE_CRISSCROSS:String = "CRISSCROSS";
		
		public var c:Vector2;
		public var r:Number;
		
		static private const rad:Number = Math.PI / 180;
		
		private var drawingSegments:int = 6 ;
		private var startAngle:Number = 0;
		private var endAngle:Number = 0;
		
		static public function from3Points( p0:Vector2, p1:Vector2, p2:Vector2 ):Circle
		{
			var m:Vector.<Number> = new Vector.<Number>;
				
			m[0] = 1;
			m[1] = -2 * p0.x;
			m[2] = -2 * p0.y;
			m[3] = - p0.x * p0.x - p0.y * p0.y;
			
			m[4] = 1;
			m[5] = -2 * p1.x;
			m[6] = -2 * p1.y;
			m[7] = - p1.x * p1.x - p1.y * p1.y;
			
			m[8] = 1;
			m[9] = -2 * p2.x;
			m[10] = -2 * p2.y;
			m[11] = - p2.x * p2.x - p2.y * p2.y;
			
			MathUtils.GLSL( m );
			
			return new Circle(m[7],m[ 11 ],  Math.sqrt( m[7] * m[7] + m[11] * m[11] - m[3]) );
			
		}
		
		public function Circle( value1:* = null, value2:* = null, value3:* = null ) {
			
			if ( value1 is Circle )
			{
				c = new Vector2( Circle( value1.c ) );
				r =  Circle( value1 ).r;
			} else if ( value1 is Vector2)
			{
				c = Vector2( value1 ).getClone();
				r = Number( value2 );
			} else {
				c = new Vector2( Number(value1),Number(value2));
				r = Number(value3);
			}
		}
		
		override public function get type():String
		{
			return "Circle";
		}
	
		//
		override public function isInside ( point:Vector2, includeVertices:Boolean = true ):Boolean
		{
			return includeVertices ? point.squaredDistanceToVector(c)<= r*r : point.squaredDistanceToVector(c)< r*r;
		}
		
		public function lineIsInside ( line:LineSegment ):Boolean
		{
			return (line.p1.squaredDistanceToVector(c)<r*r) && (line.p2.squaredDistanceToVector(c)<r*r);
		}
		
		public function circleIsInside ( circle:Circle ):Boolean
		{
			if (circle.r <= r ) return false;
			return circle.c.squaredDistanceToVector(c)<(circle.r-r)*(circle.r-r);
		}
		
		public function circleIsInsideOrIntersects ( circle:Circle ):Boolean
		{
			return circle.c.squaredDistanceToVector(c)<(circle.r+r)*(circle.r+r);
		}
	
		public function isIdentical( c2:Circle ):Boolean
		{
			return ( r==c2.r && c.x == c2.c.x && c.y == c2.c.y);
		}
		
		public function setDrawingOpions(  sgm:int = 6, s1:Number = 0, s2:Number = 0 ):void
		{
			drawingSegments = sgm;
			startAngle = s1;
			endAngle = s2;
		}
		
		public function toVector( maxSegmentLength:Number):Vector.<Vector2>
		{
			var segments:int = Math.ceil( circumference / maxSegmentLength );
			var result:Vector.<Vector2> = new Vector.<Vector2>();
			var step:Number = 2 * Math.PI / segments;
			for ( var i:int = 0; i < segments; i++ )
			{
				result.push( new Vector2( c.x + r * Math.cos(i*step), c.y + r * Math.sin(i*step)));
			}
			return result;
		}
		
		public function toPolygon( maxSegmentLength:Number):Polygon
		{
			var polygon:Polygon = new Polygon();
			var segments:int = Math.ceil( circumference / maxSegmentLength );
			var step:Number = 2 * Math.PI / segments;
			for ( var i:int = 0; i < segments; i++ )
			{
				polygon.addPoint( new Vector2( c.x + r * Math.cos(i*step), c.y + r * Math.sin(i*step)));
			}
			return polygon;
		}
		
		public function toConvexPolygon( maxSegmentLength:Number):ConvexPolygon
		{
			var polygon:ConvexPolygon = new ConvexPolygon();
			var segments:int = Math.ceil( circumference / maxSegmentLength );
			var step:Number = 2 * Math.PI / segments;
			for ( var i:int = 0; i < segments; i++ )
			{
				polygon.addPoint( new Vector2( c.x + r * Math.cos(i*step), c.y + r * Math.sin(i*step)));
			}
			return polygon;
		}
		
		
		// based on java code by Paul Hertz
		// http://ignotus.com/factory/wp-content/uploads/2010/03/bezcircle_applet/index.html
		public function toMixedPath( cubicBezierCount:int = 4 ):MixedPath
		{
			/** 
			 * kappa = distance between Bezier anchor and its associated control point divided by circle radius 
			 * when circle is divided into 4 sectors 0f 90 degrees
			 * see http://www.whizkidtech.redprince.net/bezier/circle/kappa/, notes by G. Adam Stanislav
			 */
			var kappa:Number = 0.5522847498;

			var k:Number = 4 * kappa / cubicBezierCount;
			var d:Number = k * r;
			var secPi:Number = Math.PI*2/cubicBezierCount;
			
			var a1:Vector2 = new Vector2(0,r);
			var c1:Vector2 = new Vector2(d,r);
			var a2:Vector2 = new Vector2(0,r);
			var c2:Vector2 = new Vector2(-d,r);
			
			a2.rotateBy(-secPi);
			c2.rotateBy(-secPi);
			
			var path:MixedPath = new MixedPath();
			path.addPoint( a1.getPlus(c) );
			path.addControlPoint( c1.getPlus(c) );
			path.addControlPoint( c2.getPlus(c) );
			path.addPoint( a2.getPlus(c) );
			
			for (var i:int = 1; i < cubicBezierCount; i++) 
			{
				a2.rotateBy(-secPi);
				c2.rotateBy(-secPi);
				c1.rotateBy(-secPi);
				path.addControlPoint( c1.getPlus(c) );
				path.addControlPoint( c2.getPlus(c) );
				path.addPoint( a2.getPlus(c) );
			}
			path.deletePointAt(path.pointCount-1);
			path.setLoop( true );
			
			return path;
		}
		

		public function get circumference():Number
		{
			return 2 * r * Math.PI;
		}
		
		//
		override public function draw( canvas:Graphics ):void 
		{
			var x1:Number, y1:Number, grad:Number, segm:Number;
			
			var s1:Number = startAngle;
			var s2:Number = endAngle;
			var sgm:Number = drawingSegments;
			
			if (s1 == s2) 
			{
				canvas.moveTo(c.x, c.y);
				canvas.drawCircle( c.x, c.y, r );
				return;
			} else {
				s1>s2 ? s1 -= 360 : "";
				x1 = r*Math.cos(s1*rad)+c.x;
				y1 = r*Math.sin(s1*rad)+c.y;
				grad = s2-s1;
				segm = grad/sgm;
				canvas.moveTo(c.x, c.y);
				canvas.lineTo(x1, y1);
			}
			
			for (var s:Number = segm+s1; s<grad+.1+s1; s += segm) {
				var x2:Number = r*Math.cos((s-segm/2)*rad)+c.x;
				var y2:Number = r*Math.sin((s-segm/2)*rad)+c.y;
				var x3:Number = r*Math.cos(s*rad)+c.x;
				var y3:Number = r*Math.sin(s*rad)+c.y;
				// begin tnx 2 Robert Penner
				var cx:Number = 2*x2-.5*(x1+x3);
				var cy:Number = 2*y2-.5*(y1+y3);
				canvas.curveTo(cx, cy, x3, y3);
				// end tnx 2 Robert Penner :)
				x1 = x3;
				y1 = y3;
			}
			if (grad != 360) {
				canvas.lineTo(c.x, c.y);
			}
		};
		
		override public function drawExtras( canvas:Graphics, factor:Number = 1 ):void 
		{
			c.draw( canvas, factor );
		}
		
		public function drawHatching( distance:Number, angle:Number, offsetFactor:Number, canvas:Graphics ):void
		{
			if ( distance == 0 ) return;
			
			angle %= Math.PI;
			offsetFactor %= 1;
			
			var lineLength:Number = 3 * r;
			
			var line:LineSegment = LineSegment.fromPointAndAngleAndLength( c.getClone(), angle,lineLength,true);
			var normalOffset:Vector2 = line.getNormalAtPoint( c );
			
			normalOffset.newLength( -r - distance * offsetFactor );
			line.translate( normalOffset );
			normalOffset.newLength(-distance);
			
			var maxIterations:int = 2 + (2*r)/ distance;
			while ( maxIterations-- > -1)
			{
				var pts:Intersection = this.intersect( line );
				if ( pts.points.length == 2) 
				{
					canvas.moveTo( 	pts.points[0].x,pts.points[0].y);
					canvas.lineTo( 	pts.points[1].x,pts.points[1].y);
				}
				line.translate( normalOffset );
			}
		}
		
		public function getHatchingPath( distance:Number, angle:Number, offsetFactor:Number, mode:String = HATCHING_MODE_ZIGZAG ):LinearPath
		{
			if ( distance == 0 ) return null;
			distance = Math.abs( distance );
			angle %= Math.PI;
			offsetFactor %= 2;
			
			var lineLength:Number = 3 * r;
			
			var line:LineSegment = LineSegment.fromPointAndAngleAndLength( c.getClone(), angle,lineLength,true);
			var normalOffset:Vector2 = line.getNormalAtPoint( c );
			
			
			var startLength:Number =  - (r - r % distance) - distance * offsetFactor;
			
			normalOffset.newLength( startLength );
			line.translate( normalOffset );
			normalOffset.newLength(-distance);
			
			
			var pts:Intersection;
			var path:LinearPath = new LinearPath();
			var zigzag:int = 0;
			var startLeft:Boolean = ( Math.abs(r) % (distance * 4 ) < distance * 2 );
			
			var maxIterations:int = 2 + (2*r)/ distance;
			
			while ( maxIterations-- > -1)
			{
				pts = this.intersect( line );
				if ( pts.points.length == 2) 
				{
					var middle:Vector2 = pts.points[0].getLerp( pts.points[1], 0.5 );
					if ( (pts.points[0].isLeft(middle,middle.getPlus(normalOffset)) < 0) == startLeft )
					{
						var tmp:Vector2 = pts.points[0];
						pts.points[0] = pts.points[1];
						pts.points[1] = tmp;
					}
					
					path.addPoint(pts.points[1-zigzag]);
					if ( mode != HATCHING_MODE_SAWTOOTH ) path.addPoint(pts.points[zigzag]);
					if ( mode != HATCHING_MODE_CRISSCROSS	) zigzag = 1 - zigzag;
				}
				line.translate( normalOffset );
			}
			
			return path;
		}
	
		override public function getNormalAtPoint( p:Vector2 ):Vector2
		{
			return Vector2.fromAngle(c.angleTo(p),1);
		}
	
		override public function getPoint(t:Number):Vector2
		{
			return new Vector2( c.x + r * Math.cos( 2 * Math.PI * t ),  c.y + r * Math.sin( 2 * Math.PI * t ));
		}
		
		public function getTangentPolygon( circle:Circle ):Polygon
		{
			var poly:Polygon = new Polygon();
			var l:LineSegment = new LineSegment ( c, circle.c );
			poly.addPoint(l.getNormalAtPoint( l.p1 ).newLength( r ).plus( l.p1 ));
			poly.addPoint(l.getNormalAtPoint( l.p2 ).newLength( circle.r ).plus( l.p2 ));
			poly.addPoint(l.getNormalAtPoint( l.p2 ).newLength( -circle.r ).plus( l.p2 ));
			poly.addPoint(l.getNormalAtPoint( l.p1 ).newLength( -r ).plus( l.p1 ));
			return poly;
		}
		
		public function intersect ( that:IIntersectable ):Intersection 
		{
			return Intersection.intersect( this, that );
		};
		
	}
}