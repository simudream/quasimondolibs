package com.signalsondisplay.structs.linkedlists
{
	
	/**
	 * LinkedList class
	 * version: 0.1
	 * to-do:
	 * 	continue iterators
	 * 	- + list sorting:
	 * 		- insertion sort
	 */
	
	import com.signalsondisplay.structs.collections.ICollection;
	
	public class LinkedList implements ICollection
	{
		
		private var _size:uint;
		private var _head:ListNode;
		private var _tail:ListNode;
		private var _iterator:ListIterator;
		
		public function LinkedList() 
		{
			_head =_tail = null;
			_size = 0;
		}

		public function push( data:*, name:String = "" ):ListNode
		{
			//trace( "LinkedList::pushing node: ", name );			
			var node:ListNode = new ListNode( data, name );
						
			if ( !_head )
				_head = _tail = node;
			else
			{
				node.next = _head;
				_head = node;
			}
			_size++;
			return node;
		}
		
		public function append( data:*, name:String = "" ):ListNode
		{
			//trace( "LinkedList::appending node: ", name );
			var node:ListNode = new ListNode( data, name );
			var ref:ListNode;
			
			ref = _head;
			if ( !_head ) push( node.data );
			else
			{
				while ( ref.next )
					ref = ref.next;
				ref.next = _tail = node;
			}
			_size++;
			return node;
		}
		
		public function remove( index:uint ):void
		{
			var counter:int = 0;
			var iterator:ListNode = _head;
			
			if ( index == 0 )
				_head = _head.next;
			else
			{
				while ( iterator )
				{
					if ( counter == index - 1 )
						iterator.next = iterator.next.next;
					iterator = iterator.next;
					counter++;
				}
			}
			_size--;
		}
		
		public function removeNode( data:* ):int
		{
			var counter:int = 0;
			var iterator:ListNode = _head;
			
			if ( iterator.data == data )
			{
				_head = _head.next;
				counter++;
			} else
			{
				while ( iterator )
				{
					if ( iterator.next && iterator.next.data == data )
					{
						iterator.next = iterator.next.next;
						counter++;
					}
					iterator = iterator.next;
				}
			}
			_size--;
			return counter;
		}
		
		public function removeHead():ListNode
		{
			_head = _head.next;
			return _head;
		}
		
		public function removeTail():ListNode
		{
			var iterator:ListNode = _head;
			
			while ( iterator )
			{
				if ( iterator.next == _tail )
				{
					_tail = iterator;
					_tail.next = null;
					return _tail;
				}
				iterator = iterator.next;
			}
			return null;
		}
		
		public function getNode( index:uint ):ListNode
		{
			var iterator:ListNode = _head;
			var counter:uint = 0;
			
			while ( iterator )
			{
				if ( index == counter )
					return iterator;
				counter++;
				iterator = iterator.next;	
			}
			return null;
		}

		public function insertNode( index:uint, data:*, name:String = "" ):ListNode
		{
			var node:ListNode = new ListNode( data, name );
			var iterator:ListNode = _head;
			var counter:uint = 0;
			
			if ( !index )
			{
				node.next = _head;
				return _head = node;	
			}
			else
			{
				while ( iterator )
				{
					if ( counter == index - 1 )
					{
						node.next = iterator.next;
						iterator.next = node;
						return node;
					}
					counter++;
					iterator = iterator.next;
				}
			}
			return null;
		}
		
		public function forEach( callback:Function ):void
		{
			var iterator:ListNode = _head;
			
			while ( iterator )
			{
				callback( iterator );
				iterator = iterator.next;
			}
		}
		
		public function isEmpty():Boolean
		{
			return _size == 0;
		}
		
		/**
		 * getters / setters
		 */
		public function get head():ListNode
		{
			return _head;
		}
		public function set head( head:ListNode ):void
		{
			_head = head;
		}
		
		public function get tail():ListNode
		{
			return _tail;
		}
		
		public function get size():uint
		{
			return _size;
		}
		
		public function get iterator():ListIterator
		{
			return new ListIterator( _head );
		}

	}
	
}