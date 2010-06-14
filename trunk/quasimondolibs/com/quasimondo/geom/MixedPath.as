package com.quasimondo.geom
{
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;

	public class MixedPath extends GeometricShape implements IIntersectable, ICountable
	{
		static public const LINEARIZE_APPROXIMATE:int = 0;
		static public const LINEARIZE_COMPLETE:int = 1;
		static public const LINEARIZE_UNDERSHOOT:int = 2;
		static public const LINEARIZE_OVERSHOOT:int = 3;
		static public const LINEARIZE_CENTER:int = 4;
	
		private var loop:Boolean;
		private var points:Vector.<MixedPathPoint>;
		private var segments:Vector.<GeometricShape>;
		
		private var isValid:Boolean;
		private var dirty:Boolean;
		
		private var totalLength:Number;
		
		private var t_toSegments:Vector.<Number>;
		private var length_toSegments:Vector.<Number>;
		
		public function MixedPath()
		{
			points = new Vector.<MixedPathPoint>();
			loop = false;
			isValid = false;
			dirty = true;
		}
	
	
		override public function draw( g:Graphics ):void
		{
			if ( dirty ) updateSegments();
			
			if (isValid)
			{
				GeometricShape(segments[0]).moveToStart( g );
				for (var i:int = 0; i < segments.length; i++ )
				{
					GeometricShape(segments[i]).drawTo( g );
				}
				
			}
		}
	
		override public function drawExtras( g:Graphics, factor:Number = 1  ):void
		{
			if ( dirty ) updateSegments();
			
			if (isValid)
			{
				for (var i:int = 0; i<segments.length; i++)
				{
					GeometricShape(segments[i]).drawExtras( g, factor );
				}
				
			}
		}
	
	
		public function addPoint( p:Vector2, ID:String = null, update:Boolean = false ):Boolean
		{
			dirty = true;
			
			if ( ID == null ) ID = String( points.length );
			
			points.push( new MixedPathPoint( p, ID, false ) );
			if ( update )
				return updateSegments();
			else
				return isValid;
		}
	
		public function addControlPoint( p:Vector2, ID:String = null, update:Boolean = false ):Boolean
		{
			dirty = true;
			
			if ( ID == null ) ID = String( points.length );
			
			points.push( new MixedPathPoint( p, ID, true ) );
			if ( update )
				return updateSegments();
			else
				return isValid;
		}
	
		public function insertPointAt( p:Vector2, index:Number, ID:String = null, update:Boolean = false ):Boolean
		{
			dirty = true;
			
			if ( ID == null ) ID = String( points.length );
			
			points.splice( index, 0, new MixedPathPoint( p, ID, false ) );
			
			if ( update )
				return updateSegments();
			else 
				return isValid;
		}
		
		public function insertControlPointAt( p:Vector2, index:Number, ID:String = null, update:Boolean = false  ):Boolean
		{
			dirty = true;
			
			if ( ID == null ) ID = String( points.length );
			
			points.splice( index, 0, new MixedPathPoint( p, ID, true ) );
			if ( update )
				return updateSegments();
			else
				return isValid;
		}
		
		public function line2Bezier3( p1:MixedPathPoint, p2:MixedPathPoint ):Array
		{
			var ID1:String = String( points.length );
			var ID2:String = String( points.length + 1 );
			var index:int;
			for ( var i:int = 0; i < points.length; i++ )
			{
				if ( points[i] == p1){
					if (  points[i].isControlPoint ||  points[i+1].isControlPoint || points[i+1] != p2  )
					{
						return null;					
					}
					index = i;
					break;
				} else if ( points[i] == p2){
					if (  points[i].isControlPoint || points[i+1].isControlPoint || points[i+1]!= p1  ){
						return null;					
					}
					index = i;
					break;
				}
			}
			
			
			points.splice( index+1, 0, new MixedPathPoint( points[index].getLerp(points[index+1],0.333), ID1, true),
									   new MixedPathPoint( points[index].getLerp(points[index+1],0.666), ID2, true) );
			updateSegments();
			return [ points[index+1], points[index+2] ];
		}
	
		public function deletePoint( p:MixedPathPoint ):Boolean
		{
			for (var i:int = points.length;--i>-1;)
			{
				//trace(  [points[i].p,points[i].p == p]);
				if ( points[i] == p )
				{
					points.splice(i,1);
					return updateSegments();
				}
			}
			
			return isValid;
		}
		
		public function deletePointAt( index:int ):Boolean
		{
			points.splice( index, 1 );
			return updateSegments();
		}
		
		public function getMixedPathPointAt( index:int ):MixedPathPoint
		{
			return points[ index ];
		}
		
		public function getPointAt( index:int ):Vector2
		{
			return points[ index ];
		}
		
		public function updatePointAt(  index:int, p:MixedPathPoint ):Boolean
		{
			if ( index < 0 || index >= points.length ) return false;
			points[ index ] = p;
			return updateSegments();
		}
		
		public function get centroid():Vector2
		{
			var sx:Number = 0;
			var sy:Number = 0;
			var a:Number = 0;
			
			var p1:Vector2;
			var p2:Vector2;
			var f:Number;
			
			for ( var i:int = 0; i< points.length; i++ )
			{
				if ( !points[i].isControlPoint && !points[int((i+1) % points.length)].isControlPoint )
				{
					p1 = points[i];
					p2 = points[int((i+1) % points.length)];
					a += ( f = p1.x * p2.y - p2.x * p1.y );
					sx += (p1.x + p2.x) * f;
					sy += (p1.y + p2.y) * f;
				}
			}
			
			f = 1 / ( 3 * a );
			
			
			return new Vector2( sx * f, sy * f );
		}
		
		public function updatePoint( ID:String, p:MixedPathPoint ):Boolean
		{
			var point:MixedPathPoint = getPointByID( ID );
			if ( point == null ) return false;
			point = p;
			return updateSegments();
		}
		
		public function getPointByID( ID:String ):MixedPathPoint
		{
			for (var i:int = points.length;--i>-1;){
				if (points[i].ID==ID) return points[i];
			}
			return null;
		}
		
		public function getPointAt_t( t:Number ):Vector2
		{
			if ( dirty ) updateSegments();
			
			if ( !isValid || (!loop && (t<0 || t>1))) return null;
			if ( !loop )
			{
				if ( t > 1 ) t == 1;
				if ( t < 0 ) t == 0;
				
			} else {
				t = ((t%1)+1)%1;
			}
			
			var last_t:Number = 0;
			var t_sub:Number;
			for (var i:int=0;i<segments.length;i++)
			{
				if (t <= t_toSegments[i] )
				{
					if (t_toSegments[i] - last_t != 0)
						t_sub = ( t - last_t ) / (t_toSegments[i] - last_t);
					else 
						t_sub = 0;
					return GeometricShape(segments[i]).getPoint(t_sub);
				}
				last_t = t_toSegments[i];
			}
			
			return null;
		}
	
		public function getPointAt_offset( offset:Number ):Vector2
		{
			if ( dirty ) updateSegments();
			
			if ( !isValid || (!loop && (offset<0 || offset>totalLength))) return null;
			
			offset = ((offset%totalLength)+totalLength)%totalLength;
			
			var last_offset:Number = 0;
			
			for (var i:int=0;i<segments.length;i++)
			{
				if (offset<=length_toSegments[i]){
					return segments[i].getPointAtOffset( offset - last_offset );
				}
				last_offset = length_toSegments[i];
			}
			
			return null;
		}
		
		
		public function getLength():Number
		{
			var len:Number = 0;
			for (var i:int = segments.length; --i>-1;)
			{
				len += segments[i].length;
			}
			return len;
		}
		
		public function setLoop( loop:Boolean ):Boolean
		{
			this.loop = loop;
			return updateSegments();
		}
		
		public function isValidPath( ):Boolean 
		{
			if ( points.length < 2 ) return false;
			var cCounter:int=0;
			for (var i:int = points.length + ( loop ? 1 :0 ); --i>-1;)
			{
				if ( points[ i%points.length ].isControlPoint )
				{
					cCounter++;
				} else {
					cCounter=0;
				}
				if (cCounter == 3) return false;
			}
			return true;
		}
	
		public function getClosestPoint( x:Number, y:Number ):MixedPathPoint
		{
			if ( points.length==0 ) return null;
			
			var d:Number = points[0].squaredDistanceTo( x, y );
			var closest:MixedPathPoint = points[0];
			var d2:Number
			for (var i:int = points.length;--i>0;)
			{
				d2 = points[i].squaredDistanceTo( x, y );
				if (d2<d)
				{
					d=d2;
					closest = points[i];
				}
			}
			return closest;
		}
	
		public function getNeighbours( p:MixedPathPoint ):Array
		{
			var n:Array = [];
			for ( var i:int = 0; i < points.length;i++ )
			{
				if ( points[i] == p)
				{
					if ( i-1 > 0)
					{
						if ( !points[i-1].isControlPoint )
						{
							n.push( points[i-1] );
						}
					}
					if ( i+1 < points.length )
					{
						if ( !points[i+1].isControlPoint )
						{
							n.push( points[i+1] ); 
						}
					}
					return n;
				}
			}
			return null;
		}
	
		public function updateSegments():Boolean
		{
			dirty = false;
			
			isValid = isValidPath();
			
			if (!isValid) return false;
			
			segments = new Vector.<GeometricShape>();
			var traverse:int =  points.length + ( loop ? 0 :-1 );
			
			var currentIndex:int = 0;
			while (  points[ currentIndex ].isControlPoint )
			{
				currentIndex++;
			}
			var currentPoint:MixedPathPoint = points[ currentIndex ];
			
			var pointStack:Vector.<MixedPathPoint> = new Vector.<MixedPathPoint>();
			pointStack.push( currentPoint );
			
			while (traverse>0)
			{
				currentIndex++;
				currentPoint = points[ int(currentIndex % points.length) ] ;
				pointStack.push( currentPoint );
				if (!currentPoint.isControlPoint)
				{
					var l:Number = pointStack.length;
					switch ( l )
					{
						case 2:
							segments.push(new LineSegment( pointStack[0],pointStack[1]));
							pointStack.shift();
							break;
						case 3:
							segments.push(new Bezier2(pointStack[0],pointStack[1],pointStack[2]));
							pointStack.shift();
							pointStack.shift();
							break;
						case 4:
							segments.push(new Bezier3(pointStack[0],pointStack[1],pointStack[2],pointStack[3]));
							pointStack.shift();
							pointStack.shift();
							pointStack.shift();
							break;
					}
				}
				traverse--;
			}
			updateLookupTables();
			return true;
		}
		
		public function get segmentCount():int
		{
			if ( dirty ) updateSegments();
			return segments.length;
		}
		
		public function get pointCount():int
		{
			return points.length;
		}
		
		public function getSegment( index:int ):IIntersectable
		{
			if ( dirty ) updateSegments();
			
			index %= segments.length;
			if ( index < 0 ) index += segments.length;
			return segments[index] as IIntersectable;
		}
		
		public function toLinearPath( segmentLength:Number, mode:int = LINEARIZE_APPROXIMATE ):LinearPath
		{
			if ( dirty ) updateSegments();
			
			var lp:LinearPath = new LinearPath();
			var s:GeometricShape;
			
			var ti:Number;
			var t:Number;
			var steps:Number;
			var j:Number;
			
			var totalLength:Number = this.getLength();
			var totalSteps:int = totalLength / segmentLength;
			var t_step:Number;
			var t_base:Number = 0;
			if ( mode != LINEARIZE_APPROXIMATE )
			{
				var coveredLength:Number = totalSteps * segmentLength;
				t_step = (coveredLength / totalLength) / totalSteps;
				if ( mode == LINEARIZE_CENTER ) t_base = 0.5 * (1 - ( coveredLength / totalLength ));
			} else {
				t_step = 1 / totalSteps;
				
			}
			
			if ( mode == LINEARIZE_CENTER && t_base != 0 ) lp.addPoint( getPointAt_t(0) );
			//if ( mode == LINEARIZE_CENTER ) 
			for ( var i:int = 0; i <= totalSteps; i++ )
			{
				lp.addPoint( getPointAt_t( t_base + i * t_step ) );
			}
			if ( mode ==  LINEARIZE_OVERSHOOT ) {
				var p1:Vector2 = lp.points[lp.points.length-1];
				var p2:Vector2 = getPointAt_t( 1 );
				lp.addPoint( p2.minus( p1 ).newLength( segmentLength ).plus(p1) );
			} else if ( (mode == LINEARIZE_CENTER && t_base != 0) || ( mode == LINEARIZE_COMPLETE && (i-1) * t_step != 1) ) lp.addPoint( getPointAt_t(1) );
			
			/*
			for ( var i:int = 0; i < segments.length; i++ )
			{
				s = GeometricShape( segments[i] );
				if ( s is LineSegment )
				{
				 	lp.addPoint(LineSegment(s).p1);
				} else {
				 	steps = s.length / segmentLength;
					steps--;
					for ( j = 0; j < steps; j+=1 )
					{
						t = j / steps;
						lp.addPoint( s.getPoint( t ) );
					}
				}
			}
			*/
			if ( loop )
			{
				lp.addPoint( segments[0].getPoint( 0 ) );
			}
			
			return lp;
		}
		
		public function toPolygon( segmentLength:Number ):Polygon
		{
			if ( dirty ) updateSegments();
			
			var poly:Polygon = new Polygon();
			var s:GeometricShape;
			
			var ti:Number;
			var t:Number;
			var steps:Number;
			var j:Number;
			
			for ( var i:int = 0; i < segments.length; i++ )
			{
				s = GeometricShape( segments[i] );
				if ( s is LineSegment )
				{
				 	poly.addPoint(LineSegment(s).p1);
				} else {
				 	steps = s.length / segmentLength;
					steps--;
					for ( j = 0; j < steps; j+=1 )
					{
						t = j / steps;
						poly.addPoint( s.getPoint( t ) );
					}
				}
			}
			
			return poly;
		}
		
		
		override public function getBoundingRect( loose:Boolean = true ):Rectangle
		{
			if ( dirty ) updateSegments();
			
			var i:int, j:Number, steps:Number;
			var p:Vector2;
			if ( loose )
			{
				var s:GeometricShape = GeometricShape( segments[0] );
				var r:Rectangle = s.getBoundingRect();
				for ( i = 1; i < segments.length; i++ )
				{
					r = r.union( segments[i].getBoundingRect() );
				}
			} else {
				var minP:Vector2 = segments[0].getPoint( 0 ).getClone();
				var maxP:Vector2 = segments[0].getPoint( 0 ).getClone();
				var segmentLength:Number = 1;
				for ( i = 0; i < segments.length; i++ )
				{
					s = GeometricShape( segments[i] );
					if ( s is LineSegment )
					{
						p = s.getPoint( 0 );
						minP.min( p );
						maxP.max( p );
						p = s.getPoint( 1 );
						minP.min( p );
						maxP.max( p );
					} else {
					 	steps = s.length / segmentLength;
						steps--;
						for ( j = 0; j < steps; j+=1 )
						{
							p = s.getPoint( j / steps );
							minP.min( p );
							maxP.max( p );
						}
					}
				}
				maxP.minus( minP );
				return new Rectangle( minP.x, minP.y , maxP.x, maxP.y  );
			}
			return r;
		}
		
		override public function translate(offset:Vector2):GeometricShape
		{
			for each ( var point:Vector2 in points )
			{
				point.plus( offset );
			}
			return this;
		}
		
		override public function rotate( angle:Number, center:Vector2 = null ):GeometricShape
		{
			if ( center == null ) center = centroid;
			for each ( var p:Vector2 in points )
			{
				p.rotateAround(angle, center );
			}
			dirty = true;
			return this;
		}
		
		override public function getNormalAtPoint(p:Vector2):Vector2
		{
			var path:LinearPath = toLinearPath( 1 ) ;
			return path.getNormalAtPoint( p );
		}
	
		private function updateLookupTables():void
		{
			t_toSegments = new Vector.<Number>(segments.length, true );
			length_toSegments = new Vector.<Number>(segments.length, true );
			totalLength = 0; 
			for ( var i:int = 0; i < segments.length; i++ )
			{
				totalLength += segments[i].length;
				length_toSegments[i] = totalLength;
			}
			for ( i = segments.length; --i>-1; )
			{
				t_toSegments[i] = length_toSegments[i] / totalLength;
			}
		}
		
		public function appendPath( p:MixedPath ):void
		{
			points = points.concat( p.points );
			dirty = true;
		}
		
		
		override public function isInside( p:Vector2, includeVertices:Boolean = true ):Boolean
		{
			var r:Rectangle = getBoundingRect( true );
			var l:LineSegment = new LineSegment( p, new Vector2( r.x - 1, r.y - 1 ) );
			var intersection:Intersection = l.intersect( this );
			return (intersection.points.length % 2 != 0);
		}
	
		static public function fromString( s:String ):MixedPath
		{
			var path:MixedPath = new MixedPath();
			var p:Array = s.split(";");
			path.setLoop( p[0] == "closed" );
			p = p[1].split(",");
			var pt:Array 
			var v:Vector2;
			for (var i:int = 0;i<p.length;i++)
			{
				pt =  p[i].split("|");
				v = new Vector2(Number(pt[0]),Number(pt[1]));
				if (pt.length == 3)
				{
					path.addControlPoint(v,null,false);
				}
				else {
					path.addPoint(v,null,false);
				}
			}
			path.updateSegments();
			return path;
		}
		
		public function intersect ( that:IIntersectable ):Intersection 
		{
			return Intersection.intersect( this, that );
		};
		
	
		public function toString():String
		{
			var result:Array = [];
			for ( var i:int = 0;i<points.length;i++)
			{
				result[i] = MixedPathPoint(points[i]).toString();
			}
			return (loop ? "closed":"open") + ";" + result.join(",");
		}
	
		override public function get type():String
		{
			return "MixedPath";
		}

	}
}