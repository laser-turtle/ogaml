
type t = {x : float; y : float; z : float; width : float; height : float; depth : float}

val create : Vector3f.t -> Vector3f.t -> t

val one : t

val corner : t -> Vector3f.t

val position : t -> Vector3f.t

val size : t -> Vector3f.t

val center : t -> Vector3f.t

val volume : t -> float

val scale : t -> Vector3f.t -> t

val translate : t -> Vector3f.t -> t

val from_int : IntBox.t -> t

val floor : t -> IntBox.t

val intersect : t -> t -> bool

val contains : t -> Vector3f.t -> bool

