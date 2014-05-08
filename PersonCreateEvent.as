package
{
	
	/**
	 * ...
	 * @author trl
	 */
	public class PersonCreateEvent extends FaceEvent
	{
		var person_name:String;
		public function PersonCreateEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	
	}

}
