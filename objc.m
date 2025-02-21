@import AVFoundation;
@import CoreFoundation;

@interface Delegate : NSObject<AVSpeechSynthesizerDelegate>
@end
@implementation Delegate
- (void) speechSynthesizer:(AVSpeechSynthesizer *)synth willSpeakRangeOfSpeechString:(NSRange)range utterance:(AVSpeechUtterance *)utt {
  NSString * buf = [utt.speechString substringWithRange:range];
  NSLog(@"%@", buf);
}
@end

void tts() {
  @autoreleasepool {
    float max = AVSpeechUtteranceMaximumSpeechRate;
    float min = AVSpeechUtteranceMinimumSpeechRate;

    NSString * text = @"These are five reasons to fill the gap with gapes";
    AVSpeechUtterance * utt = [AVSpeechUtterance speechUtteranceWithString:text];
    utt.voice = [AVSpeechSynthesisVoice voiceWithIdentifier:@"com.apple.voice.compact.en-GB.Daniel"];
    utt.rate = (max - min) * 0.6 + min;

    //for (AVSpeechSynthesisVoice * v in [AVSpeechSynthesisVoice speechVoices]) {
    //  if (![v.language hasPrefix:@"en"]) continue;
    //  NSLog(@"%@", v);
    //}

    Delegate * delegate = [Delegate new];

    AVSpeechSynthesizer * synth = [[AVSpeechSynthesizer alloc] init];
    synth.delegate = delegate;
    [synth speakUtterance:utt];
    //[synth writeUtterance:utt toBufferCallback:^(AVAudioBuffer * _Nonnull buffer) {
    //  NSLog(@"Received audio buffer: %@", buffer);
    //  //[NSThread sleepForTimeInterval:1.0];
    //}];
        
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
  }
}

void x(void (* cb)(const void *, int, int)) {
  NSURL * url = [NSURL fileURLWithPath:@"out/IMG_2450.MOV"];
  AVMovie * mov = [AVMovie movieWithURL:url options:nil];

  AVAssetTrack * trk = [[mov tracksWithMediaType:AVMediaTypeVideo] firstObject];
  AVAssetReaderTrackOutput * out = [[AVAssetReaderTrackOutput alloc] initWithTrack:trk outputSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)}];

  NSLog(@"1");
  AVAssetReader * rdr = [[AVAssetReader alloc] initWithAsset:mov error:nil];
  [rdr addOutput:out];
  [rdr startReading];

  NSLog(@"2");
  CMSampleBufferRef smp = [out copyNextSampleBuffer];
  CVPixelBufferRef img = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(smp);
  NSLog(@"3");

  CVPixelBufferLockBaseAddress(img, kCVPixelBufferLock_ReadOnly);
  NSLog(@"4");
  void * addr = CVPixelBufferGetBaseAddress(img);
  int w = CVPixelBufferGetBytesPerRow(img) / 4;
  int h = CVPixelBufferGetHeight(img);
  cb(addr, w, h);

  NSLog(@"5");
  CVPixelBufferUnlockBaseAddress(img, kCVPixelBufferLock_ReadOnly);

  CFRelease(smp);
  NSLog(@"6");
}

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

void z(void (* cb)(const void *, int, int)) {
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

void vdo_write() {
  unlink("out/test.mov");
  NSURL * url = [NSURL fileURLWithPath:@"out/test.mov"];
  AVAssetWriter * aw = [AVAssetWriter assetWriterWithURL:url
                                                fileType:AVFileTypeQuickTimeMovie
                                                   error:nil];

  NSDictionary * opts = @{
    AVVideoCodecKey: AVVideoCodecTypeH264,
    AVVideoWidthKey: @(720 / 2),
    AVVideoHeightKey: @(1280 / 2),
  };
  AVAssetWriterInput * inp = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                outputSettings:opts];
  inp.expectsMediaDataInRealTime = YES;

  opts = @{
    (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32ARGB),
    (id)kCVPixelBufferWidthKey: @(720),
    (id)kCVPixelBufferHeightKey: @(1280),
    (id)kCVPixelBufferBytesPerRowAlignmentKey: @(4 * 720)
  };
  AVAssetWriterInputPixelBufferAdaptor * pba = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:inp
                                                                                          sourcePixelBufferAttributes:opts];

  [aw addInput:inp];
  [aw startWriting];
  [aw startSessionAtSourceTime:kCMTimeZero];

  opts = @{
    (id)kCVPixelBufferCGImageCompatibilityKey: @(YES),
    (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @(YES),
  };
  NSLog(@"before");
  for (int frame = 0; frame < 30; frame++) {
    CVPixelBufferRef buf;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, 720, 1280, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)opts, &buf);
    // CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pba.pixelBufferPool, &buf);
    if (status != kCVReturnSuccess || !buf) {
      NSLog(@"%d", status);
      return;
    }

    CVPixelBufferLockBaseAddress(buf, 0);
    unsigned * pixies = CVPixelBufferGetBaseAddress(buf);
    for (int i = 0; i < 720 * 1280; i++) pixies[i] = (i % 720) > 360 ? ~0 : 0;
    CVPixelBufferUnlockBaseAddress(buf, 0);

    CMTime time = CMTimeMake(frame, 24);
    for (int i = 0; i < 30; i++) {
      if (!pba.assetWriterInput.readyForMoreMediaData) {
        NSLog(@"Buffer wasnt ready");
        [NSThread sleepForTimeInterval:0.05];
        continue;
      }
    }
    if (![pba appendPixelBuffer:buf withPresentationTime:time]) {
      NSLog(@"%@", aw.error);
      return;
    }
    CVBufferRelease(buf);
  }
  NSLog(@"after");

  [inp markAsFinished];
  [aw finishWritingWithCompletionHandler:^{
    NSLog(@"Done");
  }];

  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
}
