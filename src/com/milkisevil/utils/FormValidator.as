package com.milkisevil.utils 
{
	import nl.demonsters.debugger.MonsterDebugger;
	import flash.display.Sprite;
	import flash.text.TextField;

	/**
	* FormValidator
	*
	* @author 		Philip Bulley <p.bulley@impactproximity.com>
	* @version 		2.0.1
	* @usage		
	* 
	* 
	* History *******
	* 
	* v2.0.1
	* Added method to check for multiple email addresses - isEmailAddressMultiple
	*
	* v2.0
	* Ported to AS3
	* 
	* v1.1r1
	* Moved to utils package
	* 
	*/
	public class FormValidator 
	{
		
		private var target:Sprite;
		public var checkList:Array;
		public var errorList:Array;
		public var successList:Array;
		
		public function FormValidator(t:Sprite)
		{
			this.target = t;
			this.checkList = new Array();
		}
		
		/**
		* Set's up the validation checks which will be performed when FormValidator.isValid is called
		* @param	fieldName				The name of an object in the the target MovieClip, this will be the parent of a valueVariable
		* @param	valueVariable			A variable which holds the value, must be a child of the target's fieldName
		* @param	validatorFunction		A static function which will be used to validate the value
		*/
		public function addCheck( fieldName:String, valueVariable : String, validatorFunction:Function, validatorFunctionParams:Array = null ):void
		{
			//trace('exec FormValidator.addCheck: ' + fieldName );
			
			this.checkList[fieldName] = new Object();
			this.checkList[fieldName].fieldName = fieldName;
			this.checkList[fieldName].valueVariable = valueVariable;
			this.checkList[fieldName].validatorFunction = validatorFunction;
			this.checkList[fieldName].validatorFunctionParams = (validatorFunctionParams) ? validatorFunctionParams : [];
		}
		
		public function isValid():Boolean
		{
			successList = [];
			errorList = [];
			var value:Object;
			
			
			for(var fieldName:String in this.checkList)
			{
//				if(checkList[fieldName].valueVariable.indexOf('.') >-1)
//				{
//					value = this.target.getChildByName(fieldName)[ checkList[fieldName].valueVariable.split('.')[0] ][ checkList[fieldName].valueVariable.split('.')[1] ];
//					trace('fieldName has a dot: '+value);
//				}
//				else
//				{
					value = target.getChildByName(fieldName)[ checkList[fieldName].valueVariable ];
				//				}
//				
				var params:Array =  params = checkList[fieldName].validatorFunctionParams.slice();
				
				if(params)
				{
					 params.unshift(value);		// Add the value to the beginning of the params array
				}
				else
				{
					params = [ value ];
				}

				
				if(!this.checkList[fieldName].validatorFunction.apply(this, params))
				{
					errorList.push(fieldName);
				}
				else
				{
					successList.push( fieldName );
				}
				
			}
			
			//trace(' - FormValidator.isValid: errorList.length: '+errorList.length);
			if(errorList.length == 0)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		
		
		
		
		
		
		/*
		 * Static validation routine methods
		 */
		
		static public function isNumber(value:Object = null):Boolean
		{
			if(isNaN(Number(value))){
				return false;
			}else{
				return true;
			}
		}
		
		static public function isPresent(value:Object = null, defaultValue:Object = null):Boolean
		{
			//trace('FormValidator.isPresent: '+value);
			//first null used to be 'undefined'
			if( value == null || value == '' || value == 'empty' || (defaultValue && value == defaultValue)){
				return false;
			}else{
				return true;
			}
		}
		
		static public function isEmailAddress(value:Object = null, defaultValue:Object = null):Boolean
		{
			//trace('FormValidator.isEmailAddress: '+value);
			
			/*var errors:Number = 0;
			
			// check lenght of email addy
			if (value < 8) errors++;
			
			// check for @ symbol.
			if (value.indexOf("@", 0) < 1) errors++;
			
			// check for . symbol.
			if (value.lastIndexOf(".") < 5) errors++;
			
			return (errors) ? false : true;*/
			
			if(!value || (defaultValue && value == defaultValue) || (value.length < 6) || (value.indexOf (",") >= 0) || (value.indexOf (";") >= 0) || (value.indexOf (":") >= 0) || (value.indexOf ("/") >= 0) || (value.indexOf (" ") >= 0) || (value.indexOf ("@") <= 0) || (value.indexOf ("@") != value.lastIndexOf ("@")) || (value.lastIndexOf (".") < value.indexOf ("@")) || ((value.lastIndexOf (".") + 3) > value.length))
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
		/**
		 * Same validator as isEmailAddress, but allows and checks multiple email addresses
		 * separated by commas "," or semi-colons ";"
		 */
		static public function isEmailAddressMultiple(value:Object = null, defaultValue:Object = null):Boolean
		{
			var isValid:Boolean = true;
			
			if(!value)
			{
				return false;		// override and return false right away
			}
			
			// Replace all commas with semi-colons
			value = value.split(',').join(';');
			
			// Separate each address
			var addresses:Array = value.split(';');
			
			for each( var address:String in addresses )
			{
				if(!FormValidator.isEmailAddress( FormValidator.trim(address) ))
				{
					isValid = false;
					break;
				}
			}
			
			return isValid;
		}

		static public function isPhoneNumber(value:Object = null):Boolean
		{
			var permittedChars : String = '0123456789+-(). ';
			
			if(!FormValidator.isPresent(value)) return false;
			
			if(value.length < 5) return false;
			
			var char:String;
			for(var i:int=0; i<value.length; i++){
				char = value.charAt(i);
				if(permittedChars.indexOf(char) == -1){
					return false;
				}
			}
			return true;
		}
		
		static public function isTrue(value:Object = null):Boolean
		{
			if(value == 'true') value = true;		// Convert from String true to Boolean true
			if(value == 'false') value = false;		// Convert from String false to Boolean false
			
			if(value !== true)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
		static public function isFalse(value:Object = null):Boolean
		{
			if(value == 'true') value = true;
			if(value == 'false') value = false;
			
			if(value !== false)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
		/**
		 * Use to check if a field's value matched another supplied value
		 * @param value				The main value to test
		 * @param valueToMatch		The secondary value to test against/match
		 */
		static public function isMatchField(value:Object = null, target:Sprite = null, fieldName:String = null, valueVariable:String = null):Boolean
		{
			if( value != target.getChildByName(fieldName)[ valueVariable ])
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
		
		
		
		
		/**
		*	Removes whitespace from the front and the end of the specified
		*	string.
		* 
		*	@param input The String whose beginning and ending whitespace will
		*	will be removed.
		*
		*	@returns A String with whitespace removed from the begining and end	
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/			
		private static function trim(input:String):String
		{
			return FormValidator.ltrim(FormValidator.rtrim(input));
		}

		/**
		*	Removes whitespace from the front of the specified string.
		* 
		*	@param input The String whose beginning whitespace will will be removed.
		*
		*	@returns A String with whitespace removed from the begining	
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/	
		private static function ltrim(input:String):String
		{
			var size:Number = input.length;
			for(var i:Number = 0; i < size; i++)
			{
				if(input.charCodeAt(i) > 32)
				{
					return input.substring(i);
				}
			}
			return "";
		}

		/**
		*	Removes whitespace from the end of the specified string.
		* 
		*	@param input The String whose ending whitespace will will be removed.
		*
		*	@returns A String with whitespace removed from the end	
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/	
		private static function rtrim(input:String):String
		{
			var size:Number = input.length;
			for(var i:Number = size; i > 0; i--)
			{
				if(input.charCodeAt(i - 1) > 32)
				{
					return input.substring(0, i);
				}
			}

			return "";
		}
		
	}
	
}



