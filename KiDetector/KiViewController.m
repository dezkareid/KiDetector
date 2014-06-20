//
//  KiViewController.m
//  KiDetector
//
//  Created by Joel Humberto Gómez Paredes on 16/06/14.
//  Copyright (c) 2014 Joel Humberto Gómez Paredes. All rights reserved.
//

#import "KiViewController.h"

@interface KiViewController (){
    bool detected;
    int ki;
    int counterKi;
    UILabel *kilabel;
}

@end

@implementation KiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSString *accuracy =  CIDetectorAccuracyLow;
    NSDictionary *options = [NSDictionary dictionaryWithObject:accuracy forKey:CIDetectorAccuracy];
    _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
    detected = false;
    counterKi = 0;
    AVAudioPlayer* theAudio=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"scouter"ofType:@"mp3"]] error:NULL];
    AVAudioPlayer* scouter=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"scouter"ofType:@"wav"]] error:NULL];
    _soundButton = scouter;
    _audio = theAudio;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takeshot:(id)sender {
    [self iniciaCamara];
}

- (IBAction)reiniciar:(id)sender {
    detected = false;
    counterKi = 0;
    kilabel.text =  @"";
}

- (void) takePicture{
    
}

- (void) iniciaCamara{
   
    _sesion = [[AVCaptureSession alloc] init];
    
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_sesion];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
   	captureVideoPreviewLayer.frame = _kiarea.bounds;
    
    
	[_kiarea.layer addSublayer:captureVideoPreviewLayer];
    kilabel =[[UILabel alloc] initWithFrame:CGRectMake((_kiarea.frame.size.width/2)-100, _kiarea.frame.size.height-200, 300, 200)];
    [kilabel setTextColor:[UIColor blackColor]];
    [kilabel setBackgroundColor:[UIColor clearColor]];
    [kilabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 80.0f]];
    [captureVideoPreviewLayer addSublayer:kilabel.layer];
    [_kiarea addSubview:kilabel];
    NSError *error = nil;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    
    [_sesion addInput:input];
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
     [_sesion addOutput:dataOutput];
     [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
     [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    
    [_sesion addOutput:_stillImageOutput];
    
	[_sesion startRunning];
    
    [self setSesion:_sesion];
    
    NSLog(@"Punto de interes %@", NSStringFromCGPoint([captureVideoPreviewLayer captureDevicePointOfInterestForPoint:CGPointMake(0, 0)]));
}

- (void) capturaImagen{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        

    }];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // Create a UIImage from the sample buffer data
    static int counter = 0;
    
    if (detected)
    {
        return;
    }
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    //or use the UIImage wherever you like
    
    if (counter > 50) {
        
        CIImage *ciImage = [[CIImage alloc] initWithImage:image];
        
        int exifOrientation = 6; //   6  =  0th row is on the right, and 0th column is the top.
        
        
        NSDictionary *imageOptions = @{CIDetectorImageOrientation : @(exifOrientation)};
        
        NSArray *features = [self.faceDetector featuresInImage:ciImage options:imageOptions];
        
        NSLog(@"Caras detectadas %lu", (unsigned long)features.count);
        if (features.count >0){

           [_audio play];

            ki = (arc4random() %10000);
            _time = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(imprimeKi) userInfo:nil repeats:YES];
            detected = true;
            
        }
        counter = 0;
    } else {
        counter++;
    }

    
}

- (void ) imprimeKi {
    ki += (arc4random() %10000);
    [kilabel setText:[NSString stringWithFormat:@"%d",ki]];
    counterKi++;
    if (counterKi == 60) {
        [_time invalidate];
        _time = nil;
    }
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

@end
