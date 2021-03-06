(** Creation and manipulation of 2D shapes *)

(** Type of shapes *)
type t

(** Creates a convex polygon given a list of points.
  * points is this list of points,
  * origin is the origin of the polygon.
  * All coordinates are taken with respect to the top-left corner of the
  * shape. *)
val create_polygon :
  points        : OgamlMath.Vector2f.t list ->
  color         : Color.t ->
  ?origin       : OgamlMath.Vector2f.t ->
  ?position     : OgamlMath.Vector2f.t ->
  ?scale        : OgamlMath.Vector2f.t ->
  ?rotation     : float ->
  ?thickness    : float ->
  ?border_color : Color.t ->
  unit -> t

(** Creates a rectangle.
  * Its origin is positioned with respect to the top-left corner. *)
val create_rectangle :
  position      : OgamlMath.Vector2f.t ->
  size          : OgamlMath.Vector2f.t ->
  color         : Color.t ->
  ?origin       : OgamlMath.Vector2f.t ->
  ?scale        : OgamlMath.Vector2f.t ->
  ?rotation     : float ->
  ?thickness    : float ->
  ?border_color : Color.t ->
  unit -> t

(** Creates a regular polygon with a given number of vertices.
  * When this number is high, one can expect a circle. *)
val create_regular :
  position      : OgamlMath.Vector2f.t ->
  radius        : float ->
  amount        : int ->
  color         : Color.t ->
  ?origin       : OgamlMath.Vector2f.t ->
  ?scale        : OgamlMath.Vector2f.t ->
  ?rotation     : float ->
  ?thickness    : float ->
  ?border_color : Color.t ->
  unit -> t

(** Creates a line from $top$ (zero by default) to $tip$. *)
val create_line :
  thickness : float ->
  color     : Color.t ->
  ?top      : OgamlMath.Vector2f.t ->
  tip       : OgamlMath.Vector2f.t ->
  ?position : OgamlMath.Vector2f.t ->
  ?origin   : OgamlMath.Vector2f.t ->
  ?rotation : float ->
  unit -> t

(** Draws a shape. *)
val draw : 
    (module RenderTarget.T with type t = 'a) ->
    ?parameters:DrawParameter.t -> target:'a -> shape:t -> unit -> unit

val to_source : t -> VertexArray.SimpleVertex.T.s VertexArray.VertexSource.t -> unit

val map_to_source : t -> 
                    (VertexArray.SimpleVertex.T.s VertexArray.Vertex.t -> 'b VertexArray.Vertex.t) -> 
                    'b VertexArray.VertexSource.t -> unit


(** Sets the position of the origin in the window. *)
val set_position : t -> OgamlMath.Vector2f.t -> unit

(** Sets the position of the origin with respect to the top-left corner of the
  * shape. *)
val set_origin : t -> OgamlMath.Vector2f.t -> unit

(** Sets the angle of rotation of the shape. *)
val set_rotation : t -> float -> unit

(** Sets the scale of the shape. *)
val set_scale : t -> OgamlMath.Vector2f.t -> unit

(** Sets the thickness of the outline. *)
val set_thickness : t -> float -> unit

(** Sets the filling color of the shape. *)
val set_color : t -> Color.t -> unit

(** Sets the border color *)
val set_border_color : t -> Color.t -> unit

(** Translates the shape by the given vector. *)
val translate : t -> OgamlMath.Vector2f.t -> unit

(** Rotates the shape by the given angle. *)
val rotate : t -> float -> unit

(** Scales the shape. *)
val scale : t -> OgamlMath.Vector2f.t -> unit

(** Returns the position of the origin in window coordinates. *)
val position : t -> OgamlMath.Vector2f.t

(** Returns the position of the origin with respect to the first point of the
  * shape. *)
val origin : t -> OgamlMath.Vector2f.t

(** Returns the angle of rotation of the sprite. *)
val rotation : t -> float

(** Returns the scale of the shape. *)
val get_scale : t -> OgamlMath.Vector2f.t

(** Returns the thickness of the outline. *)
val thickness : t -> float

(** Returns the filling color of the shape. *)
val color : t -> Color.t

(** Returns the border color of the shape. *)
val border_color : t -> Color.t
