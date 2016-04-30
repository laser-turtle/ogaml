open OgamlCore

type t = {
  state : State.t;
  internal : LL.Window.t;
  settings : ContextSettings.t;
  programs : ProgramLibrary.t
}

let create ?width:(width=800) ?height:(height=600) ?title:(title="") 
           ?settings:(settings=OgamlCore.ContextSettings.create ()) () =
  let internal = LL.Window.create ~width ~height ~title ~settings in
  let state = State.LL.create () in
  State.LL.set_viewport state OgamlMath.IntRect.({x = 0; y = 0; width; height});
  let programs = ProgramLibrary.create state in
  {
    state;
    internal;
    settings;
    programs;
  }

let set_title win title = LL.Window.set_title win.internal title

let close win = LL.Window.close win.internal

let rect win = LL.Window.rect win.internal

let destroy win = LL.Window.destroy win.internal

let resize win size = LL.Window.resize win.internal size

let toggle_fullscreen win = LL.Window.toggle_fullscreen win.internal

let is_open win = LL.Window.is_open win.internal

let has_focus win = LL.Window.has_focus win.internal

let size win = LL.Window.size win.internal

let poll_event win = LL.Window.poll_event win.internal

let display win = 
  RenderFunctions.bind_fbo win.state 0 None;
  LL.Window.display win.internal

let clear ?color:(color=`RGB Color.RGB.black) win =
  let depth = ContextSettings.depth_bits win.settings > 0 in
  let stencil = ContextSettings.stencil_bits win.settings > 0 in
  RenderFunctions.bind_fbo win.state 0 None;
  RenderFunctions.clear ~color ~depth ~stencil win.state

let show_cursor win b = LL.Window.show_cursor win.internal b

let state win = win.state


module LL = struct

  let internal win = win.internal

  let programs win = win.programs

  let bind_draw_parameters win parameters = 
    RenderFunctions.bind_draw_parameters 
      win.state (size win) 
      (OgamlCore.ContextSettings.aa_level win.settings)
      parameters

end
