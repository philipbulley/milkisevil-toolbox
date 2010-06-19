package com.milkisevil.utils 
{
	import com.milkisevil.events.StatusEventEnhanced;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class FPSManager extends Sprite 
	{
		public static const NAME:String = 					NAME + 'FPSManager';		public static const STATUS_EVENT:String = 			NAME + '.STATUS_EVENT';		public static const AVERAGE_FPS:String = 			NAME + '.AVERAGE_FPS';
		
		private var fpsCount:int;
		private var timerPrev:int;
		private var sampleSecs:int;
		private var sampleData:Array;
		
		
		public function FPSManager()
		{
			
		}
		
		/**
		 * Calculates the average Frames Per Second based throught the time specified by sampleSecs
		 * @param sampleSecs		The number of seconds from when this method is called to base the average on
		 */
		public function calcAverageFPS( sampleSecs:int = 5 ):void
		{
			trace('exec FPSManager.calcAverageFPS: ' + sampleSecs );
			
			if(!stage) throw new Error( 'FPSManager needs to be added to the display list before calcAverageFPS can be executed' );
			
			this.sampleSecs = sampleSecs;
			sampleData = [];
			timerPrev = 0;
			
			addEventListener( Event.ENTER_FRAME, calcFPS );
		}
		
		private function calcFPS( event:Event ):void
		{
			var timer:int = getTimer();
	                   
	        if( timer - 1000 > timerPrev )
	        {
				if(timerPrev > 0)
				{
					// executes every second				
					
					trace(' - FPSManager.calcFPS: ' + fpsCount + ', timerPrev: '+timerPrev);
					sampleData.push( fpsCount );
					
					if(sampleData.length == sampleSecs)
					{
						var averageFPS:int;
						for each(var i:int in sampleData) averageFPS += i;
						averageFPS = averageFPS / sampleData.length;
						
						dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, AVERAGE_FPS, averageFPS ) );
						removeEventListener( Event.ENTER_FRAME, calcFPS );
					}
					
					fpsCount = 0;
				}
				timerPrev = timer;
	        }
	        
	        // executes every frame
	        fpsCount++;
		}
		
	}
	
	
}
