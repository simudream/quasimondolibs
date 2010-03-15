/*
Quadradic Bezier Curve Class

based on javascript code by Kevin Lindsey
http://www.kevlindev.com/

ported optimized augmented for Actionscript by Mario Klingemann
*/
package com.quasimondo.geom
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	public class Bezier2 extends GeometricShape implements IIntersectable
	{
		public var p1:Vector2;
		public var p2:Vector2;
		public var c:Vector2;
		
		private var dirty:Boolean = true;
		private var __length:Number;
		
		private static var CURVE_LENGTH_PRECISION:int = 31;
		private static var OFFSET_PRECISION:Number = 10;
		
		public function Bezier2 ( _p1:Vector2, _c:Vector2, _p2:Vector2 )
		{
			p1 = _p1;
			c = _c;
			p2 = _p2;
		}
		
		override public function get type():String
		{
			return "Bezier2";
		}
			
		override public function draw ( g:Graphics ):void
		{
			g.moveTo( p1.x, p1.y );
			g.curveTo( c.x, c.y, p2.x, p2.y );
		}
		
		override public function drawExtras ( g:Graphics, factor:Number = 1 ):void 
		{
			g.moveTo( p1.x, p1.y );
			g.lineTo( c.x, c.y);
			g.lineTo( p2.x, p2.y);
			
			p1.draw(g,factor);
			p2.draw(g,factor);
			c.draw(g,factor);
		}
		
		override public function drawTo ( g:Graphics ):void
		{	
			g.curveTo( c.x, c.y, p2.x, p2.y );
		}
		
		override public function moveToStart ( g:Graphics ):void
		{
			g.moveTo( p1.x, p1.y );
		}
		
		override public function getPoint( t:Number ):Vector2 
		{
			var ti:Number = 1-t;
			
			return new Vector2 ( ti*ti*p1.x+2*t*ti*c.x+t*t*p2.x , ti*ti*p1.y+2*t*ti*c.y+t*t*p2.y);
		}
		
		override public function getPointAtOffset ( offset:Number ):Vector2
		{
			var dsq:Number = offset * offset;
			var p1:Vector2 = getPoint( 0 );
			var p2:Vector2;
			var dt:Number = offset / length;
			var fit:Boolean = false;
			var dx:Number;
			var dy:Number;
			var d:Number;
			
			while (!fit)
			{
				p2 = getPoint( dt );
				dx=p1.x-p2.x;
				dy=p1.y-p2.y;
				d=(dx*dx+dy*dy)-dsq;
				if (d<-OFFSET_PRECISION)
				{
					dt*=1.1;
				} else if (d>OFFSET_PRECISION)
				{
					dt*=0.9;
				} else {
					fit=true;
				}
			}
			return p2;
		}
		
		override public function getBoundingRect( loose:Boolean = true ):Rectangle
		{
			var minP:Vector2 = p1.getMin( p2 ).min( c );
			var size:Vector2 = p1.getMax( p2 ).max( c ).minus( minP );
			return new Rectangle( minP.x, minP.y , size.x, size.y  );
		}
		
		override public function get length():Number
		{
			if ( !dirty ) return __length;
			
			var min_t:Number = 0;
			var max_t:Number = 1;
			var	i:int;
			var	len:Number = 0;
			var n_eval_pts:int = CURVE_LENGTH_PRECISION;
			if ( !( n_eval_pts & 1 ) ) n_eval_pts++;
		
			var t:Array = [];
			var pt:Array = [];
		
			for ( i = 0 ; i < n_eval_pts ; ++i )
			{
				t[i]  =  i / ( n_eval_pts - 1 );
				pt[i] = getPoint(t[i]);
			}
		
			for ( i = 0 ; i < n_eval_pts - 1 ; i += 2 )
			{
				len += getSectionLength (t[i] , t[int(i+1)] , t[int(i+2)] , pt[i] , pt[int(i+1)] , pt[int(i+2)]);
			}
			
			__length = len;
			dirty = false;
		
			return len;
		}
	
		//	Compute the length of a small section of a parametric curve from
		//	t0 to t2 , recursing if necessary. t1 is the mid-point.
		//	The 3 points at these parametric values are precomputed.
		
		
		 private function getSectionLength (t0:Number , t1:Number , t2:Number , pt0:Vector2 ,pt1:Vector2 , pt2:Vector2 ):Number
		{
		
			var kEpsilon:Number	= 1e-5;
			var kEpsilon2:Number	= 1e-6;
			var kMaxArc:Number	= 1.05;
			var kLenRatio:Number	= 1.2;
		
			var d1:Number ;
			var d2:Number;
			var	len_1:Number;
			var len_2:Number;
			var	da:Number;
			var db:Number;
		
			d1 = pt0.getMinus( pt2 ).length;
		
			da = pt0.getMinus( pt1 ).length;
			db = pt1.getMinus( pt2 ).length;
		
			d2 = da + db;
		
			if ( d2 < kEpsilon ){
				return ( d2 + ( d2 - d1 ) / 3 );
			} else if ( ( d1 < kEpsilon || d2/d1 > kMaxArc ) || ( da < kEpsilon2 || db/da > kLenRatio ) || ( db < kEpsilon2 || da/db > kLenRatio ) ) {
				var	mid_t:Number = ( t0 + t1 ) / 2;
		
				var	pt_mid:Vector2=getPoint ( mid_t );
		
				len_1 = getSectionLength( t0 ,mid_t ,  t1 ,  pt0 ,  pt_mid ,  pt1 );
		
				mid_t = ( t1 + t2 ) / 2;
				
				pt_mid = getPoint ( mid_t );
		
				len_2 = getSectionLength (t1 , mid_t ,t2 , pt1 , pt_mid , pt2 );
		
				return ( len_1 + len_2 );
		
			} else {
				return ( d2 + ( d2 - d1 ) / 3 );
			}
		
		}
		 
		 public function intersect ( that:IIntersectable ):Intersection 
		 {
			 return Intersection.intersect( this, that );
		 };
	
		public function toString( ):String
		{
			return p1+" - " + c + " - "+p2;
		}
		
		public function toSVG( absolute:Boolean = true ):String
		{
			if ( absolute )
			{
				return "M "+p1.toSVG()+"Q "+c.toSVG()+ p2.toSVG();
			} else {
				return "q "+c.getMinus( p1 ).toSVG()+ p2.getMinus( p1 ).toSVG();
			}
		}
	}
}