package 
{
	
	/**
	 * ...
	 * @author trl
	 */
	public class GroupCreateEvent extends FaceEvent 
	{
		public var group_name:String;
		public function GroupCreateEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
	
}
