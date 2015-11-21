open OgamlMath

type shape_vals = {
  mutable points   : Vector2f.t list ; (* Maybe something more generic *)
  mutable position : Vector2f.t ;
  mutable origin   : Vector2f.t ;
  mutable rotation : float ;
  mutable scale    : Vector2f.t ; (* ignored for the moment *)
  mutable color    : Color.t
}

type t = {
  mutable vertices : VertexArray.static VertexArray.t ;
  shape_vals       : shape_vals
}

(* Applys transformations to a point
 * corner is the first point (typically top-left corner) *)
let apply_transformations position origin rotation corner point =
  (* Position offset *)
  Vector2f.({
    x = point.x +. position.x -. origin.x -. corner.x ;
    y = point.y +. position.y -. origin.y -. corner.y
  })
  |> fun point ->
  (* Rotation *)
  Vector2f.({
    x = cos(rotation) *. (point.x-.origin.x) -.
        sin(rotation) *. (point.y-.origin.y) +. origin.x ;
    y = sin(rotation) *. (point.x-.origin.x) +.
        cos(rotation) *. (point.y-.origin.y) +. origin.y
  })

let rec foreachtwo f res = function
  | a :: b :: r -> foreachtwo f (f res a b) (b :: r)
  | _ -> res

(* Turns a shape_vals to a VertexArray *)
let vertices_of_vals vals =
  match vals.points with
  | [] -> VertexArray.static VertexArray.Source.(empty ~position:"position"
                                                       ~color:"color"
                                                       ~size:0 ())
  | corner :: _ ->
    List.map
      (apply_transformations vals.position vals.origin vals.rotation corner)
      vals.points
    |> List.map Vector3f.lift
    |> List.map (fun v ->
      VertexArray.Vertex.create ~position:v ~color:vals.color ()
    )
    |> function
    | [] -> assert false
    | edge :: vertices ->
      foreachtwo
        (fun source a b -> VertexArray.Source.(source << edge << a << b))
        VertexArray.Source.(empty ~position:"position"
                                  ~color:"color"
                                  ~size:(3 * (List.length vertices)) ())
        vertices
    |> VertexArray.static

let create_polygon ~points
                   ~color
                   ?origin:(origin=Vector2f.zero)
                   ?position:(position=Vector2i.zero)
                   ?scale:(scale=Vector2f.zero)
                   ?rotation:(rotation=0.) () =
  let points = List.map Vector2f.from_int points in
  let position = Vector2f.from_int position in
  let vals = {
    points   = points ;
    position = position ;
    origin   = origin ;
    rotation = rotation ;
    scale    = scale ;
    color    = color
  }
  in
  {
    vertices   = vertices_of_vals vals ;
    shape_vals = vals
  }

let create_rectangle ~position
                     ~size
                     ~color
                     ?origin:(origin=Vector2f.zero)
                     ?scale:(scale=Vector2f.zero)
                     ?rotation:(rotation=0.) () =
  let w = Vector2i.({ x = size.x ; y = 0 })
  and h = Vector2i.({ x = 0 ; y = size.y }) in
  create_polygon ~points:Vector2i.([zero ; w ; size ; h])
                 ~color
                 ~origin
                 ~position
                 ~scale
                 ~rotation ()

let get_vertex_array shape = shape.vertices
