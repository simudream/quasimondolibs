package com.quasimondo.delaunay
{
	import com.quasimondo.geom.Triangle;
	
	import flash.display.Graphics;
	
	
	public class DelaunayTriangles {
		
		private var first:DelaunayTriangle;
		public var size:int = 0;
		private var ta:DelaunayTriangle;
		private var tat:DelaunayTriangle;
		
		private static var depot:Array = [];
		
		public static function getTriangle( e1:DelaunayEdge, e2:DelaunayEdge, e3:DelaunayEdge, edges:DelaunayEdges = null ):DelaunayTriangle
		{
			var tri:DelaunayTriangle;
			if ( depot.length>0){
				tri = DelaunayTriangle(depot.pop());
				tri.update( e1, e2, e3, edges );
			} else {
				tri = new DelaunayTriangle( e1, e2, e3, edges );
			}
			return tri;
		}
		
		public static function deleteTriangle( tri:DelaunayTriangle ):void
		{
			tri.next = null;
			depot.push(tri);
		}
		
		public function DelaunayTriangles()
		{
		}

		public function addElement( e:DelaunayTriangle ):void
		{
			e.next = first;
			first = e;
			size++;
		}
	
		public function elementAt( index:int ):DelaunayTriangle
		{
			ta = first;
			while ( index-- > 0 && ta )
			{ 
				ta = ta.next 
			}
			return ta;
		}
		
		public function removeFirstElement():DelaunayTriangle
		{
			if (first!=null)
			{
				size--;
				ta = first;
				first = first.next;
				ta.next = null;
			}
			return ta;
		}
		
		public function deleteElement( e:DelaunayTriangle ):void
		{
			if ( first == e )
			{
				size--;
				ta = first;
				first = first.next;
				deleteTriangle(ta);
				return;
			}
			ta = first;
			while ( ta != null )
			{
				if ( ta.next == e )
				{
					size--;
					tat = ta.next
					ta.next = ta.next.next;
					deleteTriangle(tat);
					return;
				}
				ta = ta.next;
			}
		}
		
		public function removeElement( e:DelaunayTriangle ):void
		{
			
			if ( first == e )
			{
				size--;
				first = first.next;
				return;
			}
			ta = first;
			while ( ta!=null )
			{
				if ( ta.next == e )
				{
					size--;
					ta.next = ta.next.next;
					return;
				}
				ta = ta.next;
			}
		}
		
		public function removeAllElements():void
		{
			while ( first != null )
		 	{
		 		deleteTriangle(removeFirstElement());
		 	}
		}
		
		public function drawVertex( g:Graphics ):void
	  	{
	  		ta = first;
			while ( ta!=null )
			{
				ta.drawVertex( g );
				ta = ta.next;
			}
	  	}
		
		public function drawCircles( g:Graphics ):void
	  	{
	  		ta = first;
			while ( ta!=null )
			{
				ta.drawCircle( g );
				ta = ta.next;
			}
	  	}
	  	
	  	public function getVertices():Vector.<DelaunayTriangle>
	  	{
	  		var result:Vector.<DelaunayTriangle> = new Vector.<DelaunayTriangle>();
	  		ta = first;
			while ( ta!=null )
			{
				result.push( ta );
				ta = ta.next;
			}
			return result;
	  	}
	  	
	  	public function getTriangles():Vector.<Triangle>
		{
			var result:Vector.<Triangle> = new Vector.<Triangle>();
	  		ta = first;
			while ( ta!=null )
			{
				result.push( ta.toTriangle() );
				ta = ta.next;
			}
			return result;
		 }
	  	
	  	public function apply( f:Function ):void
		{
			ta = first;
			while ( ta!=null )
			{
				f(ta);
				ta = ta.next;
			}
		}
		
	}		
}