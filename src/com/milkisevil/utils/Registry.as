/**
* ...
* @author Default
* @version 0.1
*/


package com.milkisevil.utils
{
	public class Registry
	{
		public static var instance:Registry;
		private var data:Object;
		
		public function Registry(blocker:SingletonBlocker)
		{
			this.data = new Object();
		}
		
		public static function getInstance():Registry
		{
			if(!instance) instance = new Registry(new SingletonBlocker());
			return instance;
		}
		
		public function set(key:String, value:*):void
		{
			this.data[key] = value;
		}
		
		public function get(key:String):*
		{
			return this.data[key];
		}
		
	}
	
}

internal class SingletonBlocker
{
	
}