package com.signalsondisplay.structs.linkedlists
{
	
	/**
	 * Linked list node
	 * version: 0.2
	 */
	
	public class ListNode
	{
		
		private var _data:*;
		public var name:String = "";
		public var next:ListNode = null;
		
		public function ListNode( data:*, name:String = "" ) 
		{
			_data = data;
			next = null;
			if ( name )
				this.name = name;
		}
		
		public function get data():*
		{
			return _data;
		}
		
		public function set data( data:* ):void
		{
			_data = data;
		}
		
		public function toString():String
		{
			return "[ListNode name:" + name + "]";
		}
		
	}
	
}