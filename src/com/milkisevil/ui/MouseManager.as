package com.milkisevil.ui 
{
	import com.milkisevil.assets.mousemanager.HandCursorClosedAsset;
	import com.milkisevil.assets.mousemanager.HandCursorOpenAsset;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class MouseManager extends Sprite
	{
		
		public static const HAND_OPEN:String = 'MouseManager.HAND_OPEN';
		public static const HAND_CLOSED:String = 'MouseManager.HAND_CLOSED';
		public static const SYSTEM:String = 'MouseManager.SYSTEM';
		
		private static var instance:MouseManager;
		private var handCursorOpen:MovieClip;
		private var handCursorClosed:MovieClip;
		public var nowShowing:String;
		public var nowShowingBeforeHide:String;
		private var hideMouseTimer:Timer;
		private var isMouseAutoHide:Boolean;
		public var allowMouseHide:Boolean = false;
		
		
		
		public function MouseManager(blocker:SingletonBlocker) 
		{
			this.handCursorOpen = new HandCursorOpenAsset();
			this.handCursorClosed = new HandCursorClosedAsset();
			
			
			this.mouseEnabled = false;
			this.mouseChildren = false;
			
			
			this.hideMouseTimer = new Timer( 5 * 1000, 1 );
			this.hideMouseTimer.addEventListener( TimerEvent.TIMER_COMPLETE, this.hide );
			
			this.addEventListener( Event.ADDED_TO_STAGE, this.addedToStage );
			this.addEventListener( Event.REMOVED_FROM_STAGE, this.removedFromStage );
		}
		
		public static function getInstance():MouseManager
		{
			if (!MouseManager.instance)
			{
				MouseManager.instance = new MouseManager( new SingletonBlocker() );
			}
			return MouseManager.instance;
		}
		
		private function addedToStage( event:Event ):void
		{
			this.stage.addEventListener( Event.MOUSE_LEAVE, this.mouseLeave );
			this.stage.addEventListener( MouseEvent.MOUSE_MOVE, this.mouseMove );
			this.updatePosition();
		}
		
		private function removedFromStage( event:Event ):void
		{
			this.stage.removeEventListener( MouseEvent.MOUSE_MOVE, this.mouseMove );
		}
		
		/**
		 * Changes the mouse cursor to an open hand. Good for denoting a draggable DisplayObject.
		 */
		public function showHandOpen():void
		{
			//trace('exec MouseManager.showHandOpen');
			
			this.hideMouseTimer.reset();
			this.hide();
			if( !this.contains( this.handCursorOpen ) ) this.addChild( this.handCursorOpen );
			this.nowShowing = MouseManager.HAND_OPEN;
		}
		
		/**
		 * Changes the mouse cursor to a closed hand. Good for denoting that a DisplayObject is currently being dragged.
		 */
		public function showHandClosed():void
		{
			//trace('exec MouseManager.showHandClosed');
			
			this.hideMouseTimer.reset();
			this.hide();
			if( !this.contains( this.handCursorClosed ) ) this.addChild( this.handCursorClosed );	
			this.nowShowing = MouseManager.HAND_CLOSED;
		}
		
		
		/**
		 * Reverts back to the standard system mouse pointer, whatever state it may be in.
		 */
		public function showSystem():void
		{
			//trace('exec MouseManager.showSystem');
			
			this.hideMouseTimer.reset();
			this.hide();
			Mouse.show();		
			this.nowShowing = MouseManager.SYSTEM;
		}
		
		

		/**
		 * Hides the mouse cursor, whichever is showing, as long as the this.allowMouseHide
		 * is set to true
		 */
		public function hide():void
		{
			//trace('exec MouseManager.hide: allowMouseHide: '+Registry.getInstance().get('allowMouseHide'));
			
			//if ( this.allowMouseHide ) 
			//{
				this.hideMouseTimer.reset();	// only clear if we're allowing the mouse to hide, otherwise keep interval ticking away
				this.nowShowingBeforeHide = this.nowShowing;
				this.nowShowing = null;		// none of the if statements below will match, all will be hidden
			//}
			
			if(this.nowShowing != MouseManager.SYSTEM) 			Mouse.hide();
			if(this.nowShowing != MouseManager.HAND_CLOSED) 	this.hideHandClosed();
			if(this.nowShowing != MouseManager.HAND_OPEN) 		this.hideHandOpen();		
		}
		
		
		/**
		 * If the mouse cursor is currently hidden, call this method to show 
		 * whichever mouse cursor was showing before the last hide
		 */
		public function show():void
		{
			//trace('exec MouseManager.show');
			
			this.resetMouseAutoHide();
			
			if (!this.nowShowing)
			{			
				switch(this.nowShowingBeforeHide)
				{
					case MouseManager.SYSTEM:
						this.showSystem();
					break;
					
					case MouseManager.HAND_CLOSED:
						this.showHandClosed();
					break;
					
					case MouseManager.HAND_OPEN:
						this.showHandOpen();
					break;
					
					default:
						this.showSystem();
					break;
				}
			}
		}
		
		private function hideHandOpen():void
		{
			if ( this.contains(  this.handCursorOpen ) ) this.removeChild( this.handCursorOpen );
		}
		
		private function hideHandClosed():void
		{
			if ( this.contains(  this.handCursorClosed ) ) this.removeChild( this.handCursorClosed );
		}
		
		private function hidePointer():void
		{
			Mouse.hide();
		}
		
		/**
		 * Hides the mouse cursor after a specified number of seconds
		 * @param	seconds
		 */
		private function hideAfterSecs():void
		{
			//trace('exec MouseManager.hideAfterSecs: ' + seconds);
			
			this.hideMouseTimer.start();
		}
		
		
		
		public function enterFrame( event:Event ):void
		{
			// NOTE: think original reason for this in as2 was bacause system mouse would sometimes show, hope this wont happen in as3 and can remove this method
			
			//trace('exec MouseManager.loop: this.nowShowing: '+this.nowShowing);
			//if (this.nowShowing != MouseManager.SYSTEM) Mouse.hide();
		}
		
		public function mouseLeave( event:Event ):void
		{
			this.hide();
		}
		
		public function mouseMove( event:MouseEvent ):void
		{
			this.show();
			
			this.updatePosition();
			event.updateAfterEvent();
		}
		
		private function updatePosition():void
		{
			this.handCursorOpen.x = this.handCursorClosed.x = this.mouseX - 8;
			this.handCursorOpen.y = this.handCursorClosed.y = this.mouseY - 6;
		}
		
		/**
		 * After calling this method, the mouse will be hidden after 5 seconds of no movement
		 */
		public function startMouseAutoHide():void
		{
			//trace('exec MouseManager.startMouseAutoHide');
			this.hideAfterSecs();
			this.isMouseAutoHide = true;
		}
		
		private function resetMouseAutoHide():void
		{
			//trace('exec MouseManager.resetMouseAutoHide');
			this.hideMouseTimer.reset();
			if(this.isMouseAutoHide) this.hideAfterSecs();
		}
		
		public function stopMouseAutoHide():void
		{
			//trace('exec MouseManager.stopMouseAutoHide');
			this.hideMouseTimer.reset();
			this.isMouseAutoHide = false;
		}
		
		
		
		
	}
	
}


internal class SingletonBlocker
{
	
}