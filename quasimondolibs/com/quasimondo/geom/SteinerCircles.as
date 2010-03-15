package com.quasimondo.geom
{
	import com.quasimondo.geom.Vector2;
	import com.quasimondo.geom.Circle;
	
	public class SteinerCircles
	{
		
		public var circles:Array;
		public var outerCircle:Circle;
		
		
		private var parentCircle:Circle;
		private var ratio:Number;
		private var circleCount:int;
		
		private var a:Number;
		private var b:Number;
		private var angleStep:Number;
		private var piFactor:Number;
		private var centerFactor:Number;
		private var rotAngle:Number;
		
		private var center:Vector2;
		private var inverter:Vector2;
		
			
		
		public function SteinerCircles()
		{
		}
		
		
		public function init( parentCircle:Circle, circleCount:int, ratio:Number, rotation:Number ):void
		{
			var i:int;
			
			this.parentCircle = parentCircle;
			this.circleCount = circleCount;
			this.ratio = ratio;
			
			angleStep = Math.PI / circleCount;
			
			piFactor = Math.sin( angleStep );
			
			centerFactor = ( 1 - piFactor) / ( 1 + piFactor );
			
			var radius:Number = parentCircle.r;
			a = 2 * radius;
			b = a * centerFactor;
			var c:Number = ( a - b ) / 2;
			
			var satelitesDistance:Number = b + c;
			rotAngle = 0;
			
			center = new Vector2();
			
			circles = [];
			
			var points:Array = [];
			var angle:Number;
			for ( i = 0; i < circleCount; i++) 
			{
				angle = 2*angleStep*i + rotation;
				points.push( new Vector2( Math.cos(angle+angleStep)*satelitesDistance, Math.sin(angle+angleStep)*satelitesDistance));
				points.push( new Vector2( Math.cos(angle)*a, Math.sin(angle)*a));
				points.push( new Vector2( Math.cos(angle)*b, Math.sin(angle)*b));
			}
		
			
			inverter = new Vector2(  parentCircle.r * ratio * Math.cos(rotation), parentCircle.r * ratio * Math.sin(rotation));
			
			var innerPoints:Array = [];
			var outerPoints:Array = [];
			var p:Array;
			var j:int;
			var p1:Vector2;
			var p2:Vector2;
			var p3:Vector2;
			
			for ( i = 0;  i < circleCount; i++) 
			{
				p1 = invert( Vector2(points[ int( i * 3 ) ] ));
				p2 = invert( Vector2(points[ int( i * 3 + 1 ) ]) );
				p3 = invert( Vector2(points[ int( i * 3 + 2) ]) );
				
				innerPoints.push( p2 );
				outerPoints.push( p3 );
				
				circles.push( kd3p( p1, p2, p3 ) );
			}
		
			circles.push( kd3p( Vector2(innerPoints[0]),  Vector2(innerPoints[1]),  Vector2(innerPoints[2]) ) );
			outerCircle = kd3p(  Vector2(outerPoints[0]),  Vector2(outerPoints[1]),  Vector2(outerPoints[2]) );
			
			var scale:Number =  parentCircle.r / outerCircle.r;
			var circle:Circle;
			
			for ( i = 0;  i < circles.length; i++) 
			{
				circle = Circle(circles[i]);
				circle.c.minus( outerCircle.c );
				circle.c.multiply( scale );
				circle.r *= scale;
				circle.c.plus( parentCircle.c );
			}
			
			
			outerCircle.r *= scale;
			outerCircle.c.setValue( parentCircle.c );
			
			
		}
		
		private function invert( p:Vector2 ):Vector2
		{
			var dx:Number = p.x - inverter.x;
			var dy:Number = p.y - inverter.y;
			var dxy:Number = dx * dx + dy * dy ;
			if ( dxy == 0 ) dxy = 1 / Number.MAX_VALUE;
			return inverter.getPlus( new Vector2( dx  / dxy, dy / dxy) );
		}
		
		private function kd3p( p0:Vector2, p1:Vector2, p2:Vector2 ):Circle
		{
			var m:Array = [];
			
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
			
			GLSL( m );
			
			return new Circle( Number(m[ 7 ]), Number(m[ 11 ]),  Math.sqrt( Number(m[7]) * Number(m[7]) + Number(m[11]) * Number(m[11]) - Number(m[3])) );
			
		}

		private function GLSL( m:Array ):void
		{
			var q:Number;
			var i:int, j:int, k:int;
			for ( j = 0; j < 3; j++) 
			{
				q = Number( m[ int( j * 5 ) ] );
				
				if (q == 0) 
				{
					for ( i = j + 1; i < 3; i++) 
					{
						if ( Number( m [ int( i * 4 + j ) ] ) != 0 )
						{
							for ( k = 0; k < 4; k++) 
							{
								m[ int(j * 4 + k)] += Number( m[ int( i * 4 + k) ] );
							}
							q = Number( m[ int( j * 5 ) ] );
							break;
						}
					}
				}
				
				if (q != 0) 
				{
					for ( k=0; k < 4; k++)
					{
						m[ int( j * 4 + k )] = Number( m[ int( j * 4 + k )] ) / q;
					}
				}
				
				for ( i = 0; i < 3; i++)
				{
					if ( i != j )
					{
						q = Number( m[ int( i * 4 + j )] );
						for ( k=0; k < 4; k++)
						{
							m[ int( i * 4 + k )] -= q * Number( m[ int( j * 4 + k )] );
						}
					}
				}
			}
		}

	}
}

