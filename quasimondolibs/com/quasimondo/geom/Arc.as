package com.quasimondo.geom
{
	import __AS3__.vec.Vector;
	
	import flash.display.Graphics;
	
	public class Arc extends GeometricShape
	{
		public var c:Vector2;
		
		public var p_in:Vector2;
		public var p_out:Vector2;
		
		public var r_in:Number;
		public var r_out:Number;
		
		public var angle:Number;
		
		private var angle_in:Number;
		private var angle_out:Number;
		
		static private const rad:Number = Math.PI / 180;
		
		// possible constructors:
		// arc:Arc
		// startpoint:Vector2, center:Vector2, radius out:Number, arc_angle:Number
		// startpoint:Vector2, angle_in:Number, endpoint:Vector2, angle_out:Number
		
		
		public function Arc( value1:* = null, value2:* = null, value3:* = null, value4:* = null ) {
			
			if ( value1 is Arc )
			{
				c = new Vector2( Arc( value1.c ) );
				p_in =  Arc( value1 ).p_in;
				p_out =  Arc( value1 ).p_out;
				r_in =  Arc( value1 ).r_in;
				r_out =  Arc( value1 ).r_out;
				angle = Arc( value1 ).angle;
			} else if ( value1 is Vector2 && value2 is Vector2 && value3 is Number && value4 is Number )
			{
				c = Vector2( value1 ).getClone();
				p_in = Vector2( value2 ).getClone();
				r_out = Number( value3 );
				angle = Number( value4 );
				
				r_in = c.distanceToVector( p_in );
				angle_in = c.angleTo( p_in );
				angle_out = angle_in + angle;
				p_out = c.getAddCartesian( r_out, angle_out );
			} else if ( value1 is Vector2 && value2 is Number && value3 is Vector2 && value4 is Number )
			{
				angle_in = value2;
				angle_out = value4;
				
				p_in = Vector2( value1 ).getClone();
				p_out = Vector2( value3 ).getClone();
				
				var l1:LineSegment = new LineSegment( p_in, p_in.getAddCartesian( angle_in, 10 ));
				var l2:LineSegment = new LineSegment( p_out, p_out.getAddCartesian( angle_out, 10 ));
				
				var intersections:Vector.<Vector2> = l1.getIntersection( l2 );
				if ( intersections.length == 1 )
				{
					c = intersections[0];
					
					angle_in = p_in.angleTo( c );
					angle_out = p_out.angleTo( c );
					
					r_in = c.distanceToVector( p_in );
					r_out = c.distanceToVector( p_out );
					
					angle = angle_out - angle_in;
				
				} 
			} else if ( value1 is Vector2 && value2 is Number && value3 is Number && value4 is Number )
			{
				c = Vector2( value1 ).getClone();
				r_in = r_out = Number( value2 );
				angle_in = Number( value3 );
				//angle_in = (( angle_in % (2*Math.PI))+(2*Math.PI)) % (2*Math.PI);
				
				angle_out = Number( value4 );
				//angle_out = (( angle_out % (2*Math.PI))+(2*Math.PI)) % (2*Math.PI);
				
				angle = angle_out - angle_in;
				//if ( angle < 0 ) angle = 2*Math.PI + angle;
			} 
		}
		
		override public function getPoint(t:Number):Vector2
		{
			var r:Number = r_in + ( r_out - r_in ) * t;
			var a:Number = angle_in + ( angle_out - angle_in ) * t;
			
			return new Vector2( c.x + r * Math.cos( a ), c.y + r * Math.sin( a ) );
		}
	
		//
		override public function draw( canvas:Graphics ):void 
		{
			var r:Number = r_in;
			var a:Number = angle_in;
			canvas.moveTo(c.x + r * Math.cos(a),  c.y + r * Math.sin(a) );
			drawTo( canvas );
			
		
			/*
				canvas.lineStyle( 0, 0xff8000 );
				canvas.moveTo(p_in.x,p_in.y);
				canvas.lineTo(c.x,c.y);
				canvas.lineTo(p_out.x,p_out.y);
			*/
		};
		
		override public function drawTo(canvas:Graphics):void
		{
			var x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number;
			
			var segm:Number = Math.ceil( Math.abs(angle) / (Math.PI / 3 ) );
			
			var r:Number = r_in;
			var r_delta:Number = ( r_out - r_in ) / ( segm * 2 );
			
			var a:Number = angle_in;
			var a_delta:Number = angle / ( segm * 2 );
			
			x1 = c.x + r * Math.cos(a);
			y1 = c.y + r * Math.sin(a);
			
			for (var i:int = 0; i < segm; i++ ) 
			{
				r += r_delta;
				a += a_delta;
				
				x2 = c.x + r * Math.cos(a);
				y2 = c.y + r * Math.sin(a);
				
				r += r_delta;
				a += a_delta;
				
			 	x3 = c.x + r * Math.cos(a);
				y3 = c.y + r * Math.sin(a);
				
				canvas.curveTo( 2 * x2 - .5 * ( x1 + x3 ), 2 * y2 - .5 * ( y1 + y3 ), x3, y3);
				
				x1 = x3;
				y1 = y3;
			}
		}
		
		public function toMixedPath( addFirst:Boolean = true ):MixedPath
		{
			var mp:MixedPath = new MixedPath();
			
			var x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number;
			
			var segm:Number = Math.ceil( Math.abs(angle) / (Math.PI / 3 ) );
			
			var r:Number = r_in;
			var r_delta:Number = ( r_out - r_in ) / ( segm * 2 );
			
			var a:Number = angle_in;
			var a_delta:Number = angle / ( segm * 2 );
			
			x1 = c.x + r * Math.cos(a);
			y1 = c.y + r * Math.sin(a);
			
			if ( addFirst )
			{
				mp.addPoint( new Vector2(x1,y1) );
			}
			
			for (var i:int = 0; i < segm; i++ ) 
			{
				r += r_delta;
				a += a_delta;
				
				x2 = c.x + r * Math.cos(a);
				y2 = c.y + r * Math.sin(a);
				
				r += r_delta;
				a += a_delta;
				
			 	x3 = c.x + r * Math.cos(a);
				y3 = c.y + r * Math.sin(a);
				mp.addControlPoint( new Vector2(2 * x2 - .5 * ( x1 + x3 ), 2 * y2 - .5 * ( y1 + y3 )) );
				mp.addPoint( new Vector2(x3, y3) )
				x1 = x3;
				y1 = y3;
			}
			
			return mp;
			
		}
		
		override public function get type():String
		{
			return "Arc";
		}
	
	}
}