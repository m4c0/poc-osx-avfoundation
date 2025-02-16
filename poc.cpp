#pragma leco tool
#pragma leco add_impl objc

import stubby;

extern "C" void x(void (*)(const void *, int, int));

void frame(const void * ptr, int w, int h) {
  auto p = static_cast<const stbi::pixel *>(ptr);
  stbi::write_rgba_unsafe("out/test.png", w, h, p);
}

int main() {
  x(frame);
}
