package 
{
	
	/**
	 * ...
	 * @author trl
	 */
	public class FaceDetectEvent extends FaceEvent 
	{
		public var face_id:String;
		public function FaceDetectEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
	
}
