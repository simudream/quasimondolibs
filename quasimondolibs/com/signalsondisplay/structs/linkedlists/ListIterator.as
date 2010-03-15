package com.signalsondisplay.structs.linkedlists
{
	
	/**
	 * LinkedList iterator
	 * implements IIterator interface
	 * version: 0.1
	 */
	
	import com.signalsondisplay.structs.iterators.IIterator;
	
	public class ListIterator implements IIterator
	{
		
		private var _head:ListNode;
		private var _current:ListNode;
		
		public function ListIterator( head:ListNode )
		{
			_head = _current = head;
		}
		
		public function hasNext():Boolean
		{
			return _current.next != null;
		}
	
		public function next():*
		{
			_current = _current.next;
			return _current;
		}
		
		public function current():*
		{
			return _current;
		}
		
		public function reset():void
		{
			_current = _head;
		}
		
	}
	
}