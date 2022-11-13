package backend.query;

class ControlQueries
{
	public var currentQueries:Array<ControlQuery> = [];

	public function new() {}

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
					currentQuery.Function(currentQuery.Key);
				}
				catch (e) {}
			}

			currentQueries.splice(currentQuery, 1);
		}
	}
}

typedef ControlQuery =
{
	var Function:Int->Void;
	var Key:Int;
};
