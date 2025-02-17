@import AVFoundation;
@import CoreFoundation;

void y(void (* cb)(const void *, int, int)) {
  NSURL * url = [NSURL fileURLWithPath:@"out/IMG_2450.MOV"];
  AVPlayer * pl = [AVPlayer playerWithURL:url];
  AVPlayerItemVideoOutput * vout = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:@{
    (NSString *)kCVPixelBufferPixelFormatTypeKey: (NSString *)kCVPixelBufferPixelFormatTypeKey
  }];
  [pl.currentItem addOutput:vout];
  [pl play];

  NSLog(@"%f", [pl rate]);

  CMTime time = CMTimeMake(0.0, 1);
  NSLog(@"%d", [vout hasNewPixelBufferForItemTime:time]);
  CVPixelBufferRef buf = [vout copyPixelBufferForItemTime:time itemTimeForDisplay:nil];

  NSLog(@"%@", buf);

  CVBufferRelease(buf);
}

void x(void (* cb)(const void *, int, int)) {
  NSURL * url = [NSURL fileURLWithPath:@"out/IMG_2450.MOV"];
  AVMovie * mov = [AVMovie movieWithURL:url options:nil];
  AVAssetImageGenerator * gen = [AVAssetImageGenerator assetImageGeneratorWithAsset:mov];
  gen.maximumSize = NSMakeSize(1024.0, 1024.0);

  CMTime time = CMTimeMake(1.0, 1);
  CGImageRef img = [gen copyCGImageAtTime:time actualTime:nil error:nil];
  CGDataProviderRef data_prov = CGImageGetDataProvider(img);
  CFDataRef data = CGDataProviderCopyData(data_prov);

  int w = CGImageGetBytesPerRow(img) / 4;
  int h = CGImageGetHeight(img);
  const UInt8 * ptr = CFDataGetBytePtr(data);
  cb(ptr, w, h);

  CFRelease(data);
  CFRelease(data_prov);
}

