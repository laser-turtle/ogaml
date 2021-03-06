
exception Matrix3D_exception of string

type t = (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t

(* Utils, not exposed *)
let create () = Bigarray.Array1.create Bigarray.float32 Bigarray.c_layout 16

let get i j m = m.{i + j*4} (* column major order *)

let set i j m v = m.{i + j*4} <- v

let to_bigarray m = m

let zero () = 
  let m = create () in
  for i = 0 to 3 do
    for j = 0 to 3 do
      set i j m 0.
    done;
  done; m

let identity () = 
  let m = zero () in
  for i = 0 to 3 do
    set i i m 1.
  done; m

let to_string m = 
  let s = ref "" in
  for i = 0 to 3 do
    s := Printf.sprintf "%s|" !s;
    for j = 0 to 2 do
      s := Printf.sprintf "%s%f; " !s (get i j m) ;
    done;
    s := Printf.sprintf "%s%f|\n" !s (get i 3 m);
  done;
  !s

let translation v = 
  let open Vector3f in
  let m = identity () in
  set 0 3 m v.x;
  set 1 3 m v.y;
  set 2 3 m v.z;
  m

let scaling v = 
  let m = zero () in
  let open Vector3f in
  set 0 0 m v.x;
  set 1 1 m v.y;
  set 2 2 m v.z;
  set 3 3 m 1.; 
  m

let rotation v t = 
  let open Vector3f in
  let m = identity () in
  let c = cos t in
  let ic = 1. -. c in
  let s = sin t in
  let vn = 
    try normalize v 
    with Vector3f_exception _ -> raise (Matrix3D_exception "Cannot get rotation matrix : zero axis")
  in
  let (x,y,z) = (vn.x, vn.y, vn.z) in
  set 0 0 m (x *. x +. (1. -. x *. x) *. c);
  set 0 1 m (ic *. x *. y -. z *. s);
  set 0 2 m (ic *. x *. z +. y *. s);
  set 1 0 m (ic *. x *. y +. z *. s);
  set 1 1 m (y *. y +. (1. -. y *. y) *. c);
  set 1 2 m (ic *. y *. z -. x *. s);
  set 2 0 m (ic *. x *. z -. y *. s);
  set 2 1 m (ic *. y *. z +. x *. s);
  set 2 2 m (z *. z +. (1. -. z *. z) *. c);
  m

let product m1 m2 = 
  let m = create () in
  m.{0}  <- m1.{0} *. m2.{0}  +. m1.{4} *. m2.{1}  +. m1.{8}  *. m2.{2}  +. m1.{12} *. m2.{3};
  m.{1}  <- m1.{1} *. m2.{0}  +. m1.{5} *. m2.{1}  +. m1.{9}  *. m2.{2}  +. m1.{13} *. m2.{3};
  m.{2}  <- m1.{2} *. m2.{0}  +. m1.{6} *. m2.{1}  +. m1.{10} *. m2.{2}  +. m1.{14} *. m2.{3};
  m.{3}  <- m1.{3} *. m2.{0}  +. m1.{7} *. m2.{1}  +. m1.{11} *. m2.{2}  +. m1.{15} *. m2.{3};
  m.{4}  <- m1.{0} *. m2.{4}  +. m1.{4} *. m2.{5}  +. m1.{8}  *. m2.{6}  +. m1.{12} *. m2.{7};
  m.{5}  <- m1.{1} *. m2.{4}  +. m1.{5} *. m2.{5}  +. m1.{9}  *. m2.{6}  +. m1.{13} *. m2.{7};
  m.{6}  <- m1.{2} *. m2.{4}  +. m1.{6} *. m2.{5}  +. m1.{10} *. m2.{6}  +. m1.{14} *. m2.{7};
  m.{7}  <- m1.{3} *. m2.{4}  +. m1.{7} *. m2.{5}  +. m1.{11} *. m2.{6}  +. m1.{15} *. m2.{7};
  m.{8}  <- m1.{0} *. m2.{8}  +. m1.{4} *. m2.{9}  +. m1.{8}  *. m2.{10} +. m1.{12} *. m2.{11};
  m.{9}  <- m1.{1} *. m2.{8}  +. m1.{5} *. m2.{9}  +. m1.{9}  *. m2.{10} +. m1.{13} *. m2.{11};
  m.{10} <- m1.{2} *. m2.{8}  +. m1.{6} *. m2.{9}  +. m1.{10} *. m2.{10} +. m1.{14} *. m2.{11};
  m.{11} <- m1.{3} *. m2.{8}  +. m1.{7} *. m2.{9}  +. m1.{11} *. m2.{10} +. m1.{15} *. m2.{11};
  m.{12} <- m1.{0} *. m2.{12} +. m1.{4} *. m2.{13} +. m1.{8}  *. m2.{14} +. m1.{12} *. m2.{15};
  m.{13} <- m1.{1} *. m2.{12} +. m1.{5} *. m2.{13} +. m1.{9}  *. m2.{14} +. m1.{13} *. m2.{15};
  m.{14} <- m1.{2} *. m2.{12} +. m1.{6} *. m2.{13} +. m1.{10} *. m2.{14} +. m1.{14} *. m2.{15};
  m.{15} <- m1.{3} *. m2.{12} +. m1.{7} *. m2.{13} +. m1.{11} *. m2.{14} +. m1.{15} *. m2.{15};
  m

let transpose m' = 
  let m = create () in
  m.{0}  <- m'.{0}; m.{1}  <- m'.{4}; m.{2}  <- m'.{8} ; m.{3}  <- m'.{12};
  m.{4}  <- m'.{1}; m.{5}  <- m'.{5}; m.{6}  <- m'.{9} ; m.{7}  <- m'.{13};
  m.{8}  <- m'.{2}; m.{9}  <- m'.{6}; m.{10} <- m'.{10}; m.{11} <- m'.{14};
  m.{12} <- m'.{3}; m.{13} <- m'.{7}; m.{14} <- m'.{11}; m.{15} <- m'.{15};
  m

let translate v m = product (translation v) m

let scale v m = product (scaling v) m

let rotate v t m = product (rotation v t) m

let times m ?perspective:(p = true) v = 
  let open Vector3f in
  if p then 
    {
      x = v.x *. m.{0} +. v.y *. m.{4} +. v.z *. m.{8}  +. m.{12};
      y = v.x *. m.{1} +. v.y *. m.{5} +. v.z *. m.{9}  +. m.{13};
      z = v.x *. m.{2} +. v.y *. m.{6} +. v.z *. m.{10} +. m.{14}
    }
  else
    {
      x = v.x *. m.{0} +. v.y *. m.{4} +. v.z *. m.{8} ;
      y = v.x *. m.{1} +. v.y *. m.{5} +. v.z *. m.{9} ;
      z = v.x *. m.{2} +. v.y *. m.{6} +. v.z *. m.{10}
    }   

let from_quaternion q = 
  let mat = zero () in Quaternion.(
  set 0 0 mat (1. -. 2. *. q.j *. q.j -. 2. *. q.k *. q.k);
  set 1 0 mat (2. *. q.i *. q.j -. 2. *. q.r *. q.k);
  set 2 0 mat (2. *. q.i *. q.k +. 2. *. q.r *. q.j);
  set 0 1 mat (2. *. q.i *. q.j +. 2. *. q.r *. q.k);
  set 1 1 mat (1. -. 2. *. q.i *. q.i -. 2. *. q.k *. q.k);
  set 2 1 mat (2. *. q.j *. q.k -. 2. *. q.r *. q.i);
  set 0 2 mat (2. *. q.i *. q.k -. 2. *. q.r *. q.j);
  set 1 2 mat (2. *. q.j *. q.k +. 2. *. q.r *. q.i);
  set 2 2 mat (1. -. 2. *. q.i *. q.i -. 2. *. q.j *. q.j);
  set 3 3 mat 1.; mat)

let look_at ~from ~at ~up = 
  let open Vector3f in
  let dir = direction from at in
  let up = 
    try normalize up 
    with Vector3f_exception _ -> raise (Matrix3D_exception "Cannot get look_at matrix : zero up direction")
  in
  let right = 
    try normalize (cross dir up) 
    with Vector3f_exception _ -> raise (Matrix3D_exception "Cannot get look_at matrix : up and (at - from) are parallel or zero")
  in
  let up = cross right dir in
  let m = identity () in
  set 0 0 m (right.x);
  set 0 1 m (right.y);
  set 0 2 m (right.z);
  set 1 0 m (up.x);
  set 1 1 m (up.y);
  set 1 2 m (up.z);
  set 2 0 m (-. dir.x);
  set 2 1 m (-. dir.y);
  set 2 2 m (-. dir.z);
  set 0 3 m (-. dot from right);
  set 1 3 m (-. dot from up);
  set 2 3 m (dot from dir);
  m

let ilook_at ~from ~at ~up = 
  let mat_prod = product in
  let open Vector3f in
  let dir = direction from at in
  let up = 
    try normalize up 
    with Vector3f_exception _ -> raise (Matrix3D_exception "Cannot get look_at matrix : zero up direction")
  in
  let right = 
    try normalize (cross dir up) 
    with Vector3f_exception _ -> raise (Matrix3D_exception "Cannot get look_at matrix : up and (at - from) are parallel or zero")
  in
  let up = cross right dir in
  let trl = translation from in
  let rot = identity () in
  set 0 0 rot (right.x);
  set 1 0 rot (right.y);
  set 2 0 rot (right.z);
  set 0 1 rot (up.x);
  set 1 1 rot (up.y);
  set 2 1 rot (up.z);
  set 0 2 rot (-. dir.x);
  set 1 2 rot (-. dir.y);
  set 2 2 rot (-. dir.z);
  mat_prod trl rot

let look_at_eulerian ~from ~theta ~phi =
  translation (Vector3f.prop (-1.) from)
  |> product
    (from_quaternion
      (Quaternion.times
        (Quaternion.rotation Vector3f.unit_y theta)
        (Quaternion.rotation Vector3f.unit_x phi)
      ))

let ilook_at_eulerian ~from ~theta ~phi =
  from_quaternion
    (Quaternion.times
      (Quaternion.(inverse (rotation Vector3f.unit_x phi)))
      (Quaternion.(inverse (rotation Vector3f.unit_y theta))))
  |> product (translation from)

let orthographic ~right ~left ~near ~far ~top ~bottom =
  let m = identity () in
  if right = left   then raise (Matrix3D_exception "Cannot get orthographic matrix : right = left");
  if near  = far    then raise (Matrix3D_exception "Cannot get orthographic matrix : near = far");
  if top   = bottom then raise (Matrix3D_exception "Cannot get orthographic matrix : top = bottom");
  set 0 0 m (2. /. (right -. left));
  set 1 1 m (2. /. (top -. bottom));
  set 2 2 m (2. /. (near -. far));
  set 0 3 m ((right +. left) /. (left -. right));
  set 1 3 m ((top +. bottom) /. (bottom -. top));
  set 2 3 m ((far +. near) /. (near -. far));
  m

let iorthographic ~right ~left ~near ~far ~top ~bottom =
  let m = identity () in
  set 0 0 m ((right -. left) /. 2.);
  set 1 1 m ((top -. bottom) /. 2.);
  set 2 2 m ((near -. far) /. 2.);
  set 0 3 m ((right +. left) /. 2.);
  set 1 3 m ((top +. bottom) /. 2.);
  set 2 3 m (-.(far +. near) /. 2.);
  m

let perspective ~near ~far ~width ~height ~fov =
  if near  = far then raise (Matrix3D_exception "Cannot get perspective matrix : near = far");
  let aspect = width /. height in
  let top = (tan (fov /. 2.)) *. near in
  let right = top *. aspect in 
  let m = zero () in
  set 0 0 m (near /. right);
  set 1 1 m (near /. top);
  set 2 2 m ((far +. near) /. (near -. far));
  set 2 3 m (2. *. far *. near /. (near -. far));
  set 3 2 m (-1.);
  m

let iperspective ~near ~far ~width ~height ~fov =
  let aspect = width /. height in
  let top = (tan (fov /. 2.)) *. near in
  let right = top *. aspect in 
  let m = zero () in
  set 0 0 m (right /. near);
  set 1 1 m (top /. near);
  set 3 3 m ((far +. near) /. (2. *. far *. near));
  set 2 3 m (-1.);
  set 3 2 m ((near -. far) /. (2. *. far *. near));
  m



