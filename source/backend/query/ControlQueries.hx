package backend.query;

class ControlQueries
{
	public var currentQueries:Array<ControlQuery> = [];

	public function new()
	{
	}

	public function update(elapsed:Float)
	{
		var currentQuery = null;
		var i:Int = 0;

		while (i < currentQueries.length)
		{
			currentQuery = currentQueries[i++];

			if (currentQuery != null)
			{
				try
				{
					currentQuery.FunctionTask(currentQuery.Key, currentQuery.Arguments);
				} catch (e)
				{
				}
			}

			currentQueries.splice(currentQueries.indexOf(currentQuery), 1);
		}
	}
}

typedef ControlQuery =
{
	var FunctionTask:(Int, Array<Dynamic>) -> Void;
	var Arguments:Array<Dynamic>;
	var Key:Int;
};
