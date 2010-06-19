

/**
* LoaderEventEnhanced
* @author Philip Bulley <p.bulley@impactproximity.com>
*/
package com.milkisevil.events {
	
	import flash.display.DisplayObject;
	import flash.events.StatusEvent;

	public class LoaderEventEnhanced extends StatusEvent {
		
		
		public var queueId:int;
		public var fileName:String;
		public var fileNum:Number;
		public var fileNumAll:Number;
		public var bytesLoaded:Number;
		public var bytesTotal:Number;
		public var percentage:Number;
		public var percentageAll:Number;
		public var content:DisplayObject;
		public var ioErrorText:String;
		public var ioErrorId:int;
		public var httpStatus:int;
		
		
		public function LoaderEventEnhanced(
												type:String, 
												bubbles:Boolean = false, 
												cancelable:Boolean = false,
												code:String = null,
												queueId:int = 0, 
												fileName:String = '', 
												fileNum:Number = 0, 
												fileNumAll:Number = 0, 
												bytesLoaded:Number = 0, 
												bytesTotal:Number = 0, 
												percentage:Number = 0, 
												percentageAll:Number = 0,
												content:DisplayObject = null,
												ioErrorText:String = null,
												ioErrorId:int = 0,
												httpStatus:int = 0
											) 
		{
			
			super(type, bubbles, cancelable, code);
			
			this.queueId = 			queueId;
			this.fileName = 		fileName;
			this.fileNum = 			fileNum;
			this.fileNumAll = 		fileNumAll;
			this.bytesLoaded = 		bytesLoaded;
			this.bytesTotal = 		bytesTotal;
			this.percentage = 		percentage;
			this.percentageAll = 	percentageAll;
			this.content = 			content;
			this.ioErrorId = 		ioErrorId;
			this.ioErrorText = 		ioErrorText;
			this.httpStatus = 		httpStatus;
			
		}
		
		
		
		
		public static const STATUS_EVENT:String = "LoaderEnhancedStatus";
		
		
		public static const COMPLETE:String = "CompleteEvent";
		
		
		public static const COMPLETE_ALL:String = "CompleteAllEvent";
		
		
		public static const INIT:String = "InitEvent";
		
		
		public static const OPEN:String = "OpenEvent";
		
		
		public static const OPEN_ALL:String = "OpenAllEvent";
		
		
		public static const UNLOAD:String = "UnloadEvent";
		
		
		public static const PROGRESS:String = "Progress";
		
		
		public static const IO_ERROR:String = "IOErrorEvent";
		
		
		public static const HTTP_RESPONSE_STATUS:String = "HTTPResponseStatusEvent";
		
		
		public static const HTTP_STATUS:String = "HTTPStatusEvent";
		
		public static const CANCEL:String = "CancelEvent";
		
	}
	
}
