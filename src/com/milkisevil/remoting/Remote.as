package com.milkisevil.remoting 
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.Timer;

	/**
	 * ...
	 * @author Philip Bulley <philip@milkisevil.com>
	 * @usage
	 * 
	 * Recommended usage is that only 1 remote call should be made per instance of Remote. 
	 * Create multiple instances to make subsequent calls.
	 	
	 	var remote:Remote = new Remote( 'http://someplace/gateway.php', 20, remoteCallComplete, remoteCallError );
	 	makeRemoteCall( 'ServiceName.methodName', dataParam1, dataParam2... );
	   
	    private function remoteCallComplete( result:Object ):void
		{
			
		}
		
		private function remoteCallError( error:Object ):void
		{
			
		}
		
		
	 * 
	 */
	public class Remote extends EventDispatcher
	{

		private var nc:NetConnection;
		private var responder:Responder;

		private var timeoutTimer:Timer;
		private var timeoutSecs:Number;
		private var gatewayURL:String;
		private var callbackComplete:Function;
		private var callbackError:Function;
		

		public function Remote( gatewayURL:String = null, timeoutSecs:Number = 20, callbackComplete:Function = null, callbackError:Function = null ) 
		{
			if( gatewayURL ) init( gatewayURL, timeoutSecs, callbackComplete, callbackError );
		}
		
		/**
		 * Initialise the remote
		 * 
		 * @param gatewayURL		The URL of the AMF gateway/endpoint
		 * @param timeoutSecs		Number of seconds until timeout after makeRemoteCall()
		 */
		protected function init( gatewayURL:String, timeoutSecs:Number = 20, callbackComplete:Function = null, callbackError:Function = null ):void
		{
			this.gatewayURL = gatewayURL;
			this.timeoutSecs = timeoutSecs;
			this.callbackComplete = callbackComplete;
			this.callbackError = callbackError;
			
			//
			
			connect();
			
			responder = new Responder( makeRemoteCallComplete, makeRemoteCallError );
			
			timeoutTimer = new Timer( timeoutSecs * 1000, 1 );
			timeoutTimer.addEventListener( TimerEvent.TIMER_COMPLETE, makeRemoteCallTimeout );			
		}
		
		
		
		
		// --------------------------------------------------------------------
		
		
		
		/**
		 * Makes a call to the remote gateway defined via the init() method
		 * 
		 * @param command		The name of the remote command to run, (ie. ServiceName.methodName)
		 * @param arguments		Pass as many arguments as you like
		 */
		public function makeRemoteCall(command:String, ...arguments):void
		{
			trace('exec Remote.makeRemoteCall: ' + command );
			
			timeoutTimer.start();
			
			try
			{
				var parameters:Array = arguments;
				if (parameters.length > 0)
				{
					parameters.unshift(command, responder);
					nc.call.apply( nc, parameters );
				} 
				else
				{
					nc.call.apply( nc, [ command, responder, null ] );
				}				
			}
			catch (e:Error)
			{
				makeRemoteCallError(e);
			}
			catch (e:SecurityError)
			{
				makeRemoteCallError(e);
			}
		}
		
		/**
		 * Cancels any cals currently in progress
		 * NOTE: untested ;)
		 */
		public function cancel():void
		{
			if(nc.connected)
			{
				 nc.close();
				 nc.removeEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
				 nc.connect( gatewayURL );
			}
		}
		
		
		private function connect():void
		{
			nc = new NetConnection();
			nc.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			nc.connect( gatewayURL );
		}
		
		private function netStatusHandler(event:NetStatusEvent):void
		{
			switch (event.info.code) {
				
				case "NetConnection.Connect.Success": // Never fired
					//
				break;
				
				case "NetConnection.Connect.Closed": // Fired
					//
				break;
				
				case "NetConnection.Call.BadVersion": // Fired after script running limit
					makeRemoteCallError( 'Server error: NetConnection.Call.BadVersion' );
				break;	
				
				case "NetConnection.Connect.Failed": // Never Fired
					makeRemoteCallError( 'Server error: NetConnection.Connect.Failed' );
				break;
			}
		}

		private function close():void
		{
			if(nc.connected) nc.close();
		}
		
		private function makeRemoteCallComplete( result:Object ):void
		{
			trace('exec Remote.makeRemoteCallComplete: ' + result);
			
			timeoutTimer.reset();
			//dispatchEvent( new RemoteStatusEvent( RemoteStatusEvent.STATUS_EVENT, false, false, RemoteStatusEvent.COMPLETE, null, result ) );
			if( this['callbackComplete'] ) callbackComplete( result );
		}
		
		
		private function makeRemoteCallTimeout(event:TimerEvent):void
		{
			trace('exec Remote.makeRemoteCallTimeout');
			
			cancel();
			makeRemoteCallError( 'The connection timed out' );			
		}
		
		private function makeRemoteCallError(error:Object):void
		{
			trace('exec Remote.makeRemoteCallError: ' + error);
			
			//trace('exec Remote.error: ' + error);
			timeoutTimer.reset();
			//dispatchEvent( new RemoteStatusEvent( RemoteStatusEvent.STATUS_EVENT, false, false, RemoteStatusEvent.ERROR, null, error ) );
			if( this['callbackError'] ) callbackError( error );
		}
		
		
	}
	
}