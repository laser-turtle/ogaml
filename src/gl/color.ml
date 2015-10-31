
let clamp a mina maxa = max (min a maxa) mina

module RGB = struct

  type t = {r : float; g : float; b : float; a : float}

  let black   = {r = 0.; g = 0.; b = 0.; a = 1.}

  let white   = {r = 1.; g = 1.; b = 1.; a = 1.}

  let red     = {r = 1.; g = 0.; b = 0.; a = 1.}

  let green   = {r = 0.; g = 1.; b = 0.; a = 1.}

  let blue    = {r = 0.; g = 0.; b = 1.; a = 1.}

  let yellow  = {r = 1.; g = 1.; b = 0.; a = 1.}

  let magenta = {r = 1.; g = 0.; b = 1.; a = 1.}

  let cyan    = {r = 0.; g = 1.; b = 1.; a = 1.}

  let transparent = {r = 0.; g = 0.; b = 0.; a = 0.}

end

let rad60 = 60. *. OgamlMath.Constants.pi /. 180.

module HSV = struct

  type t = {h : float; s : float; v : float; a : float}

  let black   = {h = 0.; s = 0.; v = 0.; a = 1.}

  let white   = {h = 0.; s = 0.; v = 1.; a = 1.}

  let red     = {h = 0.; s = 1.; v = 1.; a = 1.}

  let green   = {h = 2. *. rad60; s = 1.; v = 1.; a = 1.}

  let blue    = {h = 4. *. rad60; s = 1.; v = 1.; a = 1.}

  let yellow  = {h = rad60; s = 1.; v = 1.; a = 1.}

  let magenta = {h = 5. *. rad60; s = 1.; v = 1.; a = 1.}

  let cyan    = {h = 3. *. rad60; s = 1.; v = 1.; a = 1.}

  let transparent = {h = 0.; s = 0.; v = 0.; a = 0.}

end

let rgb_to_hsv color = 
  let open RGB in
  let cmax = max (max color.r color.g) color.b in
  let cmin = min (min color.r color.g) color.b in
  let d = cmax -. cmin in
  let h = 
    if cmax = color.r then rad60 *. (mod_float ((color.g -. color.b) /. d) 6.)
    else if cmax = color.g then rad60 *. ((color.b -. color.r) /. d +. 2.)
    else rad60 *. ((color.r -. color.g) /. d +. 4.)
  in
  let h = 
    if h < 0. then h +. 2. *. OgamlMath.Constants.pi else h
  in
  let s = 
    if cmax = 0. then 0.
    else d /. cmax
  in
  {HSV.h = clamp h 0. (2. *. OgamlMath.Constants.pi);
   HSV.s = clamp s 0. 1.;
   HSV.v = clamp cmax 0. 1.;
   HSV.a = color.a}

let hsv_to_rgb color = 
  let open HSV in 
  let c = color.s *. color.v in
  let h = mod_float color.h (2. *. OgamlMath.Constants.pi) in
  let x = c *. (1. -. (abs_float (mod_float (h /. rad60) 2. -. 1.))) in
  let m = color.v -. c in
  let (r',g',b') =
    if h < rad60 then (c,x,0.)
    else if h < 2. *. rad60 then (x,c,0.)
    else if h < 3. *. rad60 then (0.,c,x)
    else if h < 4. *. rad60 then (0.,x,c)
    else if h < 5. *. rad60 then (x,0.,c)
    else (c,0.,x)
  in
  {RGB.r = clamp (r'+.m) 0. 1.; 
   RGB.g = clamp (g'+.m) 0. 1.; 
   RGB.b = clamp (b'+.m) 0. 1.;
   RGB.a = color.a}
