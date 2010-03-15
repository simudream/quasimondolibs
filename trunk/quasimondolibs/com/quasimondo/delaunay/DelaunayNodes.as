package com.quasimondo.delaunay
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	public class DelaunayNodes {
		
		private var first:DelaunayNode;
		public var size:int = 0;
		
		private static var depot:Array = [];
		
		private var dismin:Number=0.0;
		private var s:Number;
		private var nd:DelaunayNode;
		private var tnd:DelaunayNode;
		private var n:DelaunayNode = first;
		
		public static function getNode( x:Number, y:Number, data:DelaunayNodeProperties = null ):DelaunayNode
		{
			var node:DelaunayNode;
			if ( depot.length>0){
				node = depot.pop();
				node.x = x;
				node.y = y;
				node.data = data;
			} else {
				node = new DelaunayNode( x,y,data );
			}
			if ( data == null )
			{
				data = new DelaunayNodeProperties();
			}
			data.node = node;
			return node;
		}
		
		public static function deleteNode( node:DelaunayNode ):void
		{
			node.next = null;
			depot.push(node);
		}
		
		public function DelaunayNodes() {
		}

		public function addElement( e:DelaunayNode ):void
		{
			e.next = first;
			first = e;
			size++;
		}
	
		public function elementAt( index:int ):DelaunayNode
		{
			nd = first;
			while ( index-- > 0 && nd)
			{ 
				nd = nd.next 
			}
			return nd;
		}
		
		public function removeFirstElement():DelaunayNode
		{
			if (first!=null)
			{
				size--;
				nd = first;
				first = first.next;
				nd.next = null;
			}
			return nd;
		}
		
		public function removeElement( e:DelaunayNode ):void
		{
			if ( first === e )
			{
				size--;
				tnd = first;
				first = first.next;
				tnd.next = null;
				return;
			}
			nd = first;
			while ( nd!=null )
			{
				if ( nd.next === e )
				{
					size--;
					tnd = nd.next
					nd.next = nd.next.next;
					tnd.next = null;
					return;
				}
				nd = nd.next;
			}
		}
		
		public function apply( f:Function ):void
		{
			nd = first;
			while ( nd!=null )
			{
				f(nd);
				nd = nd.next;
			}
		}
		
		public function deleteElement( e:DelaunayNode ):void
		{
			if ( first === e )
			{
				size--;
				nd = first;
				first = first.next;
				deleteNode(nd);
				return;
			}
			nd = first;
			while ( nd!=null )
			{
				if ( nd.next === e )
				{
					size--;
					tnd = nd.next
					nd.next = nd.next.next;
					deleteNode(tnd);
					return;
				}
				nd = nd.next;
			}
		}
		
		public function removeAllElements():void
		{
			while ( first != null )
		 	{
		 		deleteNode(removeFirstElement());
		 	}
		}
		/*
		public function update( dn:Delaunay ):void
	  	{
	  		nd = first;
	  		while ( nd!=null )
			{
				dn.removeNode(nd);
				dn.insertNode(nd);
				nd = nd.next;
			}
	  	
	  }
		*/
		public function nearest( x:Number, y:Number):DelaunayNode
	  	{
			if ( first == null ) return null;
		    // locate a node nearest to (px,py)
		  	nd = n = first;
		    dismin = n.squaredDistance(x,y);
		    n = n.next;
			while (n)
			{
				s = n.squaredDistance(x,y);
				if( s < dismin ) 
		    	{ 
		    		dismin = s;
		    		nd = n;
		    	}
				n = n.next;
			}
			return nd;
	  }
	  
	  public function drawPoints( g:Graphics, fixedToo:Boolean, colorMap:BitmapData = null ):void
	  {
	  		nd = first;
			while ( nd!=null )
			{
				nd.draw(g,fixedToo, colorMap);
				nd = nd.next;
			}
	  	
	  }
	
	  public function updateSprites():void
	  {
	  		nd = first;
	  		while ( nd!=null )
			{
				nd.data.updateView();
				nd = nd.next;
			}
	  	
	  }
	  
	  public function updateData( mode:String ):void
	  {
	  		nd = first;
	  		while ( nd!=null )
			{
				if ( nd.data ) nd.data.update( mode );
				nd = nd.next;
			}
	  	
	  }
	  
	 
	  
	}
			
}