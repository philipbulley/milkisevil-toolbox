package com.milkisevil.utils
{
	import com.google.analytics.AnalyticsTracker;
	import com.google.analytics.GATracker;

	import flash.display.Sprite;

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 * @version 1.1
	 * 
	 * Requires analytics.swc to be added to the class path
	 * 
	 *
	 * Usage:
	 * 
	 * // Initiate the singleton
	 * GoogleAnalytics.getInstance().init( viewComponent as Sprite, gaAccountCode, gaVisualDebug, gaIsLive );
	 * 
	 * // Track calls
	 * GoogleAnalytics.getInstance().track( '/my/path' );
	 * 
	 * 
	 * 
	 * History:
	 * 
	 * v1.1
	 * Added isLive and renamed debug to visualDebug
	 * 
	 * 
	 */
	public class GoogleAnalytics extends Sprite
	{
		private static var instance:GoogleAnalytics;
		private var analyticsAccountCode:String;
		private var tracker:AnalyticsTracker;
		public var _initComplete:Boolean;
		private var isLive:Boolean;

		public function GoogleAnalytics( blocker:SingletonBlocker )
		{
			
		}
		
		public static function getInstance():GoogleAnalytics
		{
			if(!instance) instance = new GoogleAnalytics( new SingletonBlocker() );
			return instance;
		}
		
		/**
		 * Initiate Google Analytics
		 * 
		 * @param parent					Google Analytics needs to be added to the display list
		 * @param analyticsAccountCode		The unique google analytics code, usually in the format of "UA-XXXXXXX-X"
		 * @param visualDebug				Display on-screen what is happening under the hood
		 * @param isLive					Should data be sent to the live google analytics service?
		 */
		public function init( parent:Sprite, analyticsAccountCode:String, visualDebug:Boolean = false, isLive:Boolean = true ):void
		{
			//trace( 'exec GoogleAnalytics.init: ' + analyticsAccountCode);
			
			this.isLive = isLive;
			this.analyticsAccountCode = analyticsAccountCode;
			
			if(visualDebug && !isLive) throw new Error('Currently, Google Analytics must send live data for the visualDebug to operate.');
			
			parent.addChild( this );
			
			tracker = new GATracker( this, analyticsAccountCode, "AS3", visualDebug );
			
			_initComplete = true;
		}
		
		/**
		 * Makes sends a track call to Google Analytics.
		 * 
		 * @param path							The path to track
		 * @param forceOmitPrecedingSlash		Set to true to ensure a slash is not present at the beginning of the tracking path. 
		 * 										If your tracking path does not include a preceding slash, it will be added unless this is set to true.
		 * 										If your path does include a preceding slash, it will be removed if this is set to true.
		 */
		public function track( path:String, forceOmitPrecedingSlash:Boolean = false ):void
		{
			if(!_initComplete) throw new Error('Please init() the GoogleAnalytics singleton specifying your analyticsAccountCode before making tracking calls.');
			
			if(!forceOmitPrecedingSlash && path.substr(0, 1) != '/')
			{
				path = '/' + path;
			}
			
			if(forceOmitPrecedingSlash && path.substr(0, 1) == '/')
			{
				path = path.substr(1, path.length);
			}
			
			if(isLive) tracker.trackPageview( path ); 
		}
		
		public function get initComplete():Boolean
		{
			return _initComplete;
		}
	}
	
}

internal class SingletonBlocker
{
	
}