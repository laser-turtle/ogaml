open OgamlCore

exception Missing_uniform of string

exception Invalid_uniform of string

type t = {
  state : State.t; 
  internal : LL.Window.t; 
  settings : ContextSettings.t; 
  program2D : Program.t
}

(** 2D drawing program *)
let vertex_shader_source = "
  uniform vec2 size;

  in vec3 position;
  in vec4 color;

  out vec4 frag_color;

  void main() {

    gl_Position.x = 2.0 * position.x / size.x - 1.0;
    gl_Position.y = 2.0 * (size.y - position.y) / size.y - 1.0;
    gl_Position.z = 0.0;
    gl_Position.w = 1.0;

    frag_color = color;

  }
"

let fragment_shader_source = "
  in vec4 frag_color;

  out vec4 pixel_color;

  void main() {

    pixel_color = frag_color;

  }
"

let create ~width ~height ~settings =
  let internal = LL.Window.create ~width ~height in
  let state = State.LL.create () in
  {
    state;
    internal;
    settings;
    program2D = 
      Program.from_source_pp state
        ~vertex_source:(`String vertex_shader_source)
        ~fragment_source:(`String fragment_shader_source)
  }

let close win = LL.Window.close win.internal

let destroy win = LL.Window.destroy win.internal

let is_open win = LL.Window.is_open win.internal

let has_focus win = LL.Window.has_focus win.internal

let size win = LL.Window.size win.internal

let poll_event win = LL.Window.poll_event win.internal

let display win = LL.Window.display win.internal

let clear win =
  let cc = ContextSettings.color win.settings in
  if State.clear_color win.state <> cc then begin
    let crgb = Color.rgb cc in
    State.LL.set_clear_color win.state cc;
    Color.RGB.(GL.Pervasives.color crgb.r crgb.g crgb.b crgb.a)
  end;
  let color = ContextSettings.color_clearing win.settings in
  let depth = ContextSettings.depth_testing  win.settings in
  let stencil = ContextSettings.stenciling   win.settings in
  GL.Pervasives.clear color depth stencil

let state win = win.state


module LL = struct

  let internal win = win.internal

  let program win = win.program2D

end
