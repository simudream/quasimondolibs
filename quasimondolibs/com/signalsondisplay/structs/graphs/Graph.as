package com.signalsondisplay.structs.graphs
{
	
	/**
	 * Graph class
	 * version: 0.1
	 * to-do:
	 * 	- add removeVertex()
	 * 	- add removeEdge()
	 * 	- implement graph traversal algorithms
	 */
	
	import com.signalsondisplay.structs.linkedlists.LinkedList;
	
	public class Graph
	{
	
		private var _vertices:LinkedList;
		private var _vertexCount:uint;
		
		public function Graph()
		{
			_vertices = new LinkedList();
			_vertexCount = 0;
		}
		
		public function addVertex( vertex:Vertex ):void  
		{
			_vertices.append( vertex, vertex.name );
			_vertexCount++;
		}
		
		public function removeVertex( vertex:Vertex ):void  
		{
			_vertexCount -= _vertices.removeNode( vertex );
		}
		
		public function addEdge( u:Vertex, v:Vertex, weight:int = 1 ):Boolean
		{
			//trace( "adding edge: ", u.name, "-", v.name, "::", weight );
			if ( u && v )
			{
				if ( u == v ) return false;
				u.addEdge( v, weight );
				v.addEdge( u, weight );
				return true;
			}
			return false;
		}
		
		public function removeEdge( u:Vertex, v:Vertex ):void
		{
			u.removeEdge( v );
			v.removeEdge( u );
		}
		
		
		public function get vertices():LinkedList
		{
			return _vertices;
		}
		
		public function get size():uint
		{
			return _vertexCount;
		}
		
		public function isEmpty():Boolean
		{
			return _vertexCount == 0;
		}
		
	}
	
}