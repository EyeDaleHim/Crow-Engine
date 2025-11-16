package crow.ds;

import crow.ds.Nullable;

/**
    Represents a doubly linked list.
**/
class LinkedList<T> {
    public var first(default, null):Nullable<LinkedListNode<T>>;
    public var last(default, null):Nullable<LinkedListNode<T>>;
    public var length(default, null):Int;

    public function new(?iterable:Iterable<T>) {
        this.first = null;
        this.last = null;
        this.length = 0;

        if (iterable != null) {
            for (x in iterable) add(x);
        }
    }

    public function add(value:T):LinkedListNode<T> {
        final node = new LinkedListNode(this, value);

        if (length == 0) {
            first = Nullable.of(node);
            last = Nullable.of(node);
        } else {
            last.getUnsafe().append(node);
            last = Nullable.of(node);
        }
        length++;

        return node;
    }

    public function exists(node:LinkedListNode<T>):Bool {
        return node.list == this;
    }

    public function remove(node:LinkedListNode<T>):Bool {
        return if (node.list == this) {
            if (node == first) first = first.getUnsafe().next;
            if (node == last) last = last.getUnsafe().prev;
            node.remove();
            length--;
            true;
        } else {
            false;
        }
    }

    public function clear():Void {
        this.first = null;
        this.last = null;
        this.length = 0;
    }

    public function iterator():LinkedListIterator<T> {
        return new LinkedListIterator(first);
    }

    public inline function iter(fn:(value:T) -> Void):Void {
        var current = first;
        while (current.nonEmpty()) {
            final node = current.getUnsafe();
            fn(node.value);
            current = node.next;
        }
    }
}

class LinkedListNode<T> {
    @:allow(crow.ds.LinkedList)
    var list(default, null):Nullable<LinkedList<T>>;

    public final value:T;
    public var prev(default, null):Nullable<LinkedListNode<T>>;
    public var next(default, null):Nullable<LinkedListNode<T>>;

    @:allow(crow.ds.LinkedList)
    function new(list:LinkedList<T>, value:T) {
        this.list = Nullable.of(list);
        this.value = value;
        this.prev = null;
        this.next = null;
    }

    @:allow(crow.ds.LinkedList)
    function append(node:LinkedListNode<T>):Void {
        this.next = Nullable.of(node);
        node.prev = Nullable.of(this);
    }

    @:allow(crow.ds.LinkedList)
    function remove():Void {
        final prev = this.prev;
        final next = this.next;

        prev.iter(x -> x.next = next);
        next.iter(x -> x.prev = prev);

        this.list = null;
        this.prev = null;
        this.next = null;
    }
}

class LinkedListIterator<T> {
    var current:Nullable<LinkedListNode<T>>;

    @:allow(crow.ds.LinkedList)
    function new(firstNode:Nullable<LinkedListNode<T>>) {
        this.current = firstNode;
    }

    public inline function hasNext():Bool {
        return current.nonEmpty();
    }

    public inline function next():T {
        final node = current.getUnsafe();
        current = node.next;
        return node.value;
    }
}