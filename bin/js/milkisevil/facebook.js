			
			/**
			*	Don't forget to init in the main app html	
			*
			*	var API_KEY = 'blahblahblah';			
			*	FB.init( API_KEY, 'xd_receiver.htm' );
			*/
			
			
			
			/**
			* Start the Facebook Connect login process
			*/
			function login()
			{
				//alert('login');
				FB.Connect.requireSession( loginComplete, loginCancelled );
			}
			
			
			/** 
             * Facebook connect login has been completed, successful or not
             */
            function loginComplete() 
            {
				//alert('loginComplete: ' + FB.Facebook.apiClient._session);
				
				var session = FB.Facebook.apiClient._session;
				
				var parameters = {
					apiKey: API_KEY,
					expires: session.expires,
					secret: session.secret,
					sessionKey: session.session_key,
					sig: session.sig,
					uid: session.uid
				};
				
				swfDispatcher( 'loginComplete', parameters );
            }
            
            /** 
             * Facebook connect login has been completed, successful or not
             */
            function loginCancelled() 
            {
            	//alert('loginCancelled');
            	
            	swfDispatcher( 'loginCancelled' );
            }
            
            function streamPublish( attachment, action_links, target_id, user_message_prompt )
            {
            	FB.Connect.streamPublish( '', attachment, action_links, target_id, user_message_prompt, streamPublishComplete );
            }
            
            function streamPublishComplete( post_id, exception )
            {
            	swfDispatcher( 'streamPublishComplete', {postID: post_id, exception:exception} );
            }
            
            
            function showPermissionDialog(permissions, swfCallback)
            {
            	//alert( 'exec showPermissionDialog:\n' + permissions + '\n' + swfCallback );
            	
            	FB.Connect.showPermissionDialog(permissions, function(perms) 
            	{
					if (perms) 
					{
						swfDispatcher( swfCallback, true );
					} 
					else 
					{
						swfDispatcher( swfCallback, false );
					}
				 });
            }
            
            
            /**
            * Shows an AJAX powered dialog box, populated with the fbmlContent
			* Ideal for showing an invite requestor (aka multi-friend-selector)
            */
            function showDialog( title, fbmlContent )
			{
			 //FB.ensureInit(function()
			  //{
			        var dialog = new FB.UI.FBMLPopupDialog( title, '' );
			        var fbml = fbmlContent;
			        
			        fbml = fbml.replace( '{CURRENT_PAGE}', location.href );

			        dialog.setFBMLContent(fbml);
			        dialog.setContentWidth(745);
			        dialog.setContentHeight(620);
			        
			        dialog.show();
			    //});
			}
            
			/**
			* Call actionscript ExternalInterface methods
			*/
            function swfDispatcher( func )
			{
				if( arguments.length > 1 )
				{
					swfobject.getObjectById( 'swf' )[func]( Array.prototype.slice.call(arguments).slice(1)[0]);
				}
				else
				{
					swfobject.getObjectById( 'swf' )[func]();
				}
			}
			