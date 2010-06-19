package com.milkisevil.api.facebook.vo 
{
	import com.facebook.data.stream.ActionLinkCollection;
	import com.facebook.data.stream.AttachmentData;

	/**
	 * @author Philip Bulley <philip@milkisevil.com>
	 */
	public class FacebookStreamPublishVO 
	{
		public var userMessagePrompt:String;
		public var targetID:String;
		public var actionLinks:ActionLinkCollection;
		public var attachment:AttachmentData;

		public function FacebookStreamPublishVO( attachment:AttachmentData = null, actionLinks:ActionLinkCollection = null, targetID:String = null, userMessagePrompt:String = null  )
		{
			this.attachment = attachment;
			this.actionLinks = actionLinks;
			this.targetID = targetID;
			this.userMessagePrompt = userMessagePrompt;
		}
	}
}
