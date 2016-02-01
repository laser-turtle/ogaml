
(** Interpolation between multiple values *)
module Interpolator : sig 

  (** This module defines interpolators between two values.
    *
    * An interpolator between value v0 and v1 is a function
    * f such that f(0) = v0, f(1) = v1.
    *
    *)

  (** Type of an interpolator returning type 'a *)
  type 'a t

  (** Raised when an error occurs during the creation of an interpolator *)
  exception Invalid_interpolator of string


  (*** Accessors and modifiers *)

  (** Those functions provide a way to modify the behaviour
    * of interpolators.
    *
    * Unless otherwise specified, the modifiers applied to 
    * an interpolator are kept by all subsequent operations. 
    * This means that, for example, passing a time-based 
    * interpolator to $map$ will return a new time-based 
    * interpolator. *)

  (** $get ip t$ returns the value of the interpolator $ip$ 
    * at time $t$ in [0;1] *)
  val get : 'a t -> float -> 'a

  (** $current ip$ returns the current value of a time-based
    * interpolator (see function start).
    *
    * If $ip$ is not time-based then the result is $ip(0)$. *)
  val current : 'a t -> 'a

  (** $start ip t dt$ returns a new time-based interpolator 
    * $tip$ such that :
    *
    * $current tip$ = $ip(0)$ at time $t$
    *
    * $current tip$ = $ip(1)$ at time $t + dt$
    *
    * $t$ and $dt$ are given in seconds. 
    * $t = Unix.gettimeofday()$ means that $tip$ starts immediately.
    *
    * If $dt = 0$ then $current$ will always return $ip(0)$
    *
    * The result of $get$ on the $tip$ is left unchanged. *)
  val start : 'a t -> float -> float -> 'a t

  (** $repeat ip$ returns a repeating interpolator $lip$ from $ip$ such that
    * $lip(x)$ = $ip(x)$ for $x$ in [0;1] and $lip$ is 1-periodic. *)
  val repeat : 'a t -> 'a t

  (** $loop ip$ returns a repeating interpolator $lip$ from $ip$ such that :
    *
    * $lip(x)$ = $ip(x)$ for $x$ in [0;1] 
    *
    * $lip(x)$ = $ip(2-x)$ for $x$ in [1;2]
    *
    * $lip(x)$ is 2-periodic *)
  val loop : 'a t -> 'a t


  (*** Constructors *)

  (** Those functions provide a way to construct various (and even
    * user-defined) interpolators.
    *
    * Unless otherwise specified, parameters are clamped to
    * [0;1], that is ip(x) for x < 0 equals ip(0) and ip(x) for
    * x > 1 equals ip(1) 
    *
    * Most constructors require a list of points of the form $(dt, v)$
    * such that the created interpolator will take the value $v$
    * at time $dt$.
    *
    * The $cst_*$ variants create constant-speed iterators 
    * so the $dt$ parameter is not required. *)

  (** $custom f$ returns a custom interpolator that coincides with  
    * the function $f$ on [0;1] and equals f(0) or f(1) elsewhere. *)
  val custom : (float -> 'a) -> 'a t

  (** $copy f$ returns a custom interpolator that coincides with  
    * the function $f$ everywhere *)
  val copy : (float -> 'a) -> 'a t

  (** Returns a constant interpolator *)
  val constant : float -> float t

  (** $linear start steps end$ creates a linear interpolator
    * going from $start$ to $end$ passing through each point
    * $(dt, pos)$ of $steps$ at time $dt$ *)
  val linear : float -> (float * float) list -> float -> float t

  (** $cst_linear start steps end$ creates a linear interpolator 
    * going from $start$ to $end$ passing through each point 
    * of $steps$ at constant speed *)
  val cst_linear : float -> float list -> float -> float t

  (** $cubic (start, sm) steps (end, em)$ creates a cubic spline interpolator
    * going from $start$ with tangent $sm$ to $end$ with tangeant $em$
    * passing through each point $(dt, pos)$ of $steps$ at time $dt$ *)
  val cubic : (float * float) -> (float * float) list -> (float * float) -> float t

  (** $cubic (start, sm) steps (end, em)$ creates a cubic spline interpolator
    * going from $start$ with tangent $sm$ to $end$ with tangeant $em$
    * passing through each point of $steps$ at constant speed *)
  val cst_cubic : (float * float) -> float list -> (float * float) -> float t


  (*** Composition *)

  (** $compose ip1 ip2$ returns a new interpolator that takes the
    * values of $ip2$ but using the values of $ip1$ as parameter
    *
    * The new interpolator will have the modifiers of $ip1$ *)
  val compose : float t -> 'a t -> 'a t

  (** $map ip f$ returns a new interpolator that takes
    * the value of $ip$ and passes it to $f$. *)
  val map : 'a t -> ('a -> 'b) -> 'b t

  (** $map_right$ is an alias for $map$ *)
  val map_right : 'a t -> ('a -> 'b) -> 'b t

  (** $map_left f ip$ returns a function $g$ such that 
    * $g(x) = ip(f(x))$ *)
  val map_left : ('a -> float) -> 'b t -> ('a -> 'b)

  (** Returns a pair-interpolator from a pair of interpolators.
    * 
    * The new interpolator will not have any modifiers. *)
  val pair : 'a t -> 'b t -> ('a * 'b) t

  (** Returns a list-interpolator from a list of interpolators.
    *
    * The new iterator will not have any modifiers. *)
  val collapse : ('a t) list -> ('a list) t

  (** Returns a vector3f interpolator from three float interpolators. 
    *
    * The new iterator will not have any modifiers. *)
  val vector3f : float t -> float t -> float t -> OgamlMath.Vector3f.t t

  (** Returns a vector2f interpolator from two float interpolators. 
    *
    * The new iterator will not have any modifiers. *)
  val vector2f : float t -> float t -> OgamlMath.Vector2f.t t

end


(** Priority queue data structure *)
module PriorityQueue : sig

  (** This module provides a functor for creating priority queues *)

  (** Priorities used by a queue *)
  module type Priority = sig

    (** This module encapsulates the priorities used by a queue *)

    (** Type of a priority *)
    type t

    (** Comparison of priorities *)
    val compare : t -> t -> int

  end


  (** Type of PriorityQueue.Make *)
  module type Q = sig

    (** This module provides a basic implementation of priority queues *)

    (** Raised when a queue is empty *)
    exception Empty

    (** Priorities used by the queue *)
    type priority

    (** Type of a queue storing elements of type $'a$ *)
    type 'a t

    (** Empty queue *)
    val empty : 'a t

    (** Returns $true$ iff the queue is empty *)
    val is_empty : 'a t -> bool

    (** Singleton queue *)
    val singleton : priority -> 'a -> 'a t

    (** Merges two queues *)
    val merge : 'a t -> 'a t -> 'a t

    (** Inserts an element with a given priority *)
    val insert : 'a t -> priority -> 'a -> 'a t

    (** Returns the top element of a queue
      *
      * Raises $Empty$ if the queue is empty *)
    val top : 'a t -> 'a

    (** Removes the top element of a queue
      *
      * Raises $Empty$ if the queue is empty *)
    val pop : 'a t -> 'a t

    (** Returns the top element of a queue and the queue without its
      * first element
      *
      * Raises $Empty$ if the queue is empty *)
    val extract : 'a t -> ('a * 'a t)

  end


  (** Priority queue functor *)
  module Make : functor (P : Priority) -> Q with type priority = P.t

end


(** Graph manipulation *)
module Graph : sig

  (** This module provides a functor to create graphs with arbitrary vertices *)

  (** Vertex representation *)
  module type Vertex = sig

    (** This module encapsulates the representation of a vertex *)

    (** Type of a vertex *)
    type t

    (** Comparison of vertices (mainly used for equality checks) *)
    val compare : t -> t -> int

  end


  (** Output of Graph.Make *)
  module type G = sig

    (** Type of a graph *)
    type t

    (** Type of a vertex *)
    type vertex

    (** Empty graph *)
    val empty : t

    (** Returns the number of vertices of a graph *)
    val vertices : t -> int

    (** Returns the number of edges of a graph *)
    val edges : t -> int

    (** Iterates through all the vertices of a graph *)
    val iter_vertices : t -> (vertex -> unit) -> unit

    (** Folds through all the vertices of a graph *)
    val fold_vertices : t -> (vertex -> 'a -> 'a) -> 'a -> 'a

    (** Iterates through all the edges of a graph *)
    val iter_edges : t -> (vertex -> vertex -> unit) -> unit

    (** Adds a vertex to a graph *)
    val add_vertex : t -> vertex -> t

    (** Adds an edge with an optional cost to a graph (adds the vertices if needed) *)
    val add_edge : t -> ?cost:float -> vertex -> vertex -> t

    (** Tail-call alias for $add_edge$ (for easy composition) *)
    val add : ?cost:float -> vertex -> vertex -> t -> t

    (** Removes an edge from a graph (does nothing if the edge does not exist) *)
    val remove_edge : t -> vertex -> vertex -> t

    (** Removes a vertex from a graph (and all of its adjacent edges) *)
    val remove_vertex : t -> vertex -> t

    (** Returns all the neighbours of a vertex *)
    val neighbours : t -> vertex -> vertex list

    (** Merges two graphs *)
    val merge : t -> t -> t

    (** $dfs g s f$ iterates $f$ through all the vertices of $g$, 
      * starting from $s$ using a dfs *)
    val dfs : t -> vertex -> (vertex -> unit) -> unit

    (** $bfs g s f$ iterates $f$ through all the vertices of $g$, 
      * starting from $s$ using a bfs *)
    val bfs : t -> vertex -> (vertex -> unit) -> unit

    (** $dijkstra g v1 v2$ runs Dijkstra's algorithm on $g$ from $v1$ to $v2$
      * and returns the minimal path as well as the distance between $v1$ and $v2$,
      * or $None$ if $v1$ and $v2$ are not connected *)
    val dijkstra : t -> vertex -> vertex -> (float * vertex list) option

    (** $astar g v1 v2 f$ runs the A* algorithm on $g$ from $v1$ to $v2$
      * with the heuristic $f$ and returns the minimal path as well as the 
      * distance between $v1$ and $v2$, or $None$ if $v1$ and $v2$ are not connected *)
    val astar : t -> vertex -> vertex -> (vertex -> float) -> (float * vertex list) option

  end

  (** Graph functor *)
  module Make : functor (V : Vertex) -> G with type vertex = V.t

end
