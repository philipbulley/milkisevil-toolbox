package com.milkisevil.api.facebook 
{
	import trace;
	import com.facebook.Facebook;
	import com.facebook.commands.friends.GetAppUsers;
	import com.facebook.commands.users.GetInfo;
	import com.facebook.data.users.FacebookUser;
	import com.facebook.data.users.FacebookUserCollection;
	import com.facebook.data.users.GetInfoData;
	import com.facebook.data.users.GetInfoFieldValues;
	import com.facebook.events.FacebookEvent;
	import com.facebook.facebook_internal;
	import com.facebook.net.FacebookCall;
	import com.facebook.session.WebSession;
	import com.facebook.utils.FacebookConnectUtil;
	import com.milkisevil.api.facebook.vo.FacebookStreamPublishCompleteVO;
	import com.milkisevil.api.facebook.vo.FacebookStreamPublishVO;
	import com.milkisevil.events.StatusEventEnhanced;

	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class FacebookWrapper extends EventDispatcher
	{
		public static const NAME:String 							= "FacebookWrapper";
		public static const STATUS_EVENT:String 					= NAME + ".STATUS_EVENT";		public static const LOGIN_COMPLETE:String 					= NAME + ".LOGIN_COMPLETE";		public static const LOGIN_CANCELLED:String 					= NAME + ".LOGIN_CANCELLED";		public static const LOGIN_ERROR:String 						= NAME + ".LOGIN_ERROR";		public static const GET_USER_INFO_COMPLETE:String 			= NAME + ".GET_USER_INFO_COMPLETE";		public static const GET_CURRENT_USER_INFO_COMPLETE:String 	= NAME + ".GET_CURRENT_USER_INFO_COMPLETE";
		public static const GET_APP_USERS_COMPLETE:String 			= NAME + ".GET_APP_USERS_COMPLETE";
		public static const STREAM_PUBLISH_JS_COMPLETE:String 		= NAME + ".STREAM_PUBLISH_JS_COMPLETE";
		
		public const URL_EVENT:String 								= 'http://www.facebook.com/event.php?eid=[ID]';
		public const URL_EVENT_EDIT:String 							= 'http://www.facebook.com/events/edit/index.php?eid=[ID]';
		public const URL_EVENT_EDIT_GUESTS:String 					= 'http://www.facebook.com/events/edit/index.php?eid=[ID]&step=4&edit_guests=1';
		public const URL_EVENT_INVITE:String 						= 'http://www.facebook.com/events/edit/index.php?eid=[ID]&step=3';
		public const URL_EDIT_APPS:String 							= 'http://www.facebook.com/editapps.php';

		public static var instance:FacebookWrapper;
		
		private var connect:FacebookConnectUtil;
		private var facebook:Facebook;
		private var webSession:WebSession;
		private var currentUser:FacebookUser;

		public function FacebookWrapper(blocker:SingletonBlocker)
		{
		}

		public static function getInstance():FacebookWrapper
		{
			if(!instance) instance = new FacebookWrapper(new SingletonBlocker());
			return instance;
		}
		
		public function init( stage:Stage ):void
		{
			connect = new FacebookConnectUtil( stage.loaderInfo );
			facebook = new Facebook();
		}
		
		public function login():void
		{
			ExternalInterface.addCallback("loginComplete", loginComplete );			ExternalInterface.addCallback("loginCancelled", loginCancelled );
			ExternalInterface.call("login");
		}
		
		
		private function loginComplete( parameters:Object ):void
		{
			//trace('exec FacebookWrapper.loginComplete: ' + parameters );
			
			if(!connect) throw new Error( 'Please call init() before calling login, supplying a reference to the stage' );
			
			//MonsterDebugger.trace( this, parameters );
			
			if (parameters.apiKey && parameters.secret && parameters.sessionKey) 
			{
				startSesstion( parameters.apiKey, parameters.secret, parameters.sessionKey, parameters.uid );			
				
				//showPermissionDialog( ExtendedPermissionValues.CREATE_EVENT, showPermissionDialogComplete );
			}
			else
			{
				log(' - FacebookWrapper.loginComplete: failed');
			}
		}
		
		public function startSesstion(apiKey:String, secret:String, sessionKey:String, uid:String):void
		{
			//Start a WebSession with the ss and session key passed in from Javascript
			webSession = new WebSession( apiKey, secret, sessionKey );
			webSession.facebook_internal::_uid = uid;	
			facebook.startSession( webSession );
			
			webSession.addEventListener( FacebookEvent.CONNECT, webSessionConnect );
			webSession.verifySession();
		}

		private function loginCancelled():void
		{
			//trace('exec FacebookWrapper.loginCancelled');
			
			dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, LOGIN_CANCELLED ) );
		}
		
		private function webSessionConnect( event:FacebookEvent ):void
		{
			//trace('exec FacebookWrapper.webSessionConnect: ' + event);
			
			if( event.success )
			{
				dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, LOGIN_COMPLETE ) );
			}
			else
			{
				// Javascript will handle login here
				trace('exec FacebookWrapper.webSessionConnect: ERROR: ' + event);
				dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, LOGIN_ERROR ) );
			}
		}
		
		/**
		 * Show's a dialog prompting the user to grant certain permissions.
		 * Make sure you have the appropriate custom javascript methods available.
		 * 
		 * @param permissions		Comma separated list of permissions, use values of ExtendedPermissionValues.XXXX
		 * @see						http://wiki.developers.facebook.com/index.php/Extended_permissions
		 * @see						http://developers.facebook.com/docs/?u=facebook.jslib.FB.Connect.showPermissionDialog
		 */
		public function showPermissionDialog( permissions:String, callback:Function ):void
		{
			var callbackFunctionName:String = "showPermissionDialogComplete";
			ExternalInterface.addCallback(callbackFunctionName, callback );
			ExternalInterface.call("showPermissionDialog", permissions, callbackFunctionName);
		}
		
		private function showPermissionDialogComplete( success:Boolean ):void
		{
			log('exec FacebookWrapper.showPermissionDialogComplete: ' + success );
			log(' - permissions granted = ' + success + ' | ' + URL_EDIT_APPS );
		}
		
		
		
		/****************************
		 * UTILITY METHODS
		 */
		
		
		/**
		 * Gets user info
		 * 
		 * @param getInfoFieldValues		Use an array containing GetInfoFieldValues.XXXX		 * @param uids						Use an array of facebook uid values. Use null to default to current user.
		 */
		public function getCurrentUserInfo( getInfoFieldValues:Array = null ):void
		{
			// Default to these values
			if(!getInfoFieldValues) getInfoFieldValues = [GetInfoFieldValues.PIC_SQUARE_WITH_LOGO, GetInfoFieldValues.FIRST_NAME, GetInfoFieldValues.LAST_NAME, GetInfoFieldValues.SEX];
			
			var call:FacebookCall = new GetInfo( [facebook.uid], getInfoFieldValues );
			call.addEventListener( FacebookEvent.COMPLETE, getCurrentUserInfoComplete );
			
			facebook.post( call );
		}
		
		private function getCurrentUserInfoComplete(event:FacebookEvent):void
		{
			var getInfoData:GetInfoData = event.data as GetInfoData;
			currentUser = getInfoData.userCollection.getItemAt(0) as FacebookUser;
			
			dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, GET_CURRENT_USER_INFO_COMPLETE, currentUser ) );
		}
		
		
		/**
		 * Gets user info
		 * 
		 * @param getInfoFieldValues		Use an array containing GetInfoFieldValues.XXXX
		 * @param uidList						Use an array of facebook uid values. Use null to default to current user.
		 */
		public function getUserInfo( getInfoFieldValues:Array = null, uidList:Array = null ):void
		{
			// Default to these values
			if(!getInfoFieldValues) getInfoFieldValues = [GetInfoFieldValues.PIC_SQUARE_WITH_LOGO, GetInfoFieldValues.FIRST_NAME, GetInfoFieldValues.LAST_NAME, GetInfoFieldValues.SEX];
			
			// Default to the current user only
			if(!uidList) uidList = [facebook.uid];
			
			//trace(' - FacebookWrapper.getUserInfo: ' + uidList.join(','));
			
			var call:FacebookCall = new GetInfo( uidList, getInfoFieldValues );	
			call.addEventListener( FacebookEvent.COMPLETE, getUserInfoComplete );
			
			facebook.post( call );
		}
		
		private function getUserInfoComplete(event:FacebookEvent):void
		{
			//log('exec FacebookWrapper.getUserInfoComplete: ' + event);
			
			//MonsterDebugger.trace( this, event, undefined, undefined, 6 );
			
			var getInfoData:GetInfoData = event.data as GetInfoData;			var userCollection:FacebookUserCollection = getInfoData.userCollection as FacebookUserCollection;
			
			//MonsterDebugger.trace( this, getInfoData.userCollection, undefined, undefined, 6 );
			
			dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, GET_USER_INFO_COMPLETE, userCollection) );
		}
		
		public function getAppUsers():void
		{
			var call:FacebookCall = new GetAppUsers();	
			call.addEventListener( FacebookEvent.COMPLETE, getAppUsersComplete );
			
			facebook.post( call );
		}
		
		public function getAppUsersComplete(event:FacebookEvent):void
		{
			var uidFriends:Array = event.data['uids'];
			
			// Convert all uidFriend uids from Number to String because AMFPHP messes this up (converts large int values to float)
			for(var i:int = 0; i<uidFriends.length; i++)
			{
				uidFriends[i] = uidFriends[i].toString();
			}
			
			dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, GET_APP_USERS_COMPLETE, uidFriends ) );
		}
		
		/**
		 * Attempts to do a streamPublish via javascript.
		 * Make sure the milkisevil/facebook.js library is available to the HTML
		 */
		public function streamPublishJS( facebookStreamPublishVO:FacebookStreamPublishVO ):void
		{
			//MonsterDebugger.trace( this, facebookStreamPublishVO.attachment );			//MonsterDebugger.trace( this, facebookStreamPublishVO.actionLinks );
			
			
			
			ExternalInterface.addCallback('streamPublishComplete', streamPublishJSComplete);
			ExternalInterface.call("streamPublish", facebookStreamPublishVO.attachment, facebookStreamPublishVO.actionLinks.toArray(), facebookStreamPublishVO.targetID, facebookStreamPublishVO.userMessagePrompt );		}
		
		public function streamPublishJSComplete( parameters:Object ):void
		{
			trace('exec FacebookWrapper.streamPublishJSComplete: ' + parameters );
			/*
			 * parameters = {postID, exception}
			 */
			
			dispatchEvent( new StatusEventEnhanced( STATUS_EVENT, false, false, STREAM_PUBLISH_JS_COMPLETE, new FacebookStreamPublishCompleteVO( parameters.postID, parameters.exception ) ) );
		}
		
		
		
		public function inviteFriendsJS(appName:String, canvasURL:String, message:String, actionText:String = 'Invite your friends', authorizeButtonLabel:String = 'Authorize My Application', actionURL:String = '{CURRENT_PAGE}'):void
		{
			var fbml:String = '';
			fbml += '<fb:fbml>';
			fbml +=		'<fb:request-form action="'+actionURL+'" method="POST" invite="true" type="'+appName+'" content="'+message+' ' + ('&lt;fb:req-choice url=&quot;'+canvasURL+'&quot; label=&quot;'+authorizeButtonLabel+'&quot;&gt;') + ' ">';
			fbml +=		'<fb:multi-friend-selector showborder="false" rows="4" max="20" actiontext="'+actionText+'">';
			fbml +=		'</fb:request-form>';
			fbml +=		'</fb:fbml>';

			ExternalInterface.call("showDialog", 'Invite your friends to ' + appName, fbml);
		}
		
		
		
		/***************************
		 * DEBUG METHODS
		 */
		
		private function log( str:String  ):void
		{
			trace( str );
			//child.tf.htmlText = '<p>' + str + '</p>' + child.tf.htmlText;
		}
	}
}


internal class SingletonBlocker
{
	
}