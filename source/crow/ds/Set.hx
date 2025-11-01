package crow.ds;

class Set<T>
{
	private var root:TreeNode<T>;
	private var _size:Int = 0;
	private var comparator:T->T->Int;

	/**
	 * The number of elements in the set.
	 */
	public var size(get, never):Int;

	/**
	 * Creates a new, empty Set.
	 */
	public function new()
	{
		root = null;
		this.comparator = Reflect.compare;
	}

	/**
	 * Adds a value to the set. If the value is already in the set, nothing changes.
	 * @param value The value to add.
	 * @return `true` if the value was added, `false` if it was already present.
	 */
	public function add(value:T):Bool
	{
		if (root == null)
		{
			root = new TreeNode(value, BLACK, null, null, null);
			_size++;
			return true;
		}

		var current = root;
		var parent:TreeNode<T> = null;

		while (current != null)
		{
			parent = current;
			final c = comparator(value, current.key);
			if (c < 0)
			{
				current = current.left;
			}
			else if (c > 0)
			{
				current = current.right;
			}
			else
			{
				return false; // Value already exists
			}
		}

		var newNode = new TreeNode(value, RED, parent, null, null);
		if (comparator(value, parent.key) < 0)
		{
			parent.left = newNode;
		}
		else
		{
			parent.right = newNode;
		}

		fixInsert(newNode);
		_size++;
		return true;
	}

	/**
	 * Removes a value from the set.
	 * @param value The value to remove.
	 * @return `true` if the value was present and has been removed, `false` otherwise.
	 */
	public function remove(value:T):Bool
	{
		var node = findNode(value);
		if (node == null)
		{
			return false;
		}

		deleteNode(node);
		_size--;
		return true;
	}

	/**
	 * Checks if a value exists in the set.
	 * @param value The value to check for.
	 * @return `true` if the value is in the set, `false` otherwise.
	 */
	public function contains(value:T):Bool
	{
		return findNode(value) != null;
	}

	/**
	 * Removes all values from the set, making it empty.
	 */
	public function clear():Void
	{
		root = null;
		_size = 0;
	}

	/**
	 * Returns an iterator over the values in the set.
	 * This allows the set to be used in `for` loops.
	 * @return An iterator for the elements in the set.
	 */
	public function iterator():Iterator<T>
	{
		var list = [];
		inOrderTraversal(root, list);
		return list.iterator();
	}

    /**
     * Converts the set to an array.
     * @return Array<T>
     */
    public function toArray():Array<T>
	{
		var list = [];
		inOrderTraversal(root, list);
		return list;
	}

    /**
     * Converts the set to a string.
     * @return String
     */
    public function toString():String
	{
		return toArray().toString();
	}

    /**
	 * Creates a new Set from an array of values.
     * If there are duplicate values from the array, the firstmost unique value
     * will only be added.
	 * @param array The array of values to add to the set.
	 * @return A new Set containing all unique values from the array.
	 */
    public static function fromArray<T>(array:Array<T>):Set<T>
	{
		var newSet = new Set<T>();
		for (value in array)
		{
			newSet.add(value);
		}
		return newSet;
	}

	private function get_size():Int
	{
		return _size;
	}

	// --- Red-Black Tree Internals ---

	private function findNode(value:T):TreeNode<T>
	{
		var current = root;
		while (current != null)
		{
			final c = comparator(value, current.key);
			if (c < 0)
			{
				current = current.left;
			}
			else if (c > 0)
			{
				current = current.right;
			}
			else
			{
				return current;
			}
		}
		return null;
	}

	private function inOrderTraversal(node:TreeNode<T>, list:Array<T>)
	{
		if (node != null)
		{
			inOrderTraversal(node.left, list);
			list.push(node.key);
			inOrderTraversal(node.right, list);
		}
	}

	private function rotateLeft(node:TreeNode<T>)
	{
		var rightChild = node.right;
		node.right = rightChild.left;
		if (rightChild.left != null)
		{
			rightChild.left.parent = node;
		}
		rightChild.parent = node.parent;
		if (node.parent == null)
		{
			root = rightChild;
		}
		else if (node == node.parent.left)
		{
			node.parent.left = rightChild;
		}
		else
		{
			node.parent.right = rightChild;
		}
		rightChild.left = node;
		node.parent = rightChild;
	}

	private function rotateRight(node:TreeNode<T>)
	{
		var leftChild = node.left;
		node.left = leftChild.right;
		if (leftChild.right != null)
		{
			leftChild.right.parent = node;
		}
		leftChild.parent = node.parent;
		if (node.parent == null)
		{
			root = leftChild;
		}
		else if (node == node.parent.right)
		{
			node.parent.right = leftChild;
		}
		else
		{
			node.parent.left = leftChild;
		}
		leftChild.right = node;
		node.parent = leftChild;
	}

