package com.signalsondisplay.structs.graphs
{
	
	/**
	 * GraphEdge class
	 * version: 0.1
	 */
	
	public class GraphEdge
	{
	
		private var _cost:int;
		private var _dest:Vertex;
		
		public function GraphEdge( dest:Vertex, cost:int )
		{
			_dest = dest;
			_cost = cost;
		}
		
		public function get dest():Vertex
		{
			return _dest;
		}
		
		public function get cost():int
		{
			return _cost;
		}
		
		public function set cost( cost:int ):void
		{
			_cost = cost;
		}

	}
	
}