
type t = {x : int; y : int; z : int; width : int; height : int; depth : int}

let create v1 v2 = {
  x = v1.Vector3i.x;
  y = v1.Vector3i.y;
  z = v1.Vector3i.z;
  width  = v2.Vector3i.x;
  height = v2.Vector3i.y;
  depth  = v2.Vector3i.z
}

let one = {
  x = 0; y = 0; z = 0;
  width = 0; height = 0; depth = 0
}

let corner t = {
  Vector3i.x = t.x;
  Vector3i.y = t.y;
  Vector3i.z = t.z;
}

let position = corner

let size t = {
  Vector3i.x = t.width;
  Vector3i.y = t.height;
  Vector3i.z = t.depth;
}

let center t = {
  Vector3f.x = (float_of_int (t.x + t.width))  /. 2.;
  Vector3f.y = (float_of_int (t.y + t.height)) /. 2.;
  Vector3f.z = (float_of_int (t.z + t.depth))  /. 2.
}

let volume t = t.width * t.height * t.depth

let scale t v = {t with
  width  = t.width  * v.Vector3i.x;
  height = t.height * v.Vector3i.y;
  depth  = t.depth  * v.Vector3i.z;
}

let translate t v = {t with
  x = t.x + v.Vector3i.x;
  y = t.y + v.Vector3i.y;
  z = t.z + v.Vector3i.z;
}

let intersect t1 t2 = 
  not ((t1.x + t1.width  < t2.x) ||
       (t2.x + t2.width  < t1.x) ||
       (t1.y + t1.height < t2.y) ||
       (t2.y + t2.height < t1.y) ||
       (t1.z + t1.depth  < t2.z) ||
       (t2.z + t2.depth  < t1.z))

let contains t pt = 
  pt.Vector3i.x >= t.x &&
  pt.Vector3i.y >= t.y &&
  pt.Vector3i.z >= t.z &&
  pt.Vector3i.x <= t.x + t.width  &&
  pt.Vector3i.y <= t.y + t.height &&
  pt.Vector3i.z <= t.z + t.depth

let loop t f = 
  for i = t.x to t.x + t.width - 1 do
    for j = t.y to t.y + t.height - 1 do
      for k = t.z to t.z + t.depth - 1 do
        f i j k
      done;
    done;
  done
