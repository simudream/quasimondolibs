	package com.quasimondo.geom
	{
	
		import com.quasimondo.math.Polynomial;
		
		public class Intersection 
		{
			public static const INTERSECTION:String 	= "INTERSECTION";
			public static const NO_INTERSECTION:String  = "NO INTERSECTION";
			public static const COINCIDENT:String 		= "COINCIDENT";
			public static const PARALLEL:String 		= "PARALLEL";
			public static const INSIDE:String 			= "INSIDE";
			public static const OUTSIDE:String 			= "OUTSIDE";
			public static const TANGENT:String 			= "TANGENT";
			
			public const points:Vector.<Vector2> = new Vector.<Vector2>();
			public var status:String = Intersection.NO_INTERSECTION;
			private const SNAP_DISTANCE:Number = 0.0000000001;
		
			public static function intersect( shape1:IIntersectable, shape2:IIntersectable ):Intersection
			{
				
				switch(  shape1.type + shape2.type )
				{
					case "Bezier2Bezier2":
						return new Intersection().bezier2_bezier2( Bezier2(shape1), Bezier2(shape2) );
					break;
					case "Bezier2LineSegment":
						return new Intersection().bezier2_line( Bezier2(shape1), LineSegment(shape2) );
					break;
					case "LineSegmentBezier2":
						return new Intersection().bezier2_line( Bezier2(shape2), LineSegment(shape1) );
					break;
					case "Bezier2Ellipse":
						return new Intersection().bezier2_ellipse( Bezier2(shape1), Ellipse(shape2) );
					break;
					case "EllipseBezier2":
						return new Intersection().bezier2_ellipse( Bezier2(shape2), Ellipse(shape1) );
					break;
					case "LineSegmentLineSegment":
						return new Intersection().line_line( LineSegment(shape1), LineSegment(shape2) );
					break;
					case "EllipseLineSegment":
						return new Intersection().ellipse_line( Ellipse(shape1), LineSegment(shape2) );
					break;
					case "LineSegmentEllipse":
						return new Intersection().ellipse_line( Ellipse(shape2), LineSegment(shape1) );
					break;
					case "EllipseEllipse":
						return new Intersection().ellipse_ellipse( Ellipse(shape1), Ellipse(shape2) );
					break;
					case "CircleLineSegment":
						return new Intersection().circle_line( Circle(shape1), LineSegment(shape2) );
					break;
					case "LineSegmentCircle":
						return new Intersection().circle_line( Circle(shape2), LineSegment(shape1) );
					break;
					case "CircleCircle":
						return new Intersection().circle_circle( Circle(shape1), Circle(shape2) );
					break;
					case "Bezier2Bezier3":
						return new Intersection().bezier2_bezier3( Bezier2(shape1), Bezier3(shape2) );
					break;
					case "Bezier3Bezier2":
						return new Intersection().bezier2_bezier3( Bezier2(shape2), Bezier3(shape1) );
					break;
					case "Bezier3Bezier3":
						return new Intersection().bezier3_bezier3( Bezier3(shape2), Bezier3(shape1) );
						break;
					case "Bezier3LineSegment":
						return new Intersection().bezier3_line( Bezier3(shape1), LineSegment(shape2) );
					break;
					case "LineSegmentBezier3":
						return new Intersection().bezier3_line( Bezier3(shape2), LineSegment(shape1) );
					break;
					case "TriangleLineSegment":
						return new Intersection().line_triangle( LineSegment(shape2), Triangle(shape1) );
					break;
					case "LineSegmentTriangle":
						return new Intersection().line_triangle( LineSegment(shape1), Triangle(shape2) );
					break;
					case "PolygonLineSegment":
						return new Intersection().line_polygon( LineSegment(shape2), Polygon(shape1) );
					break;
					case "LineSegmentPolygon":
						return new Intersection().line_polygon( LineSegment(shape1), Polygon(shape2) );
					break;
					case "ConvexPolygonLineSegment":
						return new Intersection().line_convexPolygon( LineSegment(shape2), ConvexPolygon(shape1) );
					break;
					case "ConvexPolygonConvexPolygon":
						return new Intersection().convexPolygon_convexPolygon( ConvexPolygon(shape2), ConvexPolygon(shape1) );
					break;
					case "LineSegmentConvexPolygon":
						return new Intersection().line_convexPolygon( LineSegment(shape1), ConvexPolygon(shape2) );
					break;
					case "LineSegmentMixedPath":
						return new Intersection().line_mixedPath( LineSegment(shape1), MixedPath(shape2) );
					break;
					case "MixedPathLineSegment":
						return new Intersection().line_mixedPath( LineSegment(shape2), MixedPath(shape1) );
					break;
					case "PolygonPolygon":
						return new Intersection().Polygon_Polygon( Polygon(shape2), Polygon(shape1) );
					break;
					
				}
				return null;
			
			}
			
			function Intersection() 
			{
			}
	
			public function appendPoint( p:Vector2):void
			{
				for each ( var point:Vector2 in points )
				{
					if ( point.squaredDistanceToVector( p ) <= SNAP_DISTANCE ) return;
				}
				points.push(p);
			}
			
			public function bezier2_bezier2( bz1:Bezier2, bz2:Bezier2):Intersection
			{
				var poly:Polynomial;
				var TOLERANCE:Number = 1e-4;
				
				var a1:Vector2 = bz1.p1;
				var a2:Vector2 = bz1.c;
				var a3:Vector2 = bz1.p2;
				var b1:Vector2 = bz2.p1;
				var b2:Vector2 = bz2.c;
				var b3:Vector2 = bz2.p2;
				
				var va:Vector2, vb:Vector2;
				va=a2.getMultiply(-2);
				var c12:Vector2=a1.getPlus(va.getPlus(a3));
				va=a1.getMultiply(-2);
				vb=a2.getMultiply(2);
				var c11:Vector2=va.getPlus(vb);
				var c10:Vector2=new Vector2(a1.x,a1.y);
				va=b2.getMultiply(-2);
				var c22:Vector2=b1.getPlus(va.getPlus(b3));
				va=b1.getMultiply(-2);
				vb=b2.getMultiply(2);
				var c21:Vector2=va.getPlus(vb);
				var c20:Vector2 = new Vector2(b1.x,b1.y);
				
				var a:Number = c12.x*c11.y-c11.x*c12.y;
				var b:Number = c22.x*c11.y-c11.x*c22.y;
				var c:Number = c21.x*c11.y-c11.x*c21.y;
				var d:Number = c11.x*(c10.y-c20.y)+c11.y*(-c10.x+c20.x);
				var e:Number = c22.x*c12.y-c12.x*c22.y;
				var f:Number = c21.x*c12.y-c12.x*c21.y;
				var g:Number = c12.x*(c10.y-c20.y)+c12.y*(-c10.x+c20.x);
				
				poly = new Polynomial(-e*e,-2*e*f,a*b-f*f-2*e*g,a*c-2*f*g,a*d-g*g);
				var roots:Vector.<Number> = poly.getRoots();
				
				for( var i:int = 0; i < roots.length;i++)
				{
					var s:Number = roots[i];
					if(0<=s&&s<=1)
					{
						var xRoots:Vector.<Number> = new Polynomial(-c12.x,-c11.x,-c10.x+c20.x+s*c21.x+s*s*c22.x).getRoots();
						var yRoots:Vector.<Number> = new Polynomial(-c12.y,-c11.y,-c10.y+c20.y+s*c21.y+s*s*c22.y).getRoots();
						if( xRoots.length>0&&yRoots.length>0)
						{
							checkRoots:
							for(var j:int = 0; j < xRoots.length;j++)
							{
								var xRoot:Number = xRoots[j];
								if(0<=xRoot&&xRoot<=1)
								{
									for(var k:int=0;k<yRoots.length;k++)
									{
										if(Math.abs(xRoot-yRoots[k])<TOLERANCE)
										{
											points.push(c22.multiply(s*s).plus(c21.multiply(s).plus(c20)));
											break checkRoots;
										}
									}
								}
							}
						}
					}
				}
				if ( points.length > 0 ) {
					status = Intersection.INTERSECTION;
				}
				
				/*
				var v0:Number, v1:Number, v2:Number, v3:Number;
				if (c12.y == 0) 
				{
					v0 = c12.x*(c10.y-c20.y);
					v1 = v0-c11.x*c11.y;
					v2 = v0+v1;
					v3 = c11.y*c11.y;
					poly = new Polynomial(c12.x*c22.y*c22.y, 2*c12.x*c21.y*c22.y, c12.x*c21.y*c21.y-c22.x*v3-c22.y*v0-c22.y*v1, -c21.x*v3-c21.y*v0-c21.y*v1, (c10.x-c20.x)*v3+(c10.y-c20.y)*v1);
				} else {
					v0 = c12.x*c22.y-c12.y*c22.x;
					v1 = c12.x*c21.y-c21.x*c12.y;
					v2 = c11.x*c12.y-c11.y*c12.x;
					v3 = c10.y-c20.y;
					var v4:Number = c12.y*(c10.x-c20.x)-c12.x*v3;
					var v5:Number = -c11.y*v2+c12.y*v4;
					var v6:Number = v2*v2;
					poly = new Polynomial(v0*v0, 2*v0*v1, (-c22.y*v6+c12.y*v1*v1+c12.y*v0*v4+v0*v5)/c12.y, (-c21.y*v6+c12.y*v1*v4+v1*v5)/c12.y, (v3*v6+v4*v5)/c12.y);
				}
				var roots:Vector.<Number> = poly.getRoots();
				for (var i:Number = 0; i<roots.length; i++) 
				{
					var s:Number = roots[i];
					if (0<=s && s<=1) 
					{
						var xRoots:Vector.<Number> = new Polynomial(c12.x, c11.x, c10.x-c20.x-s*c21.x-s*s*c22.x).getRoots();
						var yRoots:Vector.<Number> = new Polynomial(c12.y, c11.y, c10.y-c20.y-s*c21.y-s*s*c22.y).getRoots();
						if (xRoots.length>0 && yRoots.length>0) {
							var TOLERANCE:Number = 1e-8;
							//checkRoots:
							for (var j:Number = 0; j<xRoots.length; j++) 
							{
								var xRoot:Number = xRoots[j];
								if (0<=xRoot && xRoot<=1) {
									for (var k:Number = 0; k<yRoots.length; k++) 
									{
										if (Math.abs(xRoot-yRoots[k])<TOLERANCE) 
										{
											appendPoint(c22.getMultiply(s*s).plus(c21.getMultiply(s).plus(c20)));
											j = xRoots.length;
											break;
											//checkRoots;
										}
									}
								}
							}
						}
					}
				}
			
				if ( points.length > 0 ) {
					status = Intersection.INTERSECTION;
				}
			*/
				return this;
			};
			
			
			public function bezier3_bezier3( bz1:Bezier3, bz2:Bezier3):Intersection
			{
				var a1:Vector2 = bz1.p1;
				var a2:Vector2 = bz1.c1;
				var a3:Vector2 = bz1.c2;
				var a4:Vector2 = bz1.p2;
				var b1:Vector2 = bz2.p1;
				var b2:Vector2 = bz2.c1;
				var b3:Vector2 = bz2.c2;
				var b4:Vector2 = bz2.p2;
				
				var a:Vector2,b:Vector2,c:Vector2,d:Vector2;
				var c13:Vector2,c12:Vector2,c11:Vector2,c10:Vector2;
				var c23:Vector2,c22:Vector2,c21:Vector2,c20:Vector2;
				
				a=a1.getMultiply(-1);
				b=a2.getMultiply(3);
				c=a3.getMultiply(-3);
				d=a.getPlus(b.getPlus(c.getPlus(a4)));
				c13=new Vector2(d.x,d.y);
				a=a1.getMultiply(3);
				b=a2.getMultiply(-6);
				c=a3.getMultiply(3);
				d=a.getPlus(b.getPlus(c));
				c12=new Vector2(d.x,d.y);
				a=a1.getMultiply(-3);
				b=a2.getMultiply(3);
				c=a.getPlus(b);
				c11=new Vector2(c.x,c.y);
				c10=new Vector2(a1.x,a1.y);
				a=b1.multiply(-1);
				b=b2.multiply(3);
				c=b3.multiply(-3);
				d=a.getPlus(b.getPlus(c.getPlus(b4)));
				c23=new Vector2(d.x,d.y);
				a=b1.multiply(3);
				b=b2.multiply(-6);
				c=b3.multiply(3);
				d=a.getPlus(b.getPlus(c));
				c22=new Vector2(d.x,d.y);
				a=b1.multiply(-3);
				b=b2.multiply(3);
				c=a.getPlus(b);
				c21=new Vector2(c.x,c.y);
				c20=new Vector2(b1.x,b1.y);
				
				var c10x2:Number=c10.x*c10.x;
				var c10x3:Number=c10.x*c10.x*c10.x;
				var c10y2:Number=c10.y*c10.y;
				var c10y3:Number=c10.y*c10.y*c10.y;
				var c11x2:Number=c11.x*c11.x;
				var c11x3:Number=c11.x*c11.x*c11.x;
				var c11y2:Number=c11.y*c11.y;
				var c11y3:Number=c11.y*c11.y*c11.y;
				var c12x2:Number=c12.x*c12.x;
				var c12x3:Number=c12.x*c12.x*c12.x;
				var c12y2:Number=c12.y*c12.y;
				var c12y3:Number=c12.y*c12.y*c12.y;
				var c13x2:Number=c13.x*c13.x;
				var c13x3:Number=c13.x*c13.x*c13.x;
				var c13y2:Number=c13.y*c13.y;
				var c13y3:Number=c13.y*c13.y*c13.y;
				var c20x2:Number=c20.x*c20.x;
				var c20x3:Number=c20.x*c20.x*c20.x;
				var c20y2:Number=c20.y*c20.y;
				var c20y3:Number=c20.y*c20.y*c20.y;
				var c21x2:Number=c21.x*c21.x;
				var c21x3:Number=c21.x*c21.x*c21.x;
				var c21y2:Number=c21.y*c21.y;
				var c22x2:Number=c22.x*c22.x;
				var c22x3:Number=c22.x*c22.x*c22.x;
				var c22y2:Number=c22.y*c22.y;
				var c23x2:Number=c23.x*c23.x;
				var c23x3:Number=c23.x*c23.x*c23.x;
				var c23y2:Number=c23.y*c23.y;
				var c23y3:Number=c23.y*c23.y*c23.y;
				var poly:Polynomial=new Polynomial(-c13x3*c23y3+c13y3*c23x3-3*c13.x*c13y2*c23x2*c23.y+3*c13x2*c13.y*c23.x*c23y2,-6*c13.x*c22.x*c13y2*c23.x*c23.y+6*c13x2*c13.y*c22.y*c23.x*c23.y+3*c22.x*c13y3*c23x2-3*c13x3*c22.y*c23y2-3*c13.x*c13y2*c22.y*c23x2+3*c13x2*c22.x*c13.y*c23y2,-6*c21.x*c13.x*c13y2*c23.x*c23.y-6*c13.x*c22.x*c13y2*c22.y*c23.x+6*c13x2*c22.x*c13.y*c22.y*c23.y+3*c21.x*c13y3*c23x2+3*c22x2*c13y3*c23.x+3*c21.x*c13x2*c13.y*c23y2-3*c13.x*c21.y*c13y2*c23x2-3*c13.x*c22x2*c13y2*c23.y+c13x2*c13.y*c23.x*(6*c21.y*c23.y+3*c22y2)+c13x3*(-c21.y*c23y2-2*c22y2*c23.y-c23.y*(2*c21.y*c23.y+c22y2)),c11.x*c12.y*c13.x*c13.y*c23.x*c23.y-c11.y*c12.x*c13.x*c13.y*c23.x*c23.y+6*c21.x*c22.x*c13y3*c23.x+3*c11.x*c12.x*c13.x*c13.y*c23y2+6*c10.x*c13.x*c13y2*c23.x*c23.y-3*c11.x*c12.x*c13y2*c23.x*c23.y-3*c11.y*c12.y*c13.x*c13.y*c23x2-6*c10.y*c13x2*c13.y*c23.x*c23.y-6*c20.x*c13.x*c13y2*c23.x*c23.y+3*c11.y*c12.y*c13x2*c23.x*c23.y-2*c12.x*c12y2*c13.x*c23.x*c23.y-6*c21.x*c13.x*c22.x*c13y2*c23.y-6*c21.x*c13.x*c13y2*c22.y*c23.x-6*c13.x*c21.y*c22.x*c13y2*c23.x+6*c21.x*c13x2*c13.y*c22.y*c23.y+2*c12x2*c12.y*c13.y*c23.x*c23.y+c22x3*c13y3-3*c10.x*c13y3*c23x2+3*c10.y*c13x3*c23y2+3*c20.x*c13y3*c23x2+c12y3*c13.x*c23x2-c12x3*c13.y*c23y2-3*c10.x*c13x2*c13.y*c23y2+3*c10.y*c13.x*c13y2*c23x2-2*c11.x*c12.y*c13x2*c23y2+c11.x*c12.y*c13y2*c23x2-c11.y*c12.x*c13x2*c23y2+2*c11.y*c12.x*c13y2*c23x2+3*c20.x*c13x2*c13.y*c23y2-c12.x*c12y2*c13.y*c23x2-3*c20.y*c13.x*c13y2*c23x2+c12x2*c12.y*c13.x*c23y2-3*c13.x*c22x2*c13y2*c22.y+c13x2*c13.y*c23.x*(6*c20.y*c23.y+6*c21.y*c22.y)+c13x2*c22.x*c13.y*(6*c21.y*c23.y+3*c22y2)+c13x3*(-2*c21.y*c22.y*c23.y-c20.y*c23y2-c22.y*(2*c21.y*c23.y+c22y2)-c23.y*(2*c20.y*c23.y+2*c21.y*c22.y)),6*c11.x*c12.x*c13.x*c13.y*c22.y*c23.y+c11.x*c12.y*c13.x*c22.x*c13.y*c23.y+c11.x*c12.y*c13.x*c13.y*c22.y*c23.x-c11.y*c12.x*c13.x*c22.x*c13.y*c23.y-c11.y*c12.x*c13.x*c13.y*c22.y*c23.x-6*c11.y*c12.y*c13.x*c22.x*c13.y*c23.x-6*c10.x*c22.x*c13y3*c23.x+6*c20.x*c22.x*c13y3*c23.x+6*c10.y*c13x3*c22.y*c23.y+2*c12y3*c13.x*c22.x*c23.x-2*c12x3*c13.y*c22.y*c23.y+6*c10.x*c13.x*c22.x*c13y2*c23.y+6*c10.x*c13.x*c13y2*c22.y*c23.x+6*c10.y*c13.x*c22.x*c13y2*c23.x-3*c11.x*c12.x*c22.x*c13y2*c23.y-3*c11.x*c12.x*c13y2*c22.y*c23.x+2*c11.x*c12.y*c22.x*c13y2*c23.x+4*c11.y*c12.x*c22.x*c13y2*c23.x-6*c10.x*c13x2*c13.y*c22.y*c23.y-6*c10.y*c13x2*c22.x*c13.y*c23.y-6*c10.y*c13x2*c13.y*c22.y*c23.x-4*c11.x*c12.y*c13x2*c22.y*c23.y-6*c20.x*c13.x*c22.x*c13y2*c23.y-6*c20.x*c13.x*c13y2*c22.y*c23.x-2*c11.y*c12.x*c13x2*c22.y*c23.y+3*c11.y*c12.y*c13x2*c22.x*c23.y+3*c11.y*c12.y*c13x2*c22.y*c23.x-2*c12.x*c12y2*c13.x*c22.x*c23.y-2*c12.x*c12y2*c13.x*c22.y*c23.x-2*c12.x*c12y2*c22.x*c13.y*c23.x-6*c20.y*c13.x*c22.x*c13y2*c23.x-6*c21.x*c13.x*c21.y*c13y2*c23.x-6*c21.x*c13.x*c22.x*c13y2*c22.y+6*c20.x*c13x2*c13.y*c22.y*c23.y+2*c12x2*c12.y*c13.x*c22.y*c23.y+2*c12x2*c12.y*c22.x*c13.y*c23.y+2*c12x2*c12.y*c13.y*c22.y*c23.x+3*c21.x*c22x2*c13y3+3*c21x2*c13y3*c23.x-3*c13.x*c21.y*c22x2*c13y2-3*c21x2*c13.x*c13y2*c23.y+c13x2*c22.x*c13.y*(6*c20.y*c23.y+6*c21.y*c22.y)+c13x2*c13.y*c23.x*(6*c20.y*c22.y+3*c21y2)+c21.x*c13x2*c13.y*(6*c21.y*c23.y+3*c22y2)+c13x3*(-2*c20.y*c22.y*c23.y-c23.y*(2*c20.y*c22.y+c21y2)-c21.y*(2*c21.y*c23.y+c22y2)-c22.y*(2*c20.y*c23.y+2*c21.y*c22.y)),c11.x*c21.x*c12.y*c13.x*c13.y*c23.y+c11.x*c12.y*c13.x*c21.y*c13.y*c23.x+c11.x*c12.y*c13.x*c22.x*c13.y*c22.y-c11.y*c12.x*c21.x*c13.x*c13.y*c23.y-c11.y*c12.x*c13.x*c21.y*c13.y*c23.x-c11.y*c12.x*c13.x*c22.x*c13.y*c22.y-6*c11.y*c21.x*c12.y*c13.x*c13.y*c23.x-6*c10.x*c21.x*c13y3*c23.x+6*c20.x*c21.x*c13y3*c23.x+2*c21.x*c12y3*c13.x*c23.x+6*c10.x*c21.x*c13.x*c13y2*c23.y+6*c10.x*c13.x*c21.y*c13y2*c23.x+6*c10.x*c13.x*c22.x*c13y2*c22.y+6*c10.y*c21.x*c13.x*c13y2*c23.x-3*c11.x*c12.x*c21.x*c13y2*c23.y-3*c11.x*c12.x*c21.y*c13y2*c23.x-3*c11.x*c12.x*c22.x*c13y2*c22.y+2*c11.x*c21.x*c12.y*c13y2*c23.x+4*c11.y*c12.x*c21.x*c13y2*c23.x-6*c10.y*c21.x*c13x2*c13.y*c23.y-6*c10.y*c13x2*c21.y*c13.y*c23.x-6*c10.y*c13x2*c22.x*c13.y*c22.y-6*c20.x*c21.x*c13.x*c13y2*c23.y-6*c20.x*c13.x*c21.y*c13y2*c23.x-6*c20.x*c13.x*c22.x*c13y2*c22.y+3*c11.y*c21.x*c12.y*c13x2*c23.y-3*c11.y*c12.y*c13.x*c22x2*c13.y+3*c11.y*c12.y*c13x2*c21.y*c23.x+3*c11.y*c12.y*c13x2*c22.x*c22.y-2*c12.x*c21.x*c12y2*c13.x*c23.y-2*c12.x*c21.x*c12y2*c13.y*c23.x-2*c12.x*c12y2*c13.x*c21.y*c23.x-2*c12.x*c12y2*c13.x*c22.x*c22.y-6*c20.y*c21.x*c13.x*c13y2*c23.x-6*c21.x*c13.x*c21.y*c22.x*c13y2+6*c20.y*c13x2*c21.y*c13.y*c23.x+2*c12x2*c21.x*c12.y*c13.y*c23.y+2*c12x2*c12.y*c21.y*c13.y*c23.x+2*c12x2*c12.y*c22.x*c13.y*c22.y-3*c10.x*c22x2*c13y3+3*c20.x*c22x2*c13y3+3*c21x2*c22.x*c13y3+c12y3*c13.x*c22x2+3*c10.y*c13.x*c22x2*c13y2+c11.x*c12.y*c22x2*c13y2+2*c11.y*c12.x*c22x2*c13y2-c12.x*c12y2*c22x2*c13.y-3*c20.y*c13.x*c22x2*c13y2-3*c21x2*c13.x*c13y2*c22.y+c12x2*c12.y*c13.x*(2*c21.y*c23.y+c22y2)+c11.x*c12.x*c13.x*c13.y*(6*c21.y*c23.y+3*c22y2)+c21.x*c13x2*c13.y*(6*c20.y*c23.y+6*c21.y*c22.y)+c12x3*c13.y*(-2*c21.y*c23.y-c22y2)+c10.y*c13x3*(6*c21.y*c23.y+3*c22y2)+c11.y*c12.x*c13x2*(-2*c21.y*c23.y-c22y2)+c11.x*c12.y*c13x2*(-4*c21.y*c23.y-2*c22y2)+c10.x*c13x2*c13.y*(-6*c21.y*c23.y-3*c22y2)+c13x2*c22.x*c13.y*(6*c20.y*c22.y+3*c21y2)+c20.x*c13x2*c13.y*(6*c21.y*c23.y+3*c22y2)+c13x3*(-2*c20.y*c21.y*c23.y-c22.y*(2*c20.y*c22.y+c21y2)-c20.y*(2*c21.y*c23.y+c22y2)-c21.y*(2*c20.y*c23.y+2*c21.y*c22.y)),-c10.x*c11.x*c12.y*c13.x*c13.y*c23.y+c10.x*c11.y*c12.x*c13.x*c13.y*c23.y+6*c10.x*c11.y*c12.y*c13.x*c13.y*c23.x-6*c10.y*c11.x*c12.x*c13.x*c13.y*c23.y-c10.y*c11.x*c12.y*c13.x*c13.y*c23.x+c10.y*c11.y*c12.x*c13.x*c13.y*c23.x+c11.x*c11.y*c12.x*c12.y*c13.x*c23.y-c11.x*c11.y*c12.x*c12.y*c13.y*c23.x+c11.x*c20.x*c12.y*c13.x*c13.y*c23.y+c11.x*c20.y*c12.y*c13.x*c13.y*c23.x+c11.x*c21.x*c12.y*c13.x*c13.y*c22.y+c11.x*c12.y*c13.x*c21.y*c22.x*c13.y-c20.x*c11.y*c12.x*c13.x*c13.y*c23.y-6*c20.x*c11.y*c12.y*c13.x*c13.y*c23.x-c11.y*c12.x*c20.y*c13.x*c13.y*c23.x-c11.y*c12.x*c21.x*c13.x*c13.y*c22.y-c11.y*c12.x*c13.x*c21.y*c22.x*c13.y-6*c11.y*c21.x*c12.y*c13.x*c22.x*c13.y-6*c10.x*c20.x*c13y3*c23.x-6*c10.x*c21.x*c22.x*c13y3-2*c10.x*c12y3*c13.x*c23.x+6*c20.x*c21.x*c22.x*c13y3+2*c20.x*c12y3*c13.x*c23.x+2*c21.x*c12y3*c13.x*c22.x+2*c10.y*c12x3*c13.y*c23.y-6*c10.x*c10.y*c13.x*c13y2*c23.x+3*c10.x*c11.x*c12.x*c13y2*c23.y-2*c10.x*c11.x*c12.y*c13y2*c23.x-4*c10.x*c11.y*c12.x*c13y2*c23.x+3*c10.y*c11.x*c12.x*c13y2*c23.x+6*c10.x*c10.y*c13x2*c13.y*c23.y+6*c10.x*c20.x*c13.x*c13y2*c23.y-3*c10.x*c11.y*c12.y*c13x2*c23.y+2*c10.x*c12.x*c12y2*c13.x*c23.y+2*c10.x*c12.x*c12y2*c13.y*c23.x+6*c10.x*c20.y*c13.x*c13y2*c23.x+6*c10.x*c21.x*c13.x*c13y2*c22.y+6*c10.x*c13.x*c21.y*c22.x*c13y2+4*c10.y*c11.x*c12.y*c13x2*c23.y+6*c10.y*c20.x*c13.x*c13y2*c23.x+2*c10.y*c11.y*c12.x*c13x2*c23.y-3*c10.y*c11.y*c12.y*c13x2*c23.x+2*c10.y*c12.x*c12y2*c13.x*c23.x+6*c10.y*c21.x*c13.x*c22.x*c13y2-3*c11.x*c20.x*c12.x*c13y2*c23.y+2*c11.x*c20.x*c12.y*c13y2*c23.x+c11.x*c11.y*c12y2*c13.x*c23.x-3*c11.x*c12.x*c20.y*c13y2*c23.x-3*c11.x*c12.x*c21.x*c13y2*c22.y-3*c11.x*c12.x*c21.y*c22.x*c13y2+2*c11.x*c21.x*c12.y*c22.x*c13y2+4*c20.x*c11.y*c12.x*c13y2*c23.x+4*c11.y*c12.x*c21.x*c22.x*c13y2-2*c10.x*c12x2*c12.y*c13.y*c23.y-6*c10.y*c20.x*c13x2*c13.y*c23.y-6*c10.y*c20.y*c13x2*c13.y*c23.x-6*c10.y*c21.x*c13x2*c13.y*c22.y-2*c10.y*c12x2*c12.y*c13.x*c23.y-2*c10.y*c12x2*c12.y*c13.y*c23.x-6*c10.y*c13x2*c21.y*c22.x*c13.y-c11.x*c11.y*c12x2*c13.y*c23.y-2*c11.x*c11y2*c13.x*c13.y*c23.x+3*c20.x*c11.y*c12.y*c13x2*c23.y-2*c20.x*c12.x*c12y2*c13.x*c23.y-2*c20.x*c12.x*c12y2*c13.y*c23.x-6*c20.x*c20.y*c13.x*c13y2*c23.x-6*c20.x*c21.x*c13.x*c13y2*c22.y-6*c20.x*c13.x*c21.y*c22.x*c13y2+3*c11.y*c20.y*c12.y*c13x2*c23.x+3*c11.y*c21.x*c12.y*c13x2*c22.y+3*c11.y*c12.y*c13x2*c21.y*c22.x-2*c12.x*c20.y*c12y2*c13.x*c23.x-2*c12.x*c21.x*c12y2*c13.x*c22.y-2*c12.x*c21.x*c12y2*c22.x*c13.y-2*c12.x*c12y2*c13.x*c21.y*c22.x-6*c20.y*c21.x*c13.x*c22.x*c13y2-c11y2*c12.x*c12.y*c13.x*c23.x+2*c20.x*c12x2*c12.y*c13.y*c23.y+6*c20.y*c13x2*c21.y*c22.x*c13.y+2*c11x2*c11.y*c13.x*c13.y*c23.y+c11x2*c12.x*c12.y*c13.y*c23.y+2*c12x2*c20.y*c12.y*c13.y*c23.x+2*c12x2*c21.x*c12.y*c13.y*c22.y+2*c12x2*c12.y*c21.y*c22.x*c13.y+c21x3*c13y3+3*c10x2*c13y3*c23.x-3*c10y2*c13x3*c23.y+3*c20x2*c13y3*c23.x+c11y3*c13x2*c23.x-c11x3*c13y2*c23.y-c11.x*c11y2*c13x2*c23.y+c11x2*c11.y*c13y2*c23.x-3*c10x2*c13.x*c13y2*c23.y+3*c10y2*c13x2*c13.y*c23.x-c11x2*c12y2*c13.x*c23.y+c11y2*c12x2*c13.y*c23.x-3*c21x2*c13.x*c21.y*c13y2-3*c20x2*c13.x*c13y2*c23.y+3*c20y2*c13x2*c13.y*c23.x+c11.x*c12.x*c13.x*c13.y*(6*c20.y*c23.y+6*c21.y*c22.y)+c12x3*c13.y*(-2*c20.y*c23.y-2*c21.y*c22.y)+c10.y*c13x3*(6*c20.y*c23.y+6*c21.y*c22.y)+c11.y*c12.x*c13x2*(-2*c20.y*c23.y-2*c21.y*c22.y)+c12x2*c12.y*c13.x*(2*c20.y*c23.y+2*c21.y*c22.y)+c11.x*c12.y*c13x2*(-4*c20.y*c23.y-4*c21.y*c22.y)+c10.x*c13x2*c13.y*(-6*c20.y*c23.y-6*c21.y*c22.y)+c20.x*c13x2*c13.y*(6*c20.y*c23.y+6*c21.y*c22.y)+c21.x*c13x2*c13.y*(6*c20.y*c22.y+3*c21y2)+c13x3*(-2*c20.y*c21.y*c22.y-c20y2*c23.y-c21.y*(2*c20.y*c22.y+c21y2)-c20.y*(2*c20.y*c23.y+2*c21.y*c22.y)),-c10.x*c11.x*c12.y*c13.x*c13.y*c22.y+c10.x*c11.y*c12.x*c13.x*c13.y*c22.y+6*c10.x*c11.y*c12.y*c13.x*c22.x*c13.y-6*c10.y*c11.x*c12.x*c13.x*c13.y*c22.y-c10.y*c11.x*c12.y*c13.x*c22.x*c13.y+c10.y*c11.y*c12.x*c13.x*c22.x*c13.y+c11.x*c11.y*c12.x*c12.y*c13.x*c22.y-c11.x*c11.y*c12.x*c12.y*c22.x*c13.y+c11.x*c20.x*c12.y*c13.x*c13.y*c22.y+c11.x*c20.y*c12.y*c13.x*c22.x*c13.y+c11.x*c21.x*c12.y*c13.x*c21.y*c13.y-c20.x*c11.y*c12.x*c13.x*c13.y*c22.y-6*c20.x*c11.y*c12.y*c13.x*c22.x*c13.y-c11.y*c12.x*c20.y*c13.x*c22.x*c13.y-c11.y*c12.x*c21.x*c13.x*c21.y*c13.y-6*c10.x*c20.x*c22.x*c13y3-2*c10.x*c12y3*c13.x*c22.x+2*c20.x*c12y3*c13.x*c22.x+2*c10.y*c12x3*c13.y*c22.y-6*c10.x*c10.y*c13.x*c22.x*c13y2+3*c10.x*c11.x*c12.x*c13y2*c22.y-2*c10.x*c11.x*c12.y*c22.x*c13y2-4*c10.x*c11.y*c12.x*c22.x*c13y2+3*c10.y*c11.x*c12.x*c22.x*c13y2+6*c10.x*c10.y*c13x2*c13.y*c22.y+6*c10.x*c20.x*c13.x*c13y2*c22.y-3*c10.x*c11.y*c12.y*c13x2*c22.y+2*c10.x*c12.x*c12y2*c13.x*c22.y+2*c10.x*c12.x*c12y2*c22.x*c13.y+6*c10.x*c20.y*c13.x*c22.x*c13y2+6*c10.x*c21.x*c13.x*c21.y*c13y2+4*c10.y*c11.x*c12.y*c13x2*c22.y+6*c10.y*c20.x*c13.x*c22.x*c13y2+2*c10.y*c11.y*c12.x*c13x2*c22.y-3*c10.y*c11.y*c12.y*c13x2*c22.x+2*c10.y*c12.x*c12y2*c13.x*c22.x-3*c11.x*c20.x*c12.x*c13y2*c22.y+2*c11.x*c20.x*c12.y*c22.x*c13y2+c11.x*c11.y*c12y2*c13.x*c22.x-3*c11.x*c12.x*c20.y*c22.x*c13y2-3*c11.x*c12.x*c21.x*c21.y*c13y2+4*c20.x*c11.y*c12.x*c22.x*c13y2-2*c10.x*c12x2*c12.y*c13.y*c22.y-6*c10.y*c20.x*c13x2*c13.y*c22.y-6*c10.y*c20.y*c13x2*c22.x*c13.y-6*c10.y*c21.x*c13x2*c21.y*c13.y-2*c10.y*c12x2*c12.y*c13.x*c22.y-2*c10.y*c12x2*c12.y*c22.x*c13.y-c11.x*c11.y*c12x2*c13.y*c22.y-2*c11.x*c11y2*c13.x*c22.x*c13.y+3*c20.x*c11.y*c12.y*c13x2*c22.y-2*c20.x*c12.x*c12y2*c13.x*c22.y-2*c20.x*c12.x*c12y2*c22.x*c13.y-6*c20.x*c20.y*c13.x*c22.x*c13y2-6*c20.x*c21.x*c13.x*c21.y*c13y2+3*c11.y*c20.y*c12.y*c13x2*c22.x+3*c11.y*c21.x*c12.y*c13x2*c21.y-2*c12.x*c20.y*c12y2*c13.x*c22.x-2*c12.x*c21.x*c12y2*c13.x*c21.y-c11y2*c12.x*c12.y*c13.x*c22.x+2*c20.x*c12x2*c12.y*c13.y*c22.y-3*c11.y*c21x2*c12.y*c13.x*c13.y+6*c20.y*c21.x*c13x2*c21.y*c13.y+2*c11x2*c11.y*c13.x*c13.y*c22.y+c11x2*c12.x*c12.y*c13.y*c22.y+2*c12x2*c20.y*c12.y*c22.x*c13.y+2*c12x2*c21.x*c12.y*c21.y*c13.y-3*c10.x*c21x2*c13y3+3*c20.x*c21x2*c13y3+3*c10x2*c22.x*c13y3-3*c10y2*c13x3*c22.y+3*c20x2*c22.x*c13y3+c21x2*c12y3*c13.x+c11y3*c13x2*c22.x-c11x3*c13y2*c22.y+3*c10.y*c21x2*c13.x*c13y2-c11.x*c11y2*c13x2*c22.y+c11.x*c21x2*c12.y*c13y2+2*c11.y*c12.x*c21x2*c13y2+c11x2*c11.y*c22.x*c13y2-c12.x*c21x2*c12y2*c13.y-3*c20.y*c21x2*c13.x*c13y2-3*c10x2*c13.x*c13y2*c22.y+3*c10y2*c13x2*c22.x*c13.y-c11x2*c12y2*c13.x*c22.y+c11y2*c12x2*c22.x*c13.y-3*c20x2*c13.x*c13y2*c22.y+3*c20y2*c13x2*c22.x*c13.y+c12x2*c12.y*c13.x*(2*c20.y*c22.y+c21y2)+c11.x*c12.x*c13.x*c13.y*(6*c20.y*c22.y+3*c21y2)+c12x3*c13.y*(-2*c20.y*c22.y-c21y2)+c10.y*c13x3*(6*c20.y*c22.y+3*c21y2)+c11.y*c12.x*c13x2*(-2*c20.y*c22.y-c21y2)+c11.x*c12.y*c13x2*(-4*c20.y*c22.y-2*c21y2)+c10.x*c13x2*c13.y*(-6*c20.y*c22.y-3*c21y2)+c20.x*c13x2*c13.y*(6*c20.y*c22.y+3*c21y2)+c13x3*(-2*c20.y*c21y2-c20y2*c22.y-c20.y*(2*c20.y*c22.y+c21y2)),-c10.x*c11.x*c12.y*c13.x*c21.y*c13.y+c10.x*c11.y*c12.x*c13.x*c21.y*c13.y+6*c10.x*c11.y*c21.x*c12.y*c13.x*c13.y-6*c10.y*c11.x*c12.x*c13.x*c21.y*c13.y-c10.y*c11.x*c21.x*c12.y*c13.x*c13.y+c10.y*c11.y*c12.x*c21.x*c13.x*c13.y-c11.x*c11.y*c12.x*c21.x*c12.y*c13.y+c11.x*c11.y*c12.x*c12.y*c13.x*c21.y+c11.x*c20.x*c12.y*c13.x*c21.y*c13.y+6*c11.x*c12.x*c20.y*c13.x*c21.y*c13.y+c11.x*c20.y*c21.x*c12.y*c13.x*c13.y-c20.x*c11.y*c12.x*c13.x*c21.y*c13.y-6*c20.x*c11.y*c21.x*c12.y*c13.x*c13.y-c11.y*c12.x*c20.y*c21.x*c13.x*c13.y-6*c10.x*c20.x*c21.x*c13y3-2*c10.x*c21.x*c12y3*c13.x+6*c10.y*c20.y*c13x3*c21.y+2*c20.x*c21.x*c12y3*c13.x+2*c10.y*c12x3*c21.y*c13.y-2*c12x3*c20.y*c21.y*c13.y-6*c10.x*c10.y*c21.x*c13.x*c13y2+3*c10.x*c11.x*c12.x*c21.y*c13y2-2*c10.x*c11.x*c21.x*c12.y*c13y2-4*c10.x*c11.y*c12.x*c21.x*c13y2+3*c10.y*c11.x*c12.x*c21.x*c13y2+6*c10.x*c10.y*c13x2*c21.y*c13.y+6*c10.x*c20.x*c13.x*c21.y*c13y2-3*c10.x*c11.y*c12.y*c13x2*c21.y+2*c10.x*c12.x*c21.x*c12y2*c13.y+2*c10.x*c12.x*c12y2*c13.x*c21.y+6*c10.x*c20.y*c21.x*c13.x*c13y2+4*c10.y*c11.x*c12.y*c13x2*c21.y+6*c10.y*c20.x*c21.x*c13.x*c13y2+2*c10.y*c11.y*c12.x*c13x2*c21.y-3*c10.y*c11.y*c21.x*c12.y*c13x2+2*c10.y*c12.x*c21.x*c12y2*c13.x-3*c11.x*c20.x*c12.x*c21.y*c13y2+2*c11.x*c20.x*c21.x*c12.y*c13y2+c11.x*c11.y*c21.x*c12y2*c13.x-3*c11.x*c12.x*c20.y*c21.x*c13y2+4*c20.x*c11.y*c12.x*c21.x*c13y2-6*c10.x*c20.y*c13x2*c21.y*c13.y-2*c10.x*c12x2*c12.y*c21.y*c13.y-6*c10.y*c20.x*c13x2*c21.y*c13.y-6*c10.y*c20.y*c21.x*c13x2*c13.y-2*c10.y*c12x2*c21.x*c12.y*c13.y-2*c10.y*c12x2*c12.y*c13.x*c21.y-c11.x*c11.y*c12x2*c21.y*c13.y-4*c11.x*c20.y*c12.y*c13x2*c21.y-2*c11.x*c11y2*c21.x*c13.x*c13.y+3*c20.x*c11.y*c12.y*c13x2*c21.y-2*c20.x*c12.x*c21.x*c12y2*c13.y-2*c20.x*c12.x*c12y2*c13.x*c21.y-6*c20.x*c20.y*c21.x*c13.x*c13y2-2*c11.y*c12.x*c20.y*c13x2*c21.y+3*c11.y*c20.y*c21.x*c12.y*c13x2-2*c12.x*c20.y*c21.x*c12y2*c13.x-c11y2*c12.x*c21.x*c12.y*c13.x+6*c20.x*c20.y*c13x2*c21.y*c13.y+2*c20.x*c12x2*c12.y*c21.y*c13.y+2*c11x2*c11.y*c13.x*c21.y*c13.y+c11x2*c12.x*c12.y*c21.y*c13.y+2*c12x2*c20.y*c21.x*c12.y*c13.y+2*c12x2*c20.y*c12.y*c13.x*c21.y+3*c10x2*c21.x*c13y3-3*c10y2*c13x3*c21.y+3*c20x2*c21.x*c13y3+c11y3*c21.x*c13x2-c11x3*c21.y*c13y2-3*c20y2*c13x3*c21.y-c11.x*c11y2*c13x2*c21.y+c11x2*c11.y*c21.x*c13y2-3*c10x2*c13.x*c21.y*c13y2+3*c10y2*c21.x*c13x2*c13.y-c11x2*c12y2*c13.x*c21.y+c11y2*c12x2*c21.x*c13.y-3*c20x2*c13.x*c21.y*c13y2+3*c20y2*c21.x*c13x2*c13.y,c10.x*c10.y*c11.x*c12.y*c13.x*c13.y-c10.x*c10.y*c11.y*c12.x*c13.x*c13.y+c10.x*c11.x*c11.y*c12.x*c12.y*c13.y-c10.y*c11.x*c11.y*c12.x*c12.y*c13.x-c10.x*c11.x*c20.y*c12.y*c13.x*c13.y+6*c10.x*c20.x*c11.y*c12.y*c13.x*c13.y+c10.x*c11.y*c12.x*c20.y*c13.x*c13.y-c10.y*c11.x*c20.x*c12.y*c13.x*c13.y-6*c10.y*c11.x*c12.x*c20.y*c13.x*c13.y+c10.y*c20.x*c11.y*c12.x*c13.x*c13.y-c11.x*c20.x*c11.y*c12.x*c12.y*c13.y+c11.x*c11.y*c12.x*c20.y*c12.y*c13.x+c11.x*c20.x*c20.y*c12.y*c13.x*c13.y-c20.x*c11.y*c12.x*c20.y*c13.x*c13.y-2*c10.x*c20.x*c12y3*c13.x+2*c10.y*c12x3*c20.y*c13.y-3*c10.x*c10.y*c11.x*c12.x*c13y2-6*c10.x*c10.y*c20.x*c13.x*c13y2+3*c10.x*c10.y*c11.y*c12.y*c13x2-2*c10.x*c10.y*c12.x*c12y2*c13.x-2*c10.x*c11.x*c20.x*c12.y*c13y2-c10.x*c11.x*c11.y*c12y2*c13.x+3*c10.x*c11.x*c12.x*c20.y*c13y2-4*c10.x*c20.x*c11.y*c12.x*c13y2+3*c10.y*c11.x*c20.x*c12.x*c13y2+6*c10.x*c10.y*c20.y*c13x2*c13.y+2*c10.x*c10.y*c12x2*c12.y*c13.y+2*c10.x*c11.x*c11y2*c13.x*c13.y+2*c10.x*c20.x*c12.x*c12y2*c13.y+6*c10.x*c20.x*c20.y*c13.x*c13y2-3*c10.x*c11.y*c20.y*c12.y*c13x2+2*c10.x*c12.x*c20.y*c12y2*c13.x+c10.x*c11y2*c12.x*c12.y*c13.x+c10.y*c11.x*c11.y*c12x2*c13.y+4*c10.y*c11.x*c20.y*c12.y*c13x2-3*c10.y*c20.x*c11.y*c12.y*c13x2+2*c10.y*c20.x*c12.x*c12y2*c13.x+2*c10.y*c11.y*c12.x*c20.y*c13x2+c11.x*c20.x*c11.y*c12y2*c13.x-3*c11.x*c20.x*c12.x*c20.y*c13y2-2*c10.x*c12x2*c20.y*c12.y*c13.y-6*c10.y*c20.x*c20.y*c13x2*c13.y-2*c10.y*c20.x*c12x2*c12.y*c13.y-2*c10.y*c11x2*c11.y*c13.x*c13.y-c10.y*c11x2*c12.x*c12.y*c13.y-2*c10.y*c12x2*c20.y*c12.y*c13.x-2*c11.x*c20.x*c11y2*c13.x*c13.y-c11.x*c11.y*c12x2*c20.y*c13.y+3*c20.x*c11.y*c20.y*c12.y*c13x2-2*c20.x*c12.x*c20.y*c12y2*c13.x-c20.x*c11y2*c12.x*c12.y*c13.x+3*c10y2*c11.x*c12.x*c13.x*c13.y+3*c11.x*c12.x*c20y2*c13.x*c13.y+2*c20.x*c12x2*c20.y*c12.y*c13.y-3*c10x2*c11.y*c12.y*c13.x*c13.y+2*c11x2*c11.y*c20.y*c13.x*c13.y+c11x2*c12.x*c20.y*c12.y*c13.y-3*c20x2*c11.y*c12.y*c13.x*c13.y-c10x3*c13y3+c10y3*c13x3+c20x3*c13y3-c20y3*c13x3-3*c10.x*c20x2*c13y3-c10.x*c11y3*c13x2+3*c10x2*c20.x*c13y3+c10.y*c11x3*c13y2+3*c10.y*c20y2*c13x3+c20.x*c11y3*c13x2+c10x2*c12y3*c13.x-3*c10y2*c20.y*c13x3-c10y2*c12x3*c13.y+c20x2*c12y3*c13.x-c11x3*c20.y*c13y2-c12x3*c20y2*c13.y-c10.x*c11x2*c11.y*c13y2+c10.y*c11.x*c11y2*c13x2-3*c10.x*c10y2*c13x2*c13.y-c10.x*c11y2*c12x2*c13.y+c10.y*c11x2*c12y2*c13.x-c11.x*c11y2*c20.y*c13x2+3*c10x2*c10.y*c13.x*c13y2+c10x2*c11.x*c12.y*c13y2+2*c10x2*c11.y*c12.x*c13y2-2*c10y2*c11.x*c12.y*c13x2-c10y2*c11.y*c12.x*c13x2+c11x2*c20.x*c11.y*c13y2-3*c10.x*c20y2*c13x2*c13.y+3*c10.y*c20x2*c13.x*c13y2+c11.x*c20x2*c12.y*c13y2-2*c11.x*c20y2*c12.y*c13x2+c20.x*c11y2*c12x2*c13.y-c11.y*c12.x*c20y2*c13x2-c10x2*c12.x*c12y2*c13.y-3*c10x2*c20.y*c13.x*c13y2+3*c10y2*c20.x*c13x2*c13.y+c10y2*c12x2*c12.y*c13.x-c11x2*c20.y*c12y2*c13.x+2*c20x2*c11.y*c12.x*c13y2+3*c20.x*c20y2*c13x2*c13.y-c20x2*c12.x*c12y2*c13.y-3*c20x2*c20.y*c13.x*c13y2+c12x2*c20y2*c12.y*c13.x);
				var TOLERANCE:Number=1e-4;
				var roots:Vector.<Number>=poly.getRootsInInterval(0,1);
				for(var i:int=0; i<roots.length;i++)
				{
					var s:Number=roots[i];
					var xRoots:Vector.<Number>=new Polynomial(c13.x,c12.x,c11.x,c10.x-c20.x-s*c21.x-s*s*c22.x-s*s*s*c23.x).getRoots();
					var yRoots:Vector.<Number>=new Polynomial(c13.y,c12.y,c11.y,c10.y-c20.y-s*c21.y-s*s*c22.y-s*s*s*c23.y).getRoots();
					if(xRoots.length>0&&yRoots.length>0)
					{
						
						checkRoots:
						for(var j:int=0;j<xRoots.length;j++)
						{
							var xRoot:Number=xRoots[j];
							if(0<=xRoot&&xRoot<=1)
							{
								for(var k:int=0;k<yRoots.length;k++)
								{
									if(Math.abs(xRoot-yRoots[k])<TOLERANCE)
									{
										points.push(c23.getMultiply(s*s*s).getPlus(c22.getMultiply(s*s).getPlus(c21.getMultiply(s).getPlus(c20))));
										break checkRoots;
									}
								}
							}
						}
					}
				}
				if(points.length>0) status="Intersection";
				return this;
			};
			
			
			public function bezier2_line( bz:Bezier2, l:LineSegment ):Intersection
			{ 
				var min:Vector2 = l.p1.getMin(l.p2);
				var max:Vector2 = l.p1.getMax(l.p2);
				
				var dx:Number = l.p2.x-l.p1.x
				var dy:Number = l.p1.y-l.p2.y;
				
				var c2:Number = dy*(bz.p1.x-2*bz.c.x+bz.p2.x)+dx*(bz.p1.y-2*bz.c.y+bz.p2.y);
				var c1:Number = dy*2*(bz.c.x-bz.p1.x)+dx*2*(bz.c.y-bz.p1.y);
				var c0:Number = dy*bz.p1.x+dx*bz.p1.y+l.p1.x*l.p2.y-l.p2.x*l.p1.y;
				
				var pN:Vector.<Number> = new Vector.<Number>();
				var p:Number = -c1/c2/2;
				var d:Number = p*p-c0/c2;
				if (d == 0) pN.push( p );
				else if (d>0)
				{ 
					d = Math.sqrt(d);
					pN.push(p-d,p+d);
				}
				
				for each (var t:Number in pN)
				{
					if (t>=0 && t<=1)
					{ 
						var b3x:Number = bz.p1.x + t*(bz.c.x-bz.p1.x)
						var b3y:Number = bz.p1.y + t*(bz.c.y-bz.p1.y);
						var b4x:Number = bz.c.x + t*(bz.p2.x-bz.c.x)
						var b4y:Number = bz.c.y + t*(bz.p2.y-bz.c.y);
						
						var b5:Vector2 = new Vector2(b3x+t*(b4x-b3x), b3y+t*(b4y-b3y));
						if (b5.x>=min.x && b5.x<=max.x && b5.y>=min.y && b5.y<=max.y) appendPoint(b5);
					}
				}
				if ( points.length >0 ) status = Intersection.INTERSECTION;
				return this;
			}
	
			
		public function line_line( l1:LineSegment, l2:LineSegment):Intersection
		{
			var ua_t:Number = (l2.p2.x-l2.p1.x)*(l1.p1.y-l2.p1.y)-(l2.p2.y-l2.p1.y)*(l1.p1.x-l2.p1.x);
			var ub_t:Number = (l1.p2.x-l1.p1.x)*(l1.p1.y-l2.p1.y)-(l1.p2.y-l1.p1.y)*(l1.p1.x-l2.p1.x);
			var u_b:Number  = (l2.p2.y-l2.p1.y)*(l1.p2.x-l1.p1.x)-(l2.p2.x-l2.p1.x)*(l1.p2.y-l1.p1.y);
			
			if (u_b != 0) 
			{
				var ua:Number = ua_t / u_b;
				var ub:Number = ub_t / u_b;
				if (0<=ua && ua<=1 && 0<=ub && ub<=1) 
				{
					points.push(new Vector2(l1.p1.x+ua*(l1.p2.x-l1.p1.x), l1.p1.y+ua*(l1.p2.y-l1.p1.y)));
					status = Intersection.INTERSECTION;
				} 
			} else {
				if (ua_t == 0 || ub_t == 0) {
					status = Intersection.COINCIDENT;
				} else {
					status = Intersection.PARALLEL;
				}
			}
			return this;
		};
		
		public function ellipse_line(e:Ellipse, l:LineSegment ):Intersection
		{
			var origin:Vector2 = new Vector2( l.p1 );
			var dir:Vector2 = l.p1.getMinus( l.p2 );
			var center:Vector2 = new Vector2( e.c );
			var diff:Vector2 = origin.getMinus(center);
			var mDir:Vector2 = new Vector2(dir.x / e.rx2, dir.y / e.ry2);
			var mDiff:Vector2 = new Vector2(diff.x/e.rx2, diff.y/e.ry2);
			var a:Number = dir.dot(mDir);
			var b:Number = dir.dot(mDiff);
			var c:Number = diff.dot(mDiff)-1.0;
			var d:Number = b*b-a*c;
			if (d<0) {
				status = Intersection.OUTSIDE;
			} else if (d>0) {
				var root:Number = Math.sqrt(d);
				var t_a:Number = (-b-root)/a;
				var t_b:Number = (-b+root)/a;
				if ((t_a<0 || 1<t_a) && (t_b<0 || 1<t_b)) {
					if ((t_a<0 && t_b<0) || (t_a>1 && t_b>1)) {
						status = Intersection.OUTSIDE;
					} else {
						status = Intersection.INSIDE;
					}
				} else {
					status = Intersection.INTERSECTION;
					if (0<=t_a && t_a<=1) {
						appendPoint(l.p1.getLerp(l.p2, t_a));
					}
					if (0<=t_b && t_b<=1) {
						appendPoint(l.p1.getLerp(l.p2, t_b));
					}
				}
			} else {
				var t:Number = -b/a;
				if (0<=t && t<=1) {
					status = Intersection.INTERSECTION;
					appendPoint(l.p1.getLerp(l.p2, t));
				} else {
					status = Intersection.OUTSIDE;
				}
			}
			return this;
		};
	
		public function bezier2_ellipse(bz:Bezier2, e:Ellipse):Intersection
		{
			var c0:Vector2 = bz.p1;
			var c1:Vector2 = bz.c;
			var c2:Vector2 = bz.p2;
			
			var roots:Vector.<Number> = new Polynomial(e.ry2*c2.x*c2.x+e.rx2*c2.y*c2.y, 2*(e.ry2*c2.x*c1.x+e.rx2*c2.y*c1.y), e.ry2*(2*c2.x*c0.x+c1.x*c1.x)+e.rx2*(2*c2.y*c0.y+c1.y*c1.y)-2*(e.ry2*e.c.x*c2.x+e.rx2*e.c.y*c2.y), 2*(e.ry2*c1.x*(c0.x-e.c.x)+e.rx2*c1.y*(c0.y-e.c.y)), e.ry2*(c0.x*c0.x+e.c.x*e.c.x)+e.rx2*(c0.y*c0.y+e.c.y*e.c.y)-2*(e.ry2*e.c.x*c0.x+e.rx2*e.c.y*c0.y)-e.rx2*e.ry2).getRoots();
			for (var i:Number = 0; i<roots.length; i++) {
				var t:Number = roots[i];
				if (0<=t && t<=1) {
					appendPoint(c2.getMultiply(t*t).plus(c1.multiply(t).plus(c0)));
				}
			}
			if (points.length>0) {
				status = Intersection.INTERSECTION;
			}
			return this;
		};
	
		public function ellipse_ellipse( e1:Ellipse, e2:Ellipse):Intersection
		{
			var a:Vector.<Number> = Vector.<Number>([e1.ry2, 0, e1.rx2, -2*e1.ry2*e1.c.x, -2*e1.rx2*e1.c.y, e1.ry2*e1.c.x*e1.c.x+e1.rx2*e1.c.y*e1.c.y-e1.rx2*e1.ry2]);
			var b:Vector.<Number> = Vector.<Number>([e2.ry2, 0, e2.rx2, -2*e2.ry2*e2.c.x, -2*e2.rx2*e2.c.y, e2.ry2*e2.c.x*e2.c.x+e2.rx2*e2.c.y*e2.c.y-e2.rx2*e2.ry2]);
			var yPoly:Polynomial = bezout(a, b);
			var yRoots:Vector.<Number> = yPoly.getRoots();
			var epsilon:Number = 1e-3;
			var norm0:Number = (a[0]*a[0]+2*a[1]*a[1]+a[2]*a[2])*epsilon;
			var norm1:Number = (b[0]*b[0]+2*b[1]*b[1]+b[2]*b[2])*epsilon;
			for (var y:int = 0; y < yRoots.length; y++ ) 
			{
				var xPoly:Polynomial = new Polynomial(a[0], a[3]+yRoots[y]*a[1], a[5]+yRoots[y]*(a[4]+yRoots[y]*a[2]));
				var xRoots:Vector.<Number> = xPoly.getRoots();
				for (var x:int = 0; x<xRoots.length; x++) {
					var test:Number = (a[0]*xRoots[x]+a[1]*yRoots[y]+a[3])*xRoots[x]+(a[2]*yRoots[y]+a[4])*yRoots[y]+a[5];
					if (Math.abs(test)<norm0) {
						test = (b[0]*xRoots[x]+b[1]*yRoots[y]+b[3])*xRoots[x]+(b[2]*yRoots[y]+b[4])*yRoots[y]+b[5];
						if (Math.abs(test)<norm1) {
							appendPoint(new Vector2(xRoots[x], yRoots[y]));
						}
					}
				}
			}
			if ( points.length > 0 ) 
			{
				status = Intersection.INTERSECTION;
			}
			return this;
		};
	
		public function circle_circle(c1:Circle, c2:Circle ):Intersection
		{
			var r_max:Number = c1.r+c2.r;
			var r_min:Number = Math.abs(c1.r-c2.r);
			var c_dist:Number = c1.c.distanceToVector( c2.c );
			if (c_dist == 0 && r_min == 0) {
				status = Intersection.COINCIDENT;
			} else if (c_dist>r_max) {
				status = Intersection.OUTSIDE;
			} else if (c_dist<r_min) {
				status = Intersection.INSIDE;
			} else {
				status = Intersection.INTERSECTION;
				var a:Number = (c1.r*c1.r-c2.r*c2.r+c_dist*c_dist)/(2*c_dist);
				if ( a > c1.r ) a = c1.r;
				var h:Number = Math.sqrt(c1.r*c1.r-a*a);
				var p:Vector2 = c1.c.getLerp(c2.c, a/c_dist);
				var b:Number = h / c_dist;
				points.push(new Vector2(p.x-b*(c2.c.y-c1.c.y), p.y+b*(c2.c.x-c1.c.x)));
				points.push(new Vector2(p.x+b*(c2.c.y-c1.c.y), p.y-b*(c2.c.x-c1.c.x)));
			}
			return this;
		};
		
		//
		public function circle_line( c:Circle, l:LineSegment ):Intersection
		{
			var a:Number = (l.p2.x-l.p1.x)*(l.p2.x-l.p1.x)+(l.p2.y-l.p1.y)*(l.p2.y-l.p1.y);
			var b:Number = 2*((l.p2.x-l.p1.x)*(l.p1.x-c.c.x)+(l.p2.y-l.p1.y)*(l.p1.y-c.c.y));
			var cc:Number = c.c.x * c.c.x + c.c.y * c.c.y + l.p1.x * l.p1.x + l.p1.y * l.p1.y - 2 *( c.c.x * l.p1.x + c.c.y * l.p1.y ) - c.r * c.r;
			var deter:Number = b * b - 4 * a * cc;
			
			if (deter<0) 
			{
				status = Intersection.OUTSIDE;
			} else if (deter == 0) 
			{
				status = Intersection.TANGENT;
			} else 
			{
				var e:Number = Math.sqrt(deter);
				var u1:Number = (-b+e)/(2*a);
				var u2:Number = (-b-e)/(2*a);
				if ((u1<0 || u1>1) && (u2<0 || u2>1)) 
				{
					if ((u1<0 && u2<0) || (u1>1 && u2>1)) 
					{
						status = Intersection.OUTSIDE;
					} else {
						status = Intersection.INSIDE;
					}
				} else 
				{
					status = Intersection.INTERSECTION;
					if (0<=u1 && u1<=1) 
					{
						appendPoint(l.p1.getLerp(l.p2, u1));
					}
					if (0<=u2 && u2<=1) {
						appendPoint(l.p1.getLerp(l.p2, u2));
					}
				}
			}
			return this;
		};
		
		public function bezier2_bezier3( bz2:Bezier2, bz3:Bezier3):Intersection
		{
			var c10:Vector2 = bz2.p1;
			var c11:Vector2 = bz2.c;
			var c12:Vector2 = bz2.p2;
			
			var c20:Vector2 = bz3.p1;
			var c21:Vector2 = bz3.c1;
			var c22:Vector2 = bz3.c2;
			var c23:Vector2 = bz3.p2;
			
			var c10x2:Number = c10.x*c10.x;
			var c10y2:Number = c10.y*c10.y;
			var c11x2:Number = c11.x*c11.x;
			var c11y2:Number = c11.y*c11.y;
			var c12x2:Number = c12.x*c12.x;
			var c12y2:Number = c12.y*c12.y;
			var c20x2:Number = c20.x*c20.x;
			var c20y2:Number = c20.y*c20.y;
			var c21x2:Number = c21.x*c21.x;
			var c21y2:Number = c21.y*c21.y;
			var c22x2:Number = c22.x*c22.x;
			var c22y2:Number = c22.y*c22.y;
			var c23x2:Number = c23.x*c23.x;
			var c23y2:Number = c23.y*c23.y;
			var poly:Polynomial = new Polynomial(-2*c12.x*c12.y*c23.x*c23.y+c12x2*c23y2+c12y2*c23x2, -2*c12.x*c12.y*c22.x*c23.y-2*c12.x*c12.y*c22.y*c23.x+2*c12y2*c22.x*c23.x+2*c12x2*c22.y*c23.y, -2*c12.x*c21.x*c12.y*c23.y-2*c12.x*c12.y*c21.y*c23.x-2*c12.x*c12.y*c22.x*c22.y+2*c21.x*c12y2*c23.x+c12y2*c22x2+c12x2*(2*c21.y*c23.y+c22y2), 2*c10.x*c12.x*c12.y*c23.y+2*c10.y*c12.x*c12.y*c23.x+c11.x*c11.y*c12.x*c23.y+c11.x*c11.y*c12.y*c23.x-2*c20.x*c12.x*c12.y*c23.y-2*c12.x*c20.y*c12.y*c23.x-2*c12.x*c21.x*c12.y*c22.y-2*c12.x*c12.y*c21.y*c22.x-2*c10.x*c12y2*c23.x-2*c10.y*c12x2*c23.y+2*c20.x*c12y2*c23.x+2*c21.x*c12y2*c22.x-c11y2*c12.x*c23.x-c11x2*c12.y*c23.y+c12x2*(2*c20.y*c23.y+2*c21.y*c22.y), 2*c10.x*c12.x*c12.y*c22.y+2*c10.y*c12.x*c12.y*c22.x+c11.x*c11.y*c12.x*c22.y+c11.x*c11.y*c12.y*c22.x-2*c20.x*c12.x*c12.y*c22.y-2*c12.x*c20.y*c12.y*c22.x-2*c12.x*c21.x*c12.y*c21.y-2*c10.x*c12y2*c22.x-2*c10.y*c12x2*c22.y+2*c20.x*c12y2*c22.x-c11y2*c12.x*c22.x-c11x2*c12.y*c22.y+c21x2*c12y2+c12x2*(2*c20.y*c22.y+c21y2), 2*c10.x*c12.x*c12.y*c21.y+2*c10.y*c12.x*c21.x*c12.y+c11.x*c11.y*c12.x*c21.y+c11.x*c11.y*c21.x*c12.y-2*c20.x*c12.x*c12.y*c21.y-2*c12.x*c20.y*c21.x*c12.y-2*c10.x*c21.x*c12y2-2*c10.y*c12x2*c21.y+2*c20.x*c21.x*c12y2-c11y2*c12.x*c21.x-c11x2*c12.y*c21.y+2*c12x2*c20.y*c21.y, -2*c10.x*c10.y*c12.x*c12.y-c10.x*c11.x*c11.y*c12.y-c10.y*c11.x*c11.y*c12.x+2*c10.x*c12.x*c20.y*c12.y+2*c10.y*c20.x*c12.x*c12.y+c11.x*c20.x*c11.y*c12.y+c11.x*c11.y*c12.x*c20.y-2*c20.x*c12.x*c20.y*c12.y-2*c10.x*c20.x*c12y2+c10.x*c11y2*c12.x+c10.y*c11x2*c12.y-2*c10.y*c12x2*c20.y-c20.x*c11y2*c12.x-c11x2*c20.y*c12.y+c10x2*c12y2+c10y2*c12x2+c20x2*c12y2+c12x2*c20y2);
			var roots:Vector.<Number> = poly.getRootsInInterval(0, 1);
			var TOLERANCE:Number = 1e-4;
			for (var i:Number = 0; i<roots.length; i++) {
				var s:Number = roots[i];
				var xRoots:Vector.<Number> = new Polynomial(c12.x, c11.x, c10.x-c20.x-s*c21.x-s*s*c22.x-s*s*s*c23.x).getRoots();
				var yRoots:Vector.<Number> = new Polynomial(c12.y, c11.y, c10.y-c20.y-s*c21.y-s*s*c22.y-s*s*s*c23.y).getRoots();
				if (xRoots.length>0 && yRoots.length>0) {
					//checkRoots:
					for (var j:Number = 0; j<xRoots.length; j++) {
						var xRoot:Number = xRoots[j];
						if (0<=xRoot && xRoot<=1) {
							for (var k:Number = 0; k<yRoots.length; k++) {
								if (Math.abs(xRoot-yRoots[k])<TOLERANCE) {
									appendPoint(c23.getMultiply(s*s*s).plus(c22.multiply(s*s).plus(c21.multiply(s).plus(c20))));
									break;
									//checkRoots;
								}
							}
						}
					}
				}
			}
			if (points.length>0) {
				status =Intersection.INTERSECTION;
			}
			return this;
		};
		
		
		 
		 public function bezier3_line(b:Bezier3, l:LineSegment):Intersection
		 { 
			 var min:Vector2 = l.p1.getMin(l.p2);
			 var max:Vector2 = l.p1.getMax(l.p2);
			 
			 var dy:Number = l.p1.y-l.p2.y, dx:Number = l.p2.x-l.p1.x;
			 var c3:Number = dy*(-b.p1.x+3*(b.c1.x-b.c2.x)+b.p2.x)+dx*(-b.p1.y+3*(b.c1.y-b.c2.y)+b.p2.y);
			 var c2:Number = dy*3*(b.p1.x-2*b.c1.x+b.c2.x)+dx*3*(b.p1.y-2*b.c1.y+b.c2.y);
			 var c1:Number = dy*3*(b.c1.x-b.p1.x)+dx*3*(b.c1.y-b.p1.y);
			 var c0:Number = dy*b.p1.x+dx*b.p1.y+l.p1.x*l.p2.y-l.p2.x*l.p1.y;
			 
			 var pN:Vector.<Number> = new Vector.<Number>();
				
			 var bb:Number = c2/c3;
			 var c:Number = c1/c3;
			 var d:Number = c0/c3;
			 var p:Number = c-bb*bb/3
			 var p3:Number = p*p*p/27;
			 var q:Number = 2*bb*bb*bb/27-bb*c/3+d
			 var q2:Number = -q/2;
			 var dis:Number = q2*q2+p3;
			 
			 if (dis>0)
			 { 
				 var dd:Number = Math.sqrt(dis);
				 var ud:Number = q2+dd;
				 var u:Number = ud<0 ? -Math.pow(-ud, 1/3) : Math.pow(ud, 1/3);
				 var vd:Number = q2-dd;
				 var v:Number = vd<0 ? -Math.pow(-vd, 1/3) : Math.pow(vd, 1/3);
				 pN.push( (u+v)-bb/3 );
			 }
			 else if (dis == 0)
			 { if (!p && !q) pN[0] = -bb/3;
			 else
			 { 
				 pN.push( Math.pow(-4*q, 1/3)-bb/3 );
				 pN.push( Math.pow(q/2, 1/3)-bb/3);
			 } }
			 else if (dis<0)
			 { 
				 var a:Number = Math.acos(q2/Math.sqrt(-p3))/3;
				 var p2:Number = 2*Math.sqrt(-p/3);
				 pN.push( p2*Math.cos(a)-bb/3);
				 pN.push( p2*Math.cos(a+Math.PI*2/3)-bb/3);
				 pN.push( p2*Math.cos(a-Math.PI*2/3)-bb/3);
			 }
			 
			
			 for each (var t:Number in pN)
			 { 
				 if (t>=0 && t<=1)
				 { 
					 var b4x:Number = b.p1.x+t*(b.c1.x-b.p1.x);
					 var b4y:Number = b.p1.y+t*(b.c1.y-b.p1.y);
				   	 var b5x:Number = b.c1.x+t*(b.c2.x-b.c1.x);
					 var b5y:Number = b.c1.y+t*(b.c2.y-b.c1.y);
				   	 var b6x:Number = b.c2.x+t*(b.p2.x-b.c2.x);
					 var b6y:Number = b.c2.y+t*(b.p2.y-b.c2.y);
				   	 var b7x:Number = b4x+t*(b5x-b4x);
					 var b7y:Number = b4y+t*(b5y-b4y);
					 var b8x:Number = b5x+t*(b6x-b5x);
					 var b8y:Number = b5y+t*(b6y-b5y);
					 var b9:Vector2 = new Vector2(b7x+t*(b8x-b7x), b7y+t*(b8y-b7y));
					 if (b9.x>=min.x && b9.y>=min.y && b9.x<=max.x && b9.y<=max.y) appendPoint(b9);
				 } 
			 }
			 
			 if ( points.length > 0 ) status = INTERSECTION;
			 return this;
		 } 
		 
		 
		 
		
	    
	    public function line_triangle( l:LineSegment, t:Triangle ):Intersection
	    {
	    	var result:Intersection = new Intersection();
	    	var intersection:Intersection;
	    	
	    	for ( var i:int = 0; i < 3; i++ )
	    	{
	    		intersection = l.intersect( t.getSide( i ) );
	    		if ( intersection.status == Intersection.INTERSECTION )
	    		{
	    			result.status = Intersection.INTERSECTION;
	    			result.appendPoint( Vector2( intersection.points[0] ) );
	    		} else if ( result.status == Intersection.NO_INTERSECTION )
	    		{
	    			result.status = intersection.status;
	    		}
	    	}
	    	return result;
	    }
	    
	    public function line_polygon( l:LineSegment, p:Polygon ):Intersection
	    {
	    	var result:Intersection = new Intersection();
	    	var intersection:Intersection;
	    	
	    	for ( var i:int = 0; i < p.pointCount; i++ )
	    	{
	    		intersection = l.intersect( p.getSide( i ) );
	    		if ( intersection.status == Intersection.INTERSECTION )
	    		{
	    			result.status = Intersection.INTERSECTION;
	    			result.appendPoint( Vector2( intersection.points[0] ) );
	    		} else if ( result.status == Intersection.NO_INTERSECTION )
	    		{
	    			result.status = intersection.status;
	    		}
	    	}
	    	return result;
	    }
	    
	    public function line_convexPolygon( l:LineSegment, p:ConvexPolygon ):Intersection
	    {
	    	var result:Intersection = new Intersection();
	    	var intersection:Intersection;
	    	var side:LineSegment;
	    	for ( var i:int = 0; i < p.pointCount; i++ )
	    	{
	    		intersection = l.intersect( side = p.getSide( i ) );
	    		if ( intersection.status == Intersection.INTERSECTION )
	    		{
	    			result.status = Intersection.INTERSECTION;
	    			result.appendPoint( intersection.points[0] );
	    		} else if ( intersection.status == Intersection.COINCIDENT || intersection.status == Intersection.PARALLEL )
	    		{
	    			if ( side.contains(l.p1) ) {
	    				result.appendPoint( l.p1 );
	    				result.status = Intersection.INTERSECTION;
	    			}
	    			if ( side.contains(l.p2) ) {
	    				result.appendPoint( l.p2 );
	    				result.status = Intersection.INTERSECTION;
	    			}
	    			if ( l.contains(side.p1) ){
	    				result.appendPoint( side.p1 );
	    				result.status = Intersection.INTERSECTION;
	    			}
	    			if ( l.contains(side.p2) ) {
	    				result.appendPoint( side.p2 );
	    				result.status = Intersection.INTERSECTION;
	    			}
	    		} else if ( result.status == Intersection.NO_INTERSECTION )
	    		{
	    			result.status = intersection.status;
	    		}
	    	}
	    	return result;
	    }
	    
	    
	    public function convexPolygon_convexPolygon( p1:ConvexPolygon, p2:ConvexPolygon ):Intersection
	    {
	    	var result:Intersection = new Intersection();
	    	var intersection:Intersection;
	    	var side1:LineSegment;
	    	var side2:LineSegment;
	    	
	    	
	    	for ( var i:int = 0; i < p1.pointCount; i++ )
	    	{
	    		side1 = p1.getSide( i );
	    		for ( var j:int = 0; j < p2.pointCount; j++ )
		    	{
		    		side2 = p2.getSide( j );
		    		intersection = side2.intersect( side1 );
		    		if ( intersection.status == Intersection.INTERSECTION )
		    		{
		    			result.status = Intersection.INTERSECTION;
		    			result.appendPoint( Vector2( intersection.points[0] ) );
		    		} else if ( intersection.status == Intersection.COINCIDENT || intersection.status == Intersection.PARALLEL )
		    		{
		    			if ( side1.contains(side2.p1) ) {
		    				result.appendPoint( side2.p1 );
		    				result.status = Intersection.INTERSECTION;
		    			}
		    			if ( side1.contains(side2.p2) ) {
		    				result.appendPoint( side2.p2 );
		    				result.status = Intersection.INTERSECTION;
		    			}
		    			if ( side2.contains(side1.p1) ){
		    				result.appendPoint( side1.p1 );
		    				result.status = Intersection.INTERSECTION;
		    			}
		    			if ( side2.contains(side1.p2) ) {
		    				result.appendPoint( side1.p2 );
		    				result.status = Intersection.INTERSECTION;
		    			}
		    		} else if ( result.status == Intersection.NO_INTERSECTION )
		    		{
		    			result.status = intersection.status;
		    		}
		    		
		    	}
	    	}
	    	return result;
	    }
	    
	    public function Polygon_Polygon( p1:Polygon, p2:Polygon ):Intersection
	    {
	    	var result:Intersection = new Intersection();
	    	var intersection:Intersection;
	    	var side1:LineSegment;
	    	var side2:LineSegment;
	    	
	    	
	    	for ( var i:int = 0; i < p1.pointCount; i++ )
	    	{
	    		side1 = p1.getSide( i );
	    		for ( var j:int = 0; j < p2.pointCount; j++ )
		    	{
		    		side2 = p2.getSide( j );
		    		intersection = side2.intersect( side1 );
		    		if ( intersection.status == Intersection.INTERSECTION )
		    		{
		    			result.status = Intersection.INTERSECTION;
		    			result.appendPoint( Vector2( intersection.points[0] ) );
		    		} else if ( intersection.status == Intersection.COINCIDENT || intersection.status == Intersection.PARALLEL )
		    		{
		    			if ( side1.contains(side2.p1) ) {
		    				result.appendPoint( side2.p1 );
		    				result.status = Intersection.INTERSECTION;
		    			}
		    			if ( side1.contains(side2.p2) ) {
		    				result.appendPoint( side2.p2 );
		    				result.status = Intersection.INTERSECTION;
		    			}
		    			if ( side2.contains(side1.p1) ){
		    				result.appendPoint( side1.p1 );
		    				result.status = Intersection.INTERSECTION;
		    			}
		    			if ( side2.contains(side1.p2) ) {
		    				result.appendPoint( side1.p2 );
		    				result.status = Intersection.INTERSECTION;
		    			}
		    		} else if ( result.status == Intersection.NO_INTERSECTION )
		    		{
		    			result.status = intersection.status;
		    		}
		    		
		    	}
	    	}
	    	return result;
	    }
	    
	    public function line_mixedPath( l:LineSegment, p:MixedPath ):Intersection
	    {
	    	var result:Intersection = new Intersection();
	    	var intersection:Intersection;
	    	var side:IIntersectable;
	    	for ( var i:int = 0; i < p.segmentCount; i++ )
	    	{
	    		intersection = l.intersect( side = p.getSegment( i ) );
	    		if ( intersection.status == Intersection.INTERSECTION )
	    		{
	    			result.status = Intersection.INTERSECTION;
	    			result.appendPoint( Vector2( intersection.points[0] ) );
	    		} else if ( result.status == Intersection.NO_INTERSECTION )
	    		{
	    			result.status = intersection.status;
	    		}
	    	}
	    	return result;
	    }
	
		//
		private function bezout(e1:Vector.<Number>, e2:Vector.<Number>):Polynomial
		{
			var AB:Number = e1[0]*e2[1]-e2[0]*e1[1];
			var AC:Number = e1[0]*e2[2]-e2[0]*e1[2];
			var AD:Number = e1[0]*e2[3]-e2[0]*e1[3];
			var AE:Number = e1[0]*e2[4]-e2[0]*e1[4];
			var AF:Number = e1[0]*e2[5]-e2[0]*e1[5];
			var BC:Number = e1[1]*e2[2]-e2[1]*e1[2];
			var BE:Number = e1[1]*e2[4]-e2[1]*e1[4];
			var BF:Number = e1[1]*e2[5]-e2[1]*e1[5];
			var CD:Number = e1[2]*e2[3]-e2[2]*e1[3];
			var DE:Number = e1[3]*e2[4]-e2[3]*e1[4];
			var DF:Number = e1[3]*e2[5]-e2[3]*e1[5];
			var BFpDE:Number = BF+DE;
			var BEmCD:Number = BE-CD;
			return new Polynomial(AB*BC-AC*AC, AB*BEmCD+AD*BC-2*AC*AE, AB*BFpDE+AD*BEmCD-AE*AE-2*AC*AF, AB*DF+AD*BFpDE-2*AE*AF, AD*DF-AF*AF);
		};
	
	}
}