open OgamlGraphics
open OgamlMath
open OgamlUtils
open OgamlUtils.Result

let fail ?msg err = 
  Log.fatal Log.stdout "%s" err;
  begin match msg with
  | None -> ()
  | Some e -> Log.fatal Log.stderr "%s" e
  end;
  exit 2

let settings =
  OgamlCore.ContextSettings.create
    ~msaa:8
    ~resizable:true
    ()

let window =
  match Window.create ~width:800 ~height:600 ~settings ~title:"Noise Example" () with
  | Ok win -> win
  | Error (`Context_initialization_error msg) -> 
    fail ~msg "Failed to create context"
  | Error (`Window_creation_error msg) -> 
    fail ~msg "Failed to create window"

let img = 
  Image.empty Vector2i.({x = 800; y = 600}) (`RGB Color.RGB.white)

let perlin = 
  Random.self_init ();
  Noise.Perlin2D.create ()

let () = 
  let mini = ref 0. in
  let maxi = ref 0. in
  for i = 0 to 799 do
    for j = 0 to 599 do
      let v = Noise.Perlin2D.get perlin 
        Vector2f.{
          x = float_of_int i /. 100.;
          y = float_of_int j /. 100.;
        }
      in
      mini := min !mini v;
      maxi := max !maxi v;
      let v = (v +. 1.) /. 2. in
      Image.set img Vector2i.({x = i; y = j}) (`RGB Color.RGB.({r = v; g = v; b = v; a = 1.}))
      |> assert_ok
    done;
  done;
  Printf.printf "Noise min : %f, noise max : %f\n%!" !mini !maxi

let tex = 
  Texture.Texture2D.create (module Window) window (`Image img)
  |> assert_ok

let draw = 
  let sprite = Sprite.create ~texture:tex () |> assert_ok in
  Sprite.draw (module Window) ~target:window ~sprite

let rec handle_events () =
  let open OgamlCore in
  match Window.poll_event window with
  | Some e -> Event.(
      match e with
      | Closed -> Window.close window
      | _      -> ()
    ) ; handle_events ()
  | None -> ()

let rec each_frame () =
  if Window.is_open window then begin
    Window.clear ~color:(Some (`RGB Color.RGB.white)) window |> assert_ok;
    draw () ;
    Window.display window ;
    handle_events () ;
    each_frame ()
  end

let () = each_frame ()
