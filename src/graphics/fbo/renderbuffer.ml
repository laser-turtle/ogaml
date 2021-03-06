open OgamlMath

exception RBO_Error of string


module ColorBuffer = struct

  type t = {
    id : int;
    internal : GL.RBO.t;
    size : Vector2i.t
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target size = 
    let internal = GL.RBO.create () in
    let context = M.context target in
    let id = Context.LL.rbo_id context in
    let capabilities = Context.capabilities context in
    if size.Vector2i.x >= capabilities.Context.max_renderbuffer_size 
    || size.Vector2i.y >= capabilities.Context.max_renderbuffer_size then
      raise (RBO_Error "Max renderbuffer size exceeded");
    GL.RBO.bind (Some internal);
    GL.RBO.storage GLTypes.TextureFormat.RGBA8 size.Vector2i.x size.Vector2i.y;
    GL.RBO.bind None;
    {id; internal; size}

  let to_color_attachment t = 
    Attachment.ColorAttachment.ColorRBO t.internal

  let size t = t.size

end


module DepthBuffer = struct

  type t = {
    id : int;
    internal : GL.RBO.t;
    size : Vector2i.t
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target size = 
    let internal = GL.RBO.create () in
    let context = M.context target in
    let id = Context.LL.rbo_id context in
    let capabilities = Context.capabilities context in
    if size.Vector2i.x >= capabilities.Context.max_renderbuffer_size 
    || size.Vector2i.y >= capabilities.Context.max_renderbuffer_size then
      raise (RBO_Error "Max renderbuffer size exceeded");
    GL.RBO.bind (Some internal);
    GL.RBO.storage GLTypes.TextureFormat.Depth24 size.Vector2i.x size.Vector2i.y;
    GL.RBO.bind None;
    {id; internal; size}

  let to_depth_attachment t = 
    Attachment.DepthAttachment.DepthRBO t.internal

  let size t = t.size

end


module DepthStencilBuffer = struct

  type t = {
    id : int;
    internal : GL.RBO.t;
    size : Vector2i.t
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target size = 
    let internal = GL.RBO.create () in
    let context = M.context target in
    let id = Context.LL.rbo_id context in
    let capabilities = Context.capabilities context in
    if size.Vector2i.x >= capabilities.Context.max_renderbuffer_size
    || size.Vector2i.y >= capabilities.Context.max_renderbuffer_size then
      raise (RBO_Error "Max renderbuffer size exceeded");
    GL.RBO.bind (Some internal);
    GL.RBO.storage GLTypes.TextureFormat.Depth24Stencil8 size.Vector2i.x size.Vector2i.y;
    GL.RBO.bind None;
    {id; internal; size}

  let to_depth_stencil_attachment t = 
    Attachment.DepthStencilAttachment.DepthStencilRBO t.internal

  let size t = t.size

end   


module StencilBuffer = struct

  type t = {
    id : int;
    internal : GL.RBO.t;
    size : Vector2i.t
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target size = 
    let internal = GL.RBO.create () in
    let context = M.context target in
    let id = Context.LL.rbo_id context in
    let capabilities = Context.capabilities context in
    if size.Vector2i.x >= capabilities.Context.max_renderbuffer_size 
    || size.Vector2i.y >= capabilities.Context.max_renderbuffer_size then
      raise (RBO_Error "Max renderbuffer size exceeded");
    GL.RBO.bind (Some internal);
    GL.RBO.storage GLTypes.TextureFormat.Stencil8 size.Vector2i.x size.Vector2i.y;
    GL.RBO.bind None;
    {id; internal; size}

  let to_stencil_attachment t = 
    Attachment.StencilAttachment.StencilRBO t.internal

  let size t = t.size

end   


