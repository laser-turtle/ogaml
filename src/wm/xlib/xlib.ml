
(* Display module *)
module Display = struct

  (* Display type *)
  type t


  (* Abstract functions (not exposed) *)
  external abstract_open  : string option -> t = "caml_xopen_display"

  external abstract_screen_size    : t -> int -> (int * int) = "caml_xscreen_size"

  external abstract_screen_size_mm : t -> int -> (int * int) = "caml_xscreen_sizemm"

  
  (* Exposed functions *)
  external screen_count : t -> int = "caml_xscreen_count"
  
  external default_screen : t -> int = "caml_xdefault_screen"

  external flush : t -> unit = "caml_xflush"


  (* Implementation of abstract functions *)
  let create ?hostname ?display:(display = 0) ?screen:(screen = 0) () =
    match hostname with
    |None -> abstract_open None
    |Some(s) -> abstract_open (Some (Printf.sprintf "%s:%i.%i" s display screen))

  let screen_size ?screen display = 
    match screen with
    |None -> abstract_screen_size display (default_screen display)
    |Some(s) -> abstract_screen_size display s

  let screen_size_mm ?screen display = 
    match screen with
    |None -> abstract_screen_size_mm display (default_screen display)
    |Some(s) -> abstract_screen_size_mm display s

end


(* Window module *)
module Window = struct

  (* Window type *)
  type t


  (* Abstract functions *)
  external abstract_root_window : Display.t -> int -> t = "caml_xroot_window"

  external abstract_create_simple_window : 
    Display.t -> t -> (int * int) -> (int * int) -> int -> t
    = "caml_xcreate_simple_window"

  external map : Display.t -> t -> unit = "caml_xmap_window"


  (* Implementation of abstract functions *)
  let root_of ?screen display =
    match screen with
    |None -> abstract_root_window display (Display.default_screen display)
    |Some(s) -> abstract_root_window display s

  let create_simple ~display ~parent ~size ~origin ~background = 
    abstract_create_simple_window display parent origin size background


end


(* Atom module *)
module Atom = struct

  (* Atom type *)
  type t


  (* Abstract functions *)
  external abstract_setwm_protocols : 
    Display.t -> Window.t -> t array -> int -> unit
    = "caml_xset_wm_protocols"


  (* Exposed functions *)
  external intern : Display.t -> string -> bool -> t option = "caml_xintern_atom"


  (* Implementation *)
  let set_wm_protocols disp win plist = 
    let arr = Array.of_list plist in
    abstract_setwm_protocols disp win arr (Array.length arr)

end
