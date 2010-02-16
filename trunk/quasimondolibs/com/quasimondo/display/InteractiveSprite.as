package com.quasimondo.display
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	public class InteractiveSprite extends Sprite
	{
		
		protected var shiftIsDown:Boolean = false;
		protected var ctrlIsDown:Boolean = false;
		protected const g:Graphics = graphics;
		
		public function InteractiveSprite()
		{
			super();
			addEventListener( Event.ADDED_TO_STAGE, setup );
		}
		
		protected function setup( event:Event):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, setup );
			stage.scaleMode = "noScale";	
			stage.align = "TL";	
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, _onKeyDown );
			stage.addEventListener( KeyboardEvent.KEY_UP, _onKeyUp );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			init();
		}
		
		public function init():void
		{
		}
		
		public function onEnterFrame( event:Event ):void
		{
			
		}
		
		private function _onKeyDown( event:KeyboardEvent ):void
		{
			if ( event.keyCode == Keyboard.SHIFT ) shiftIsDown = true;
			if ( event.keyCode == Keyboard.CONTROL ) ctrlIsDown = true;
			onKeyDown( event );
		}
		
		public function onKeyDown( event:KeyboardEvent ):void
		{
		}
		
		private function _onKeyUp( event:KeyboardEvent ):void
		{
			if ( event.keyCode == Keyboard.SHIFT ) shiftIsDown = false;
			if ( event.keyCode == Keyboard.CONTROL ) ctrlIsDown = false;
			onKeyUp( event );
		}
		
		public function onKeyUp( event:KeyboardEvent ):void
		{
			
		}
		
		public function onMouseDown( event:MouseEvent ):void
		{
			
		}
		
		public function onMouseUp( event:MouseEvent ):void
		{
			
		}
		
		public function onMouseMove( event:MouseEvent ):void
		{
			
		}
	}
}