	private function fixInsert(node:TreeNode<T>)
	{
		var current = node;
		while (current.parent != null && current.parent.color == RED)
		{
			var parent = current.parent;
			var grandParent = parent.parent;

			if (parent == grandParent.left)
			{
				var uncle = grandParent.right;
				if (uncle != null && uncle.color == RED)
				{
					parent.color = BLACK;
					uncle.color = BLACK;
					grandParent.color = RED;
					current = grandParent;
				}
				else
				{
					if (current == parent.right)
					{
						current = parent;
						rotateLeft(current);
						parent = current.parent; // update parent after rotation
					}
					parent.color = BLACK;
					grandParent.color = RED;
					rotateRight(grandParent);
				}
			}
			else
			{
				var uncle = grandParent.left;
				if (uncle != null && uncle.color == RED)
				{
					parent.color = BLACK;
					uncle.color = BLACK;
					grandParent.color = RED;
					current = grandParent;
				}
				else
				{
					if (current == parent.left)
					{
						current = parent;
						rotateRight(current);
						parent = current.parent; // update parent after rotation
					}
					parent.color = BLACK;
					grandParent.color = RED;
					rotateLeft(grandParent);
				}
			}
		}
		root.color = BLACK;
	}

	private function deleteNode(node:TreeNode<T>)
	{
		var y = node;
		var yOriginalColor = y.color;
		var x:TreeNode<T>;

		if (node.left == null)
		{
			x = node.right;
			transplant(node, node.right);
		}
		else if (node.right == null)
		{
			x = node.left;
			transplant(node, node.left);
		}
		else
		{
			y = minimum(node.right);
			yOriginalColor = y.color;
			x = y.right;
			if (y.parent == node)
			{
				if (x != null)
					x.parent = y;
			}
			else
			{
				transplant(y, y.right);
				y.right = node.right;
				y.right.parent = y;
			}
			transplant(node, y);
			y.left = node.left;
			y.left.parent = y;
			y.color = node.color;
		}

		if (yOriginalColor == BLACK)
		{
			fixDelete(x);
		}
	}

	private function fixDelete(node:TreeNode<T>)
	{
		var current = node;
		while (current != root && (current == null || current.color == BLACK))
		{
			if (current == current.parent.left)
			{
				var sibling = current.parent.right;
				if (sibling.color == RED)
				{
					sibling.color = BLACK;
					current.parent.color = RED;
					rotateLeft(current.parent);
					sibling = current.parent.right;
				}
				if ((sibling.left == null || sibling.left.color == BLACK) && (sibling.right == null || sibling.right.color == BLACK))
				{
					sibling.color = RED;
					current = current.parent;
				}
				else
				{
					if (sibling.right == null || sibling.right.color == BLACK)
					{
						if (sibling.left != null)
							sibling.left.color = BLACK;
						sibling.color = RED;
						rotateRight(sibling);
						sibling = current.parent.right;
					}
					sibling.color = current.parent.color;
					current.parent.color = BLACK;
					if (sibling.right != null)
						sibling.right.color = BLACK;
					rotateLeft(current.parent);
					current = root;
				}
			}
			else
			{ // Symmetric case
				var sibling = current.parent.left;
				if (sibling.color == RED)
				{
					sibling.color = BLACK;
					current.parent.color = RED;
					rotateRight(current.parent);
					sibling = current.parent.left;
				}
				if ((sibling.right == null || sibling.right.color == BLACK) && (sibling.left == null || sibling.left.color == BLACK))
				{
					sibling.color = RED;
					current = current.parent;
				}
				else
				{
					if (sibling.left == null || sibling.left.color == BLACK)
					{
						if (sibling.right != null)
							sibling.right.color = BLACK;
						sibling.color = RED;
						rotateLeft(sibling);
						sibling = current.parent.left;
					}
					sibling.color = current.parent.color;
					current.parent.color = BLACK;
					if (sibling.left != null)
						sibling.left.color = BLACK;
					rotateRight(current.parent);
					current = root;
				}
			}
		}
		if (current != null)
		{
			current.color = BLACK;
		}
	}

	private function transplant(u:TreeNode<T>, v:TreeNode<T>)
	{
		if (u.parent == null)
		{
			root = v;
		}
		else if (u == u.parent.left)
		{
			u.parent.left = v;
		}
		else
		{
			u.parent.right = v;
		}
		if (v != null)
		{
			v.parent = u.parent;
		}
	}

	private function minimum(node:TreeNode<T>):TreeNode<T>
	{
		var current = node;
		while (current.left != null)
		{
			current = current.left;
		}
		return current;
	}
}
