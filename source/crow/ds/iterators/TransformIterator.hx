package crow.ds.iterators;

@:noCompletion
class TransformIterator<T, U> {
    final iterator:Iterator<T>;
    final transformer:(value:T) -> U;

    public inline function new(iterator:Iterator<T>, transformer:(value:T) -> U) {
        this.iterator = iterator;
        this.transformer = transformer;
    }

    public inline function hasNext():Bool {
        return iterator.hasNext();
    }

    public inline function next():U {
        return transformer(iterator.next());
    }
}