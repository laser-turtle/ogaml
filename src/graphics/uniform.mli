(** This module provides a way to easily construct
  * a list of uniforms to be passed to a program
  * when drawing 
**)

(** Raised when trying to bind a non-provided uniform *)
exception Unknown_uniform of string

(** Raised when trying to bind a uniform with the wrong type *)
exception Invalid_uniform of string

(** Type of a set of uniforms *)
type t

(** An empty uniform set *)
val empty : t

(** Adds a vector3f to a uniform structure *)
val vector3f : string -> OgamlMath.Vector3f.t -> t -> t

(** Adds a vector2f to a uniform structure *)
val vector2f : string -> OgamlMath.Vector2f.t -> t -> t

(** Adds a vector3i to a uniform structure *)
val vector3i : string -> OgamlMath.Vector3i.t -> t -> t

(** Adds a vector2i to a uniform structure *)
val vector2i : string -> OgamlMath.Vector2i.t -> t -> t

(** Adds an integer to a uniform structure *)
val int : string -> int -> t -> t

(** Adds a float to a uniform structure *)
val float : string -> float -> t -> t

(** Adds a matrix3D to a uniform structure *)
val matrix3D : string -> OgamlMath.Matrix3D.t -> t -> t

(** Adds a matrix2D to a uniform structure *)
val matrix2D : string -> OgamlMath.Matrix2D.t -> t -> t

(** Adds a color to a uniform structure *)
val color : string -> Color.t -> t -> t

(** Adds a 2D texture to a uniform structure *)
val texture2D : string -> ?tex_unit:int -> Texture.Texture2D.t -> t -> t

(** Adds the texture of a font to a uniform structure *)
val font : string -> ?tex_unit:int -> Font.t -> int -> t -> t


module LL : sig

  (** Binds a value to a program uniform *)
  val bind : State.t -> t -> Program.Uniform.t -> unit

end
