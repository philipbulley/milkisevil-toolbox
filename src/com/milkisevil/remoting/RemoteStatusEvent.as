package com.milkisevil.remoting 
{
	import flash.events.StatusEvent;
	
	/**
	 * ...
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class RemoteStatusEvent extends StatusEvent
	{
		
		public static const STATUS_EVENT:String = 'RemoteStatusEvent.STATUS_EVENT';
		public static const COMPLETE:String = 'RemoteStatusEvent.COMPLETE';
		public static const ERROR:String = 'RemoteStatusEvent.ERROR';
		
		public var result:Object;		
		
		public function RemoteStatusEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, code:String = null, level:String = null, result:Object = null) 
		{
			super(type, bubbles, cancelable, code, level);
			
			this.result = result;
		}
		
	}
	
}