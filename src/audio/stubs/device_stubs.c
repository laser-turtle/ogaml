#include <string.h>
#if defined(__APPLE__)
  #include <OpenAl/al.h>
  #include <OpenAL/alc.h>
#else
  #include <AL/al.h>
  #include <AL/alc.h>
#endif
#include "utils.h"


value Val_alcerror(ALCenum error)
{
  switch(error)
  {
    case ALC_NO_ERROR:          
      return Val_int(0);

    case ALC_INVALID_DEVICE:      
      return Val_int(1);

    case ALC_INVALID_CONTEXT:      
      return Val_int(2);

    case ALC_INVALID_ENUM:     
      return Val_int(3);

    case ALC_INVALID_VALUE: 
      return Val_int(4);

    case ALC_OUT_OF_MEMORY:     
      return Val_int(5);

    default: 
      return Val_int(0);
  }
}

CAMLprim value
caml_alc_open_device(value dev_name)
{
  CAMLparam1(dev_name);

  ALCchar* devicename;

  if(dev_name == Val_int(0))
    devicename = NULL;
  else
    devicename = String_val(Field(dev_name,0));

  CAMLreturn((value)alcOpenDevice(devicename));
}

CAMLprim value
caml_alc_close_device(value device)
{
  CAMLparam1(device);

  ALCboolean result = alcCloseDevice((ALCdevice*)device);

  CAMLreturn(Val_bool(result == ALC_TRUE));
}

CAMLprim value
caml_alc_error(value device)
{
  CAMLparam1(device);

  CAMLreturn(Val_alcerror(alcGetError((ALCdevice*)device)));
}
