package com.milkisevil.api.facebook.vo 
{

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class FacebookStreamPublishCompleteVO 
	{
		public var exception:String;
		public var postID:String;

		public function FacebookStreamPublishCompleteVO( postID:String, exception:String )
		{
			this.postID = postID;
			this.exception = exception;
		}
	}
}
