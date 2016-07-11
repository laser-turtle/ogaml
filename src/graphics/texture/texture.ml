open OgamlMath


module type T = sig

  type t

  val bind : t -> int -> unit

end

module MinifyFilter = GLTypes.MinifyFilter

module MagnifyFilter = GLTypes.MagnifyFilter

module WrapFunction = GLTypes.WrapFunction

module Common = struct

  type t = {
      context : State.t;
      internal: GL.Texture.t;
      target  : GLTypes.TextureTarget.t;
      id      : int;
      mipmaps : int;
      mutable minify  : MinifyFilter.t option;
      mutable magnify : MagnifyFilter.t option;
      mutable wrap    : WrapFunction.t option;
  }

  let max_mipmaps size = 
    let rec log2 i = 
      match i with
      | 0 -> 0
      | 1 -> 0
      | n -> 1 + (log2 (n lsr 1))
    in
    max (log2 size.Vector2i.x) (log2 size.Vector2i.y) + 1

  let set_unit st uid = 
    let bound_unit = State.LL.texture_unit st in
    if bound_unit <> uid then begin
      State.LL.set_texture_unit st uid;
      GL.Texture.activate uid
    end

  let bind tex uid = 
    set_unit tex.context uid;
    let bound_tex = State.LL.bound_texture tex.context uid in
    if bound_tex <> Some tex.id then begin
      State.LL.set_bound_texture tex.context uid (Some (tex.internal, tex.id, tex.target));
      GL.Texture.bind tex.target (Some tex.internal)
    end

  let unbind state target uid = 
    set_unit state uid;
    let bound_tex = 
      State.LL.bound_texture state uid
    in
    let bound_target = 
      State.LL.bound_target state uid
    in
    if bound_tex <> None && bound_target = Some target then begin
      State.LL.set_bound_texture
        state uid
        None;
      GL.Texture.bind target None
    end

  let create state mipmaps target =
    (* Create the texture *)
    let internal = GL.Texture.create () in
    let tex = {internal; 
               context = state;
               target;
               mipmaps;
               id = State.LL.texture_id state; 
               wrap = Some GLTypes.WrapFunction.ClampEdge;
               magnify = Some GLTypes.MagnifyFilter.Linear;
               minify = Some GLTypes.MinifyFilter.LinearMipmapLinear} in
    (* Bind it *)
    bind tex 0;
    (* Set reasonable parameters *)
    GL.Texture.parameter target (`Minify GLTypes.MinifyFilter.LinearMipmapLinear);
    GL.Texture.parameter target (`Magnify GLTypes.MagnifyFilter.Linear);
    GL.Texture.parameter target (`Wrap GLTypes.WrapFunction.ClampEdge);
    tex

  let minify tex filter = 
    bind tex 0;
    match tex.minify with
    | Some f when f = filter -> ()
    | _ ->
      GL.Texture.parameter tex.target (`Minify filter);
      tex.minify <- Some filter

  let magnify tex filter = 
    bind tex 0;
    match tex.magnify with
    | Some f when f = filter -> ()
    | _ ->
      GL.Texture.parameter tex.target (`Magnify filter);
      tex.magnify <- Some filter

  let wrap tex func = 
    bind tex 0;
    match tex.wrap with
    | Some f when f = func -> ()
    | _ ->
      GL.Texture.parameter tex.target (`Wrap func);
      tex.wrap <- Some func

end

module Texture2DMipmap = struct

  type t = {
    common  : Common.t;
    width   : int;
    height  : int;
    level   : int
  }

  let bind tex uid = 
    Common.bind tex.common uid

  let size tex = 
    Vector2i.({x = tex.width; y = tex.height})

  let write tex ?rect img = 
    bind tex 0;
    let rect = 
      match rect with
      | None   -> IntRect.create Vector2i.zero (size tex)
      | Some r -> r
    in
    GL.Texture.subimage2D 
      GLTypes.TextureTarget.Texture2D
      tex.level (rect.IntRect.x, rect.IntRect.y)
      (rect.IntRect.width, rect.IntRect.height)
      GLTypes.PixelFormat.RGBA
      (Some (Image.data img))

  let level tex = 
    tex.level

  let to_color_attachment tex = 
    Attachment.ColorAttachment.Texture2D (tex.common.Common.internal, tex.level)

end


module Texture2D = struct

  type t = {
    common  : Common.t;
    width   : int;
    height  : int;
  }

  let create (type s) (module M : RenderTarget.T with type t = s) target 
    ?mipmaps:(mipmaps=`AllGenerated) src = 
    let state = M.state target in
    (* Extract the texture parameters *)
    let width, height, img = 
      match src with
      | `File s -> 
        let img = Image.create (`File s) in
        let v = Image.size img in
        v.Vector2i.x, v.Vector2i.y, (Some img)
      | `Image img ->
        let v = Image.size img in
        v.Vector2i.x, v.Vector2i.y, (Some img)
      | `Empty size ->
        size.Vector2i.x, size.Vector2i.y, None
    in
    let levels = 
      let max_levels = Common.max_mipmaps Vector2i.({x = width; y = height}) in
      match mipmaps with
      | `AllGenerated | `AllEmpty    -> max_levels
      | `Empty i      | `Generated i -> max 1 (min max_levels i)
      | `None -> 1
     in
    (* Create the internal texture *)
    let common = Common.create state levels GLTypes.TextureTarget.Texture2D in
    let tex = {common; width; height} in
    (* Bind the texture *)
    Common.bind tex.common 0;
    (* Allocate the texture *)
    GL.Texture.storage2D
      GLTypes.TextureTarget.Texture2D 
      levels 
      GLTypes.TextureFormat.RGBA8
      (width, height);
    (* Load the corresponding image in each mipmap if requested *)
    begin match mipmaps with
    | `AllGenerated | `Generated _ ->
      for lvl = 0 to levels -1 do
        let data = 
          match img with
          | Some img -> Some (Image.data (Image.mipmap img lvl))
          | None     -> None
        in
        GL.Texture.subimage2D
          GLTypes.TextureTarget.Texture2D 
          lvl (0,0)
          (width lsr lvl, height lsr lvl)
          GLTypes.PixelFormat.RGBA
          data
      done;
    | `None | `AllEmpty | `Empty _ -> ()
    end;
    (* Return the texture *)
    tex

  let size tex = Vector2i.({x = tex.width; y = tex.height})

  let minify tex filter = Common.minify tex.common filter

  let magnify tex filter = Common.magnify tex.common filter

  let wrap tex func = Common.wrap tex.common func

  let mipmap_levels tex = tex.common.Common.mipmaps

  let mipmap tex i = 
    if i >= tex.common.Common.mipmaps || i < 0 then
      raise (Invalid_argument (Printf.sprintf "Mipmap level out of bounds"))
    else
      {Texture2DMipmap.common = tex.common; 
       width = tex.width lsr i; 
       height = tex.height lsr i;
       level = i}

  let bind tex uid = Common.bind tex.common uid

  let to_color_attachment tex = 
    Attachment.ColorAttachment.Texture2D (tex.common.Common.internal, 0)

end
