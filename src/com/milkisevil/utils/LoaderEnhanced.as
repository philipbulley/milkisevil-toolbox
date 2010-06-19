
package com.milkisevil.utils 
{
	import com.milkisevil.events.LoaderEventEnhanced;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;

	/**
	* LoaderEventEnhanced - A class to manage your load queue
	* 
	* @author Philip Bulley <p.bulley@impactproximity.com>
	* @version 2.2
	* @see com.milkisevil.events.LoaderEventEnhanced LoaderEventEnhanced
	* 
	* @usage		
	 				var loader:LoaderEnhanced = LoaderEnhanced.getInstance();
	 				loader.addToQueue('myfile.jpg');
	 				loader.addToQueue('myfile2.jpg');
	 
	 				
	 				loader.addEventListener( LoaderEventEnhanced.STATUS_EVENT, this.loaderStatus );
	 
	 				private function loaderStatus( event:LoaderEventEnhanced ):void
					{
						switch (event.code) 
						{
							case LoaderEventEnhanced.PROGRESS:
								
							break;
							
							case LoaderEventEnhanced.COMPLETE:
								
							break;
							
							case LoaderEventEnhanced.COMPLETE_ALL:
								
							break;
						}
					}
	 
	 				loader.start();
	* 
	* 
	* History *******
	* 
	* 
	* v2.2
	* Added priortize method, to promote specific files during the loading process
	*
	* v2.1
	* Added cancel functionailty. Now all files can be cancelled, or just the currently
	* loading file. A LoaderEventEnhanced.CANCEL will be dispatched for each file cancelled
	* 
	* v2.0
	* Ported what was MovieClipLoaderEnhanced from AS2 to AS3, becoming LoaderEnhanced.
	* A custom event class called LoaderEventEnhanced has now formalised the event dispatching
	*  
	* v1.2r2
	* Added support for multiple singletons (sounds nuts right!?), this allows two
	* seperate independent load queues which can be accessed from anywhere with
	* static access to this class. 
	* 		*	MovieClipLoaderEnhanced.getInstance() to get the default singleton
	* 		*	MovieClipLoaderEnhanced.getInstance('thumbnails') to get a seperate 
	* 			singleton which for example could be used to constantly background 
	* 			load thumbnail images.
	* 
	* v1.2r1
	* this.start() will not initiate the loading sequence if it is already running
	* 
	* v1.2
	* Added currentFileNum and fileNumAll to the dispatchers
	* Also added onLoadStartAll event
	* The onProgress event now reports the collective percentage of all files loaded (percentageAll)
	* 
	* v1.1r2
	* Moved to utils package
	* 
	* v1.1r1
	* Changed decache variable to be on _level0 instead of _root
	* 
	* v1.1
	* onStatus events now include 'fileName', specifying the filename
	* for which the event applies to.
	* Now carries through a _root.decache variable if set, to prevent
	* server-side caching
	* 
	*/
	public class LoaderEnhanced extends EventDispatcher {
		
		
		private static var instance:Object;
		private var loader:Loader;
		private var loadQueue:Array;
		private var startedAll:Boolean;
		private var isLoading:Boolean;					// Flags whether we're currently in the process of loading, for example subsequent calls to start can be surpressed if true
		
		private var currentFileName:String;
		private var currentFileNum:Number = 0;			// keeps track of which number file we're currently loading (starts at 1)
		private var fileNumAll:Number = 0;				// keeps track of the total number of files there are to be loaded in this queue (not to be confused with getNumItemsInQueue() which decreases as files are loaded)
		private var decache:String;
		private var lastQueueId:int = 0;
		private var currentFileBytesLoaded:Number;
		private var currentFileBytesTotal:Number;
		private var currentFilePercentage:Number;
		private var currentFilePercentageAll:Number;
		
		
		public var _debug:Boolean = false;
		
		
		public function LoaderEnhanced( blocker:SingletonBlocker ) 
		{
			
			this.loadQueue = new Array();
			
			var flashVars:Object = Registry.getInstance().get('FLASH_VARS');
			if(flashVars) this.decache = flashVars.decache;
		}
		
		

		public static function getInstance(name:String = 'default'):LoaderEnhanced
		{
			if(!LoaderEnhanced.instance) LoaderEnhanced.instance = { };
			
			if (!LoaderEnhanced.instance[name]) 
			{
				LoaderEnhanced.instance[name] = new LoaderEnhanced( new SingletonBlocker() );
			}
			
			return LoaderEnhanced.instance[name];			
		}
		
		
		
		
		
		
		// EVENT HANDLER METHODS -------------------------------------------------------------
		
		
		/**
		 * Dispatched when data is received as the download operation progresses.
		 * 
		 * @param	event
		 */
		private function progressEvent(event:ProgressEvent):void
		{
			
			var percentage:Number = (event.bytesLoaded/event.bytesTotal) * 100;
			var percSplit:Number = 100 / this.fileNumAll;
			var percentageAll:Number = (percSplit * (this.currentFileNum-1)) + (percentage / this.fileNumAll);
			
			this.currentFileBytesLoaded = event.bytesLoaded;
			this.currentFileBytesTotal = event.bytesTotal;
			
			this.currentFilePercentage = percentage;
			this.currentFilePercentageAll = percentageAll;
			
			
			this.dispatchEvent( new LoaderEventEnhanced(
				LoaderEventEnhanced.STATUS_EVENT, 
				event.bubbles, 
				event.cancelable,
				LoaderEventEnhanced.PROGRESS,
				this.getCurrentLoadingQueueId(),
				this.currentFileName,
				this.currentFileNum,
				this.fileNumAll,
				this.currentFileBytesLoaded,
				this.currentFileBytesTotal,
				this.currentFilePercentage,
				this.currentFilePercentageAll,
				null,
				null,
				0,
				0				
			) );
			
		}
		
		
		/**
		 * Dispatched when data has loaded successfully.
		 * 
		 * @param	event
		 */
		private function completeEvent(event:Event):void
		{
			
			this.dispatchEvent( new LoaderEventEnhanced(
				LoaderEventEnhanced.STATUS_EVENT, 
				event.bubbles, 
				event.cancelable,
				LoaderEventEnhanced.COMPLETE,
				this.getCurrentLoadingQueueId(),
				this.currentFileName,
				this.currentFileNum,
				this.fileNumAll,
				this.currentFileBytesLoaded,
				this.currentFileBytesTotal,
				this.currentFilePercentage,
				this.currentFilePercentageAll,
				event.target.content,
				null,
				0,
				0				
			) );
			
			
			this.isLoading = false;			// Must be set here so start can continue if need be
			
			
			/*
			if(this.loadQueue.length == 0){
				this.completeAllEvent();
			}else{
				this.loadQueue.shift();
				this.start();
			}
			*/
			
			this.startNext();
			
		}
		
		
		/**
		 * Dispatched when all items in the queue have loaded.
		 * 
		 * @param	event
		 */
		private function completeAllEvent():void
		{
			
			this.dispatchEvent( new LoaderEventEnhanced(
				LoaderEventEnhanced.STATUS_EVENT, 
				false, 
				false,
				LoaderEventEnhanced.COMPLETE_ALL
			) );
			
			this.loadQueue.shift();
			this.resetFileCounters();
			
		}
		
		
		/**
		 * Dispatched when a network request is made over HTTP and Flash Player can detect the HTTP status code.
		 * 
		 * @param	event
		 */
		private function httpStatusEvent(event:HTTPStatusEvent):void
		{
			
			this.dispatchEvent( new LoaderEventEnhanced(
				LoaderEventEnhanced.STATUS_EVENT, 
				event.bubbles, 
				event.cancelable,
				LoaderEventEnhanced.HTTP_STATUS,
				this.getCurrentLoadingQueueId(),
				this.currentFileName,
				this.currentFileNum,
				this.fileNumAll,
				this.currentFileBytesLoaded,
				this.currentFileBytesTotal,
				this.currentFilePercentage,
				this.currentFilePercentageAll,
				null,
				null,
				0,
				event.status				
			) );
			
			
			
		}
		
		
		/**
		 * Dispatched when the properties and methods of a loaded SWF file are accessible.
		 * 
		 * @param	event
		 */
		private function initEvent(event:Event):void
		{
			
			this.dispatchEvent( new LoaderEventEnhanced(
				LoaderEventEnhanced.STATUS_EVENT, 
				event.bubbles, 
				event.cancelable,
				LoaderEventEnhanced.INIT,
				this.getCurrentLoadingQueueId(),
				this.currentFileName,
				this.currentFileNum,
				this.fileNumAll,
				this.currentFileBytesLoaded,
				this.currentFileBytesTotal,
				this.currentFilePercentage,
				this.currentFilePercentageAll,
				event.target.content,
				null,
				0,
				0				
			) );
			
		}
		
		
		/**
		 * Dispatched when an input or output error occurs that causes a load operation to fail.
		 * 
		 * @param	event
		 */
		private function ioErrorEvent(event:IOErrorEvent):void
		{
			if(debug) trace('exec LoaderEnhanced.ioErrorEvent: ' + event.text );
			
			
			this.dispatchEvent( new LoaderEventEnhanced(
				LoaderEventEnhanced.STATUS_EVENT, 
				event.bubbles, 
				event.cancelable,
				LoaderEventEnhanced.IO_ERROR,
				this.getCurrentLoadingQueueId(),
				this.currentFileName,
				this.currentFileNum,
				this.fileNumAll,
				this.currentFileBytesLoaded,
				this.currentFileBytesTotal,
				this.currentFilePercentage,
				this.currentFilePercentageAll,
				null,
				event.text,
				0,		// Compiler issue here, I can't seem to get the id from the event
				0				
			) );
			
			
			this.startNext();
			
		}
		
		
		/**
		 * Dispatched when a load operation starts.
		 * 
		 * @param	event
		 */
		private function openEvent(event:Event):void
		{			
			
			this.dispatchEvent( new LoaderEventEnhanced(
				LoaderEventEnhanced.STATUS_EVENT, 
				event.bubbles, 
				event.cancelable,
				LoaderEventEnhanced.OPEN,
				this.getCurrentLoadingQueueId(),
				this.currentFileName,
				this.currentFileNum,
				this.fileNumAll,
				this.currentFileBytesLoaded,
				this.currentFileBytesTotal,
				this.currentFilePercentage,
				this.currentFilePercentageAll,
				null,
				null,
				0,
				0				
			) );		
			
			
		}
		
		
		/**
		 * Dispatched when the first load operation in the queue starts.
		 * 
		 * @param	event
		 */
		private function openAllEvent():void
		{
			
			this.dispatchEvent( new LoaderEventEnhanced(
				LoaderEventEnhanced.STATUS_EVENT, 
				false, 
				false,
				LoaderEventEnhanced.OPEN_ALL,
				this.getCurrentLoadingQueueId(),
				this.currentFileName,
				this.currentFileNum,
				this.fileNumAll,
				this.currentFileBytesLoaded,
				this.currentFileBytesTotal,
				this.currentFilePercentage,
				this.currentFilePercentageAll,
				null,
				null,
				0,
				0				
			) );
			
		}
			
			
		/**
		 * Dispatched when the loading of an item in the queue has been cancelled.
		 * 
		 * @param	event
		 */
		private function cancelEvent():void
		{
			
			this.dispatchEvent( new LoaderEventEnhanced(
				LoaderEventEnhanced.STATUS_EVENT, 
				false, 
				false,
				LoaderEventEnhanced.CANCEL,
				this.getCurrentLoadingQueueId(),
				this.currentFileName,
				this.currentFileNum,
				this.fileNumAll,
				this.currentFileBytesLoaded,
				this.currentFileBytesTotal,
				this.currentFilePercentage,
				this.currentFilePercentageAll,
				null,
				null,
				0,
				0				
			) );
			
		}
		
		
		/**
		 * Dispatched by a LoaderInfo object whenever a loaded object is removed by using the 
		 * unload() method of the Loader object, or when a second load is performed by the 
		 * same Loader object and the original content is removed prior to the load beginning.
		 * 
		 * @param	event
		 */
		private function unloadEvent(event:Event):void
		{
			
			this.dispatchEvent( new LoaderEventEnhanced(
				LoaderEventEnhanced.STATUS_EVENT, 
				event.bubbles, 
				event.cancelable,
				LoaderEventEnhanced.UNLOAD,
				this.getCurrentLoadingQueueId(),
				this.currentFileName,
				this.currentFileNum,
				this.fileNumAll,
				this.currentFileBytesLoaded,
				this.currentFileBytesTotal,
				this.currentFilePercentage,
				this.currentFilePercentageAll,
				null,
				null,
				0,
				0				
			) );
			
		}
		
		
		
		
		
		
		
		
		// GENERAL METHODS -------------------------------------------------------------
		
		
		
		/**
		* Use this function to add files to the global LoaderEnhanced queue
		* @param	fileName		The path of the file to be loaded
		*/
		public function addToQueue(fileName:String):int
		{
			
			if(debug) trace('exec LoaderEnhanced.addToQueue: '+fileName);
			
				
			this.loadQueue.push(
				{
					id:			this.getNextQueueId(),
					fileName: 	fileName,
					loader:		new Loader()
				}
			);
			this.fileNumAll++;
			
			
			return this.loadQueue[this.loadQueue.length - 1].id;
			
		}
		
		
		
		public function clearQueue():void
		{
			
			if(debug) trace('exec LoaderEnhanced.clearQueue');
			this.loadQueue = null;
			this.loadQueue = new Array();
			this.startedAll = false;
			this.resetFileCounters();
			
		}
		
		
		/**
		 * If an item is currently loading, it will be cancelled. A LoaderEventEnhanced.CANCEL will be 
		 * dispatched with the files progress at the point of cancellation.
		 * 
		 * NOTE: Not yet fully tested
		 */
		public function cancelCurrentLoad():void
		{
			if (this.isLoading)
			{
				this.loader.close();
				
				this.cancelEvent();
				
				this.isLoading = false;
				this.startNext();
			}
		}
		
		
		/**
		 * Cancels all items to be loaded and clears the loadQueue.
		 * If an item is currently loading, it will be cancelled. A LoaderEventEnhanced.CANCEL will be 
		 * dispatched with the files progress at the point of cancellation.
		 * 
		 * NOTE: Not yet fully tested 
		 */
		public function cancelAll():void
		{
			if (this.isLoading)
			{
				this.loader.close();
				this.cancelEvent();
				this.isLoading = false;
				this.removeLoaderEventListeners( this.loadQueue[0].loader );
				this.loadQueue.shift();
			}
			
			if (this.loadQueue.length > 0)
			{
				
				for (var i:Number = 0; i < this.loadQueue.length; i++)
				{
					this.currentFileName = this.loadQueue[i].fileName;
					this.currentFileNum++;
					this.currentFileBytesLoaded = 0;
					this.currentFileBytesTotal = 0;
					this.currentFilePercentage = 0;
					this.cancelEvent();
				}
			}
			
			this.clearQueue();
		}
		
		
		/**
		 * Ensure a specific file name is in a priority position within the load queue.
		 * A priority position is considered as the current file being loaded, or the 
		 * very next file to be loaded.
		 * 
		 * Useful if you need to load a file now that could be in any position within
		 * the load queue.
		 * 
		 * @param fileName		The filename of the file to be prioritized, should match the filename previously supplied to addToQueue()
		 * @return				Boolean value indicating whether the filename requiring priority has successfully been prioritized
		 */
		public function priortize( fileName:String ):Boolean
		{
			var foundIndex:int = Number.NaN;
			
			if(loadQueue.length == 0) return false;
			
			for(var i:int = 0; i<this.loadQueue.length; i++)
			{
				if( this.loadQueue[i].fileName == fileName )
				{
					foundIndex = i;
					break;
				}
			}
			
			if( isNaN(foundIndex) )
			{
				return false;
			}
			else if(foundIndex != 0 && foundIndex != 1)
			{
				var spliced:Object = this.loadQueue.splice(foundIndex, 1);
				if(debug) trace(' - LoaderEnhanced.priortize: moving: ' + spliced[0].fileName + ', ' + spliced[0].id + ', ' + spliced[0].loader);
				this.loadQueue.splice( 1, 0, spliced[0] );
				
				return true;
			}
			else
			{
				// The file is in slot 0 or 1, so we can confirm that it's prioritized
				return true;
			}		
		}
		
		
		public function start():void
		{
			if(debug) trace('exec LoaderEnhanced.start: decache:'+this.decache);
			
			
			if(this.isLoading) return;
			
			
			if(this.loadQueue.length > 0){
				this.isLoading = true;
				
				if(debug) trace(' - LoaderEnhanced.start: file: '+this.loadQueue[0].fileName);
				this.currentFileName = this.loadQueue[0].fileName;
				this.currentFileNum++;
				
				if(!this.startedAll){
					this.openAllEvent();
					this.startedAll = true;
				}
				
				
				this.loader = this.loadQueue[0].loader;
				this.addLoaderEventListeners(loader);
				
				// Use the decache variable if it exists				
				if (this.decache != null) {
					
					loader.load( new URLRequest(this.loadQueue[0].fileName + "?decache=" + this.decache) );
					
				} else {
					
					loader.load( new URLRequest(this.loadQueue[0].fileName) );
					
				}
				
			} else {
				
				//throw new Error('Error: LoaderEnhanced.start: Nothing in the queue to load');
				
			}
		}
		
		
		
		private function startNext():void
		{
			if(debug) trace('exec LoaderEnhanced.startNext');
			
			this.isLoading = false;			// Must be set here so start can continue if need be
			
			this.removeLoaderEventListeners( this.loadQueue[0].loader );
			
			this.loadQueue.shift();
			
			if(debug) trace(' - LoaderEnhanced.startNext: load queue length: ' + this.loadQueue.length);
			
			if (this.loadQueue.length == 0) {
				
				if(debug) trace(' - LoaderEnhanced.startNext: END OF QUEUE! length: ' + this.loadQueue.length);
				this.completeAllEvent();
				
			} else {
				
				if(debug) trace(' - LoaderEnhanced.startNext: continue queue: length: ' + this.loadQueue.length);
				
				this.start();
				
			}
		}
		
		/**
		 * Returns the number of item that are still in the queue
		 */
		public function getNumItemsInQueue():Number
		{
			return this.loadQueue.length;
		}
		
		/**
		 * Returns the load queue
		 */
		public function getLoadQueue():Array
		{
			return this.loadQueue;
		}
		
		/**
		 * Traces the loadQueue, for debug purposes
		 */
		public function traceLoadQueue():void
		{
			if(debug)
			{
				trace('exec LoaderEnhanced.traceLoadQueue: ____________________________');
				
				for(var i:int; i<loadQueue.length; i++)
				{
					trace(' - LoaderEnhanced.traceLoadQueue: id:' + loadQueue[i].id + ', fileName:' + loadQueue[i].fileName );
				}
				trace(' - LoaderEnhanced.traceLoadQueue: ____________________________');
			}
		}
		
		
		private function resetFileCounters():void
		{
			this.fileNumAll = 0;
			this.currentFileNum = 0;
		}
		
		
		
		private function getNextQueueId():int
		{
			
			this.lastQueueId++;
			
			if(debug) trace('LoaderEnhanced.getNextQueueId: '+this.lastQueueId);
			return this.lastQueueId;
			
		}
		
		
		private function getCurrentLoadingQueueId():int
		{
			//trace('LoaderEnhanced.getCurrentLoadingQueueId: '+this.loadQueue[0].id);
			
			return this.loadQueue[0].id;
			
		}
		
		
		
		private function addLoaderEventListeners(loader:Loader):void
		{
			
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, 		this.progressEvent);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, 				this.completeEvent);
			loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, 	this.httpStatusEvent);
			loader.contentLoaderInfo.addEventListener(Event.INIT, 					this.initEvent);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, 		this.ioErrorEvent);
			loader.contentLoaderInfo.addEventListener(Event.OPEN, 					this.openEvent);
			loader.contentLoaderInfo.addEventListener(Event.UNLOAD, 				this.unloadEvent);
			
		}
		
		
		private function removeLoaderEventListeners(loader:Loader):void
		{
			
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, 		this.progressEvent);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, 				this.completeEvent);
			loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, 	this.httpStatusEvent);
			loader.contentLoaderInfo.removeEventListener(Event.INIT, 					this.initEvent);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, 		this.ioErrorEvent);
			loader.contentLoaderInfo.removeEventListener(Event.OPEN, 					this.openEvent);
			loader.contentLoaderInfo.removeEventListener(Event.UNLOAD, 					this.unloadEvent);
		}
		
		
		/**
		 * If set to true, will trace debug information
		 */
		public function get debug():Boolean
		{
			return _debug;
		}
		
		public function set debug(debug:Boolean):void
		{
			_debug = debug;
		}
	}
}


internal class SingletonBlocker
{
	
}