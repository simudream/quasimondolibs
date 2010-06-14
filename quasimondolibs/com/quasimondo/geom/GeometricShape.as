package com.quasimondo.geom
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	public class GeometricShape
	{
		public var fillColor:uint;
		
		function GeometricShape()
		{
		}
		
		public function booleanOperation( that:GeometricShape, operation:String ):CompoundShape
		{
			return BooleanShapeOperation.operate( this, that, operation );
		}
		
		public function get type():String
		{
			return "GeometricShape";
		}
		
		/*
		public function offset( offset:Vector2 ):void
		{
			throw new Error("Must override offset!");
		}
		*/
		
		public function drawExtras( g:Graphics, factor:Number = 1 ):void
		{
			throw new Error("Must override drawExtras!");
		}
		
		public function draw( g:Graphics ):void
		{
			throw new Error("Must override draw!");
		}
		
		public function drawTo( g:Graphics ):void
		{
			throw new Error("Must override drawTo!");
		}
		
		public function moveToStart( g:Graphics ):void
		{
			throw new Error("Must override moveToStart!");
		}
		
		public function moveToEnd ( g: Graphics ): void
		{
			throw new Error("Must override moveToEnd!");
		}
		
		public function getPoint( t:Number ):Vector2
		{
			throw new Error("Must override getPoint!");
			return null;
		}
		
		public function getPointAtOffset( offset:Number ):Vector2
		{
			throw new Error("Must override getPointAtOffset!");
			return null;
		}
		
		public function getNormalAtPoint( p:Vector2 ):Vector2
		{
			throw new Error("Must override getNormalAt!");
			return null;
		}
		
		public function translate( offset:Vector2 ):GeometricShape
		{
			throw new Error("Must override translate!");
			return null;
		}
		
		public function rotate( angle:Number, center:Vector2 = null ):GeometricShape
		{
			throw new Error("Must override rotate!");
			return null;
		}
		
		public function getBoundingRect( loose:Boolean = true ):Rectangle
		{
			throw new Error("Must override getBoundingRect!");
			return null;
		}
		
		public function get length():Number
		{
			throw new Error("Must override length");
			return 0
		}
		
		public function isInside( p:Vector2, includeVertices:Boolean = true ):Boolean
		{
			throw new Error("Must override isInside");
			return false;
		}
		
		public function clone( deepClone:Boolean = true ):GeometricShape
		{
			throw new Error("Must override clone()");
			return null;
		}
		
	}
}