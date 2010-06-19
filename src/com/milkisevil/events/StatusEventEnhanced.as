package com.milkisevil.events 
{
	import flash.events.StatusEvent;

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class StatusEventEnhanced extends StatusEvent 
	{
		public var data:Object;
		
		public function StatusEventEnhanced(type:String, bubbles:Boolean = false, cancelable:Boolean = false, code:String = "", data:Object = null, level:String = "")
		{
			this.data = data;
			super( type, bubbles, cancelable, code, level );
		}
	}
}
