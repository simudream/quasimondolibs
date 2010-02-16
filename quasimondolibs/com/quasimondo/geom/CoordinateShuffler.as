/**
* CoordinateShuffler by Mario Klingemann. Dec 14, 2008
* Visit www.quasimondo.com for documentation, updates and more free code.
*
*
* Copyright (c) 2008 Mario Klingemann
* 
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
**/

package com.quasimondo.geom
{
	import flash.geom.Point;

	public class CoordinateShuffler
	{
		protected var __width:uint;
		protected var __height:uint;
		protected var __seed:uint;
		
		protected var __hLookup:Vector.<uint>;
		protected var __vLookup:Vector.<uint>;
		
		protected var __seed0:uint;
		protected var __seed1:uint;
		protected var __seed2:uint;
		
		protected var __shuffleDepth:uint;
		protected var __lookupTableSize:uint;
		protected var __maximumIndex:uint;
		protected var __currentIndex:uint;
		
		public function CoordinateShuffler( width:uint, height:uint, seed:uint = 0xBADA55, shuffleDepth:uint = 3, lookupTableSize:uint = 256 )
		{
			__width = width;
			__height = height;
			__maximumIndex = width * height;
			__currentIndex = 0;
			__shuffleDepth = shuffleDepth;
			__lookupTableSize = lookupTableSize;
			this.seed = seed;
		}
		
		/**
		* Returns a unique coordinate within the given width and height
		* Valid values for index go from 0 to width * height, 
		* bigger values will be wrapped around  
		**/
		public function getCoordinate( index:uint ):Point
		{
			index %= maximumIndex;
			var x:uint = index % __width;
			var y:uint = index / __width;
			var i:int;
			for ( i = 0; i < __shuffleDepth; i++ )
			{
				y = ( y + __hLookup[ uint((i * __width  + x) % __lookupTableSize)] ) % __height;
				x = ( x + __vLookup[ uint((i * __height + y) % __lookupTableSize)] ) % __width;
			}
			__currentIndex = index+1;
			return new Point( x,y );
		}
		
		/**
		* Returns a unique coordinate within the given width and height
		* and increments the internal index
		**/
		public function getNextCoordinate( ):Point
		{
			__currentIndex %= maximumIndex;
			return getCoordinate( __currentIndex++ );
		}
		
		
		/**
		* Returns a list of unique coordinate within the given width and height
		* The maximum amount of returned coordinates is width * height which constitutes all pixels, 
		**/
		public function getCoordinates( count:uint, index:uint = 0 ):Vector.<Point>
		{
			var list:Vector.<Point> = new Vector.<Point>();
			var x:uint, y:uint, xx:uint, yy:uint, i:int;
			
			__currentIndex = index;
			
			if ( count < 1 ) return list;
			
			var minx:uint = index % __width;
			var miny:uint = index / __width;
			
			for ( yy = miny; yy < __height; yy++ )
			{
				for ( xx = ( yy == miny ? minx :0 ); xx < __width; xx++ )
				{
					x = xx;
					y = yy;
					for ( i = 0; i < __shuffleDepth; i++ )
					{
						y = ( y + __hLookup[ uint((i * __width  + x) % __lookupTableSize)] ) % __height;
						x = ( x + __vLookup[ uint((i * __height + y) % __lookupTableSize)] ) % __width;
					}
					
					list.push( new Point( x,y ) );
					__currentIndex = ( __currentIndex + 1 ) % __maximumIndex;
					if ( count-- == 0 ) return list;
				}
			}
			return list;
		}
		
		/**
		* Controls how often the coordinates get shuffled around
		* A higher should create a more random looking pattern
		* minimum value is 1 
		**/
		public function set shuffleDepth( value:uint ):void
		{
			__shuffleDepth = Math.max( 1, value );
			seed = __seed;
		}
		
		public function get shuffleDepth():uint
		{
			return __shuffleDepth;
		}
		
		
		/**
		* Sets the size of the internal coordinate shuffle tables
		* Smaller values create a more geometric looking pattern
		* Bigger values need a bit longer for the initial setup of the table 
		* minimum value is 1 
		**/
		public function set lookupTableSize ( value:uint ):void
		{
			__lookupTableSize = Math.max( 1, value );
			seed = __seed;
		}
		
		public function get lookupTableSize():uint
		{
			return __lookupTableSize;
		}
		
		public function get maximumIndex():uint
		{
			return __maximumIndex;
		}	
	
		public function set width ( value:uint ):void
		{
			__width = width;
			seed = __seed;
		}
		
		public function get width():uint
		{
			return __width;
		}
		
		public function set height( value:uint ):void
		{
			__height = height;
			seed = __seed;
		}
		
		public function get height():uint
		{
			return __height;
		}
		
		/**
		* Sets the next point index
		* used in conjuntion with getNextCoordinate
		**/
		public function set index( value:uint ):void
		{
			__currentIndex = value % maximumIndex;
		}
		
		
		/**
		* Sets the random seed 
		* different seeds will return the coordinates in different order 
		**/
		public function set seed( value:uint ):void
		{
			__seed = value;
			
			__seed0 = (69069*__seed) & 0xffffffff;
			if (__seed0 < 2) {
	            __seed0 += 2;
	        }
	
	        __seed1 = (69069* __seed0) & 0xffffffff;;
	        if (__seed1 < 8) {
	            __seed1 += 8;
	        }
	
	        __seed2 = ( 69069 * __seed1) & 0xffffffff;;
	        if (__seed2 < 16) {
	            __seed2 += 16;
	        }
	        
	        update();
		}
		
		private function update():void
		{
			var i:uint;
			__hLookup = new Vector.<uint>(__lookupTableSize);
			for ( i = __lookupTableSize; --i > -1; )
			{
				__hLookup[i] = getNextInt() % __height;
			}
			__vLookup = new Vector.<uint>(__lookupTableSize);;
			for ( i = __lookupTableSize; --i > -1; )
			{
				__vLookup[i] = getNextInt() % __width;
			}
		}
		
		private function getNextInt(): uint
		{
			__seed0 = ((( __seed0 & 4294967294) << 12 )& 0xffffffff)^((((__seed0<<13)&0xffffffff)^__seed0) >>> 19 );
       		__seed1 = ((( __seed1 & 4294967288) << 4) & 0xffffffff)^((((__seed1<<2)&0xffffffff)^__seed1)>>>25)
        	__seed2 =  ((( __seed2 & 4294967280) << 17) & 0xffffffff)^((((__seed2<<3)&0xffffffff)^__seed2)>>>11)
        	return __seed0 ^ __seed1 ^ __seed2;
		}

	}
}