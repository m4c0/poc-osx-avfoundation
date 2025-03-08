#pragma leco tool
#pragma leco add_impl objc

import stubby;

extern "C" void x(void (*)(const void *, int, int));
extern "C" void tts();
extern "C" void read_audio();
extern "C" void vdo_write();

void frame(const void * ptr, int w, int h) {
  auto p = static_cast<const stbi::pixel *>(ptr);
  stbi::write_rgba_unsafe("out/test.png", w, h, p);
}

int main() {
  //x(frame);
  //tts();
  //vdo_write();
  read_audio();
}
