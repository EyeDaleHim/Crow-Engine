package crow.ds;

enum Color
{
	RED;
	BLACK;
}

class TreeNode<T>
{
	public var key:T;
	public var color:Color;
	public var parent:TreeNode<T>;
	public var left:TreeNode<T>;
	public var right:TreeNode<T>;

	public function new(key:T, color:Color, parent:TreeNode<T>, left:TreeNode<T>, right:TreeNode<T>)
	{
		this.key = key;
		this.color = color;
		this.parent = parent;
		this.left = left;
		this.right = right;
	}
}