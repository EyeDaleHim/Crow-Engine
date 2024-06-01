package system.data;

typedef FloatPointData = PointData<Float>;
typedef IntPointData = PointData<Int>;
typedef AxePointData = PointData<Bool>;

typedef PointData<T> = {
	var ?x:T;
	var ?y:T;
}