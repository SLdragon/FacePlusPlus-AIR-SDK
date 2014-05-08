package
{
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	import flash.filesystem.FileStream;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import UploadPostHelper;
	
	/**
	 * ...
	 * @author trl
	 */
	public class FacePlusPlus extends EventDispatcher
	{
		public static var API_KEY:String;
		public static var API_SECRET:String;
		public static var URL:String;
		public var current_face_id:String;
		
		public function FacePlusPlus(key:String="",secret:String="")
		{
			intial(key, secret, "http://apicn.faceplusplus.com");
		}
		
		public function intial(key:String, secret:String, url:String = "http://apicn.faceplusplus.com")
		{
			API_KEY = key;
			API_SECRET = secret;
			URL = url;
		}
		
		//detect picture from web
		public function detect_file_web(url:String="")
		{
			var url_request:URLRequest = new URLRequest("http://apicn.faceplusplus.com/v2/detection/detect?url="+url);
			url_request.method = "POST";
			
			var variables:URLVariables = new URLVariables();
			variables.api_key = API_KEY;
			variables.api_secret = API_SECRET;
			url_request.data = variables;
			
			var url_loader:URLLoader = new URLLoader();
			url_loader.addEventListener(Event.COMPLETE, onGetFaceComplete);
			url_loader.load(url_request);
			url_loader.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);
		
		}
		
		public function onGetFaceComplete(e:Event)
		{
			var url_loader:URLLoader = URLLoader(e.target);
			trace(url_loader.data);
			var people:Object = JSON.parse(url_loader.data);
			//trace(people.face[0].face_id);
			
			var face_event:FaceDetectEvent = new FaceDetectEvent(FaceEvent.FACE_DETECT_OK);
			if (people.face.length > 0)
			{
				face_event.face_id = people.face[0].face_id;
			}
			else
			{
				face_event.face_id = null;
			}
			
			dispatchEvent(face_event);
		}
		
		
		
		public function detect_file_local(file_path:String)
		{
			var img:ByteArray = readBinary(file_path);
			var url_request:URLRequest = new URLRequest("http://apicn.faceplusplus.com/v2/detection/detect");
			url_request.method = "POST";
			
			url_request.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
			url_request.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );
			var obj:Object = new Object();
			obj.api_key = API_KEY;
			obj.api_secret = API_SECRET;
			var variables:ByteArray=UploadPostHelper.getPostData(img,obj);
			url_request.data = variables;
			
			var url_loader:URLLoader = new URLLoader();
			url_loader.addEventListener(Event.COMPLETE, onGetFaceComplete);
			url_loader.load(url_request);
			url_loader.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);
		}
		
		
		public function create_group(group_name:String)
		{
			var url_request:URLRequest = new URLRequest("https://apicn.faceplusplus.com/v2/group/create?api_key="+API_KEY+"&api_secret="+API_SECRET+"&group_name="+group_name);
			url_request.method = "POST";
			var url_loader:URLLoader = new URLLoader();
			url_loader.addEventListener(Event.COMPLETE, onGroupCreate);
			url_loader.load(url_request);
			url_loader.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);			
		}
		
		public function onGroupCreate(e:Event)
		{
			var url_loader:URLLoader = URLLoader(e.target);
			trace(url_loader.data);
			var group:Object = JSON.parse(url_loader.data);
			
			var face_event:GroupCreateEvent = new GroupCreateEvent(FaceEvent.GROUP_CREAT_OK);
			face_event.group_name = group.group_name;
			dispatchEvent(face_event);
				
		}
		
		public function creat_person(person_name:String,face_id:String,group_name:String,tag:String)
		{
			var url_request:URLRequest = new URLRequest("https://apicn.faceplusplus.com/v2/person/create?api_key="+API_KEY+"&api_secret="+API_SECRET+"&person_name="+person_name+"&face_id="+face_id+"&group_name="+group_name+"&tag="+tag);
			trace(("https://apicn.faceplusplus.com/v2/person/create?api_key=" + API_KEY + "&api_secret=" + API_SECRET + "&person_name=" + person_name + "&face_id" + face_id + "&group_name" + group_name));
			url_request.method = "POST";
			var url_loader:URLLoader = new URLLoader();
			url_loader.addEventListener(Event.COMPLETE, onPersonCreate);
			url_loader.load(url_request);
			url_loader.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);	
		}
		
		public function onPersonCreate(e:Event)
		{
			
			var url_loader:URLLoader = URLLoader(e.target);
			trace(url_loader.data);
			var person:Object = JSON.parse(url_loader.data);
			
			var face_event:PersonCreateEvent = new PersonCreateEvent(FaceEvent.PERSON_CREATE_OK);
			face_event.person_name = person.person_name;
			dispatchEvent(face_event);
			
		}
		
		public function add_face_to_person(person_name:String, face_id:String)
		{
			//trace(("https://apicn.faceplusplus.com/v2/person/add_face?api_key="+API_KEY+"&api_secret="+API_SECRET+"&person_name="+person_name+"&face_id="+face_id));
			var url_request:URLRequest = new URLRequest("https://apicn.faceplusplus.com/v2/person/add_face?api_key="+API_KEY+"&api_secret="+API_SECRET+"&person_name="+person_name+"&face_id="+face_id);
			url_request.method = "GET";
			var url_loader:URLLoader = new URLLoader();
			url_loader.addEventListener(Event.COMPLETE, onLoadCom);
			url_loader.load(url_request);
			url_loader.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);	
		}
		
		public function add_person_to_group(person_name:String, group_name:String)
		{
			var url_request:URLRequest = new URLRequest("https://apicn.faceplusplus.com/v2/group/add_person?api_key="+API_KEY+"&api_secret="+API_SECRET+"&person_name="+person_name+"&group_name="+group_name);
			url_request.method = "POST";
			var url_loader:URLLoader = new URLLoader();
			url_loader.addEventListener(Event.COMPLETE, onLoadCom);
			url_loader.load(url_request);
			url_loader.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);	
		}
		
		public function train_identify(group_name:String)
		{
			var url_request:URLRequest = new URLRequest("https://apicn.faceplusplus.com/v2/train/identify?api_key="+API_KEY+"&api_secret="+API_SECRET+"&group_name="+group_name);
			url_request.method = "POST";
			var url_loader:URLLoader = new URLLoader();
			url_loader.addEventListener(Event.COMPLETE, onLoadCom);
			url_loader.load(url_request);
			url_loader.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);	
		}
		
		public function get_session(session_id:String)
		{
			var url_request:URLRequest = new URLRequest("https://apicn.faceplusplus.com/v2/info/get_session?api_key="+API_KEY+"&api_secret="+API_SECRET+"&session_id="+session_id);
			url_request.method = "POST";
			var url_loader:URLLoader = new URLLoader();
			url_loader.addEventListener(Event.COMPLETE, onLoadCom);
			url_loader.load(url_request);
			url_loader.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);	
		}
		
		public function identify_similar_person_web(group_name:String,url:String)
		{
			var url_request:URLRequest = new URLRequest("https://apicn.faceplusplus.com/v2/recognition/identify?api_key=" + API_KEY + "&api_secret=" + API_SECRET + "&group_name=" + group_name + "&url=" + url);
			url_request.method = "POST";
			var url_loader:URLLoader = new URLLoader();
			url_loader.addEventListener(Event.COMPLETE, onLoadCom);
			url_loader.load(url_request);
			url_loader.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);	
		}
		
		public function identify_similar_person_local(group_name:String, file_path:String)
		{
			var img:ByteArray = readBinary(file_path);
			var url_request:URLRequest = new URLRequest("https://apicn.faceplusplus.com/v2/recognition/identify?api_key=" + API_KEY + "&api_secret=" + API_SECRET + "&group_name=" + group_name+"&img="+img);
			
			url_request.method = "POST";
			
			url_request.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
			url_request.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );
			var obj:Object = new Object();
			obj.api_key = API_KEY;
			obj.api_secret = API_SECRET;
			var variables:ByteArray=UploadPostHelper.getPostData(img,obj);
			url_request.data = variables;
			
			var url_loader:URLLoader = new URLLoader();
			url_loader.addEventListener(Event.COMPLETE, onIdentifyOK);
			url_loader.load(url_request);
			url_loader.addEventListener(IOErrorEvent.IO_ERROR, this.errorHandler);	
		}
		
		public function onIdentifyOK(e:Event)
		{
			var url_loader:URLLoader = URLLoader(e.target);
			trace(url_loader.data);
			var result:Object = JSON.parse(url_loader.data);
			
			var face_event:IdentifyEvent = new IdentifyEvent(FaceEvent.IDENTIFY_OK);
			face_event.identify_result_str = "";

			for (var i:int = 0; i < result.face[0].candidate.length; i++)
			{
				
				face_event.identify_result_str+= "candidate" + i + "  url=" + result.face[0].candidate[i].tag + "  confidence" + result.face[0].candidate[i].confidence;
				face_event.identify_result_str+="\r\n"
			}
			if (face_event.identify_result_str == "")
			{
				face_event.identify_result_str = "no candidate find!";
			}
			
			trace(face_event.identify_result_str);
			dispatchEvent(face_event);
			
			
		}
		
		//wrote this function
		private function errorHandler(e:ErrorEvent):void
		{
			var url_loader:URLLoader = URLLoader(e.target);
			trace(url_loader.data);
			trace("got you.!!! " + e.toString());
		}
		
		
		
		public function onLoadCom(e:Event)
		{
			var url_loader:URLLoader = URLLoader(e.target);
			trace(url_loader.data);
			var people:Object = JSON.parse(url_loader.data);			
			//trace(people.face[0].face_id);
		}
		
		private function readBinary(file_path:String)
		{
			var fileStream:FileStream = new FileStream();
			trace(file_path);
			var file:File = new File(file_path);
			fileStream.open(file, FileMode.READ);
			var bytes:ByteArray = new ByteArray();
			fileStream.readBytes(bytes);
			fileStream.close();
			return bytes;
		}
	
	}

}
