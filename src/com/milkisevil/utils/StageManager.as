package com.milkisevil.utils 
{
	import com.milkisevil.events.StatusEventEnhanced;
	import flash.display.Sprite;

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class StageManager extends Sprite 
	{
		public static const STATUS_EVENT:String = 'StageManager.STATUS_EVENT';		public static const QUALITY_CHANGE:String = 'StageManager.QUALITY_CHANGE';
				public static var instance:StageManager;

		public function StageManager( blocker:SingletonBlocker )
		{
			
		}
		
		public static function getInstance():StageManager
		{
			if(!instance) instance = new StageManager(new SingletonBlocker());
			return instance;
		}
		
		public function get quality():String
		{
			return stage.quality;
		}
		
		public function set quality(quality:String):void
		{
			stage.quality = quality;
			
			dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, QUALITY_CHANGE, quality ) );
		}
	}
}

internal class SingletonBlocker
{
	
}