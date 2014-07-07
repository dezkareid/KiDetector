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
    _preferencias = [NSUserDefaults standardUserDefaults];
    _imagenMeme = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takeshot:(id)sender {
    [_soundButton play];
    [self iniciaCamara];
}

- (IBAction)reiniciar:(id)sender {
    [_soundButton play];
    detected = false;
    counterKi = 0;
    kilabel.text =  @"";
}

- (IBAction)share:(id)sender {
    //[self capturaImagen];
    if (_imagenMeme == nil) {
        return;
    }
    
    [self makeMeme:_imagenMeme];
    NSArray *activityItems;
    NSString * palabra = [_preferencias stringForKey:@"texto"];
    if (palabra.length==0) {
        palabra = @"emprendedor";
        [_preferencias setObject:@"emprendedor" forKey:@"texto"];
    }
    NSString *mensaje = ki > 350000 ? [NSString stringWithFormat:@"Tu nivel de %@ supera los limites",palabra ] : [NSString stringWithFormat:@"Nivel de %@ ",palabra ];
    activityItems = @[mensaje, _imagenMeme];
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc]
     initWithActivityItems:activityItems
     applicationActivities:nil];
    [self presentViewController:activityController
                       animated:YES completion:nil];
    _imagenMeme = nil;
    detected = false;
    counterKi = 0;
    kilabel.text =  @"";
}


- (void) iniciaCamara{
   
    _sesion = [[AVCaptureSession alloc] init];
    
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_sesion];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResize];
   	captureVideoPreviewLayer.frame = _kiarea.bounds;
    
    
	[_kiarea.layer addSublayer:captureVideoPreviewLayer];
    kilabel =[[UILabel alloc] initWithFrame:CGRectMake((_kiarea.frame.size.width/2)-100, _kiarea.frame.size.height-200, 300, 200)];
    [kilabel setTextColor:[UIColor yellowColor]];
    [kilabel setBackgroundColor:[UIColor clearColor]];
    [kilabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 80.0f]];
    [captureVideoPreviewLayer addSublayer:kilabel.layer];
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
        
        if (imageSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            _imagenMeme = [self procesaImagen:[UIImage imageWithData:imageData]];
         

        }
    }];
}

- (UIImage *) procesaImagen:(UIImage *)image {
    //UIImage *myImage;
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width,image.size.height));
    [image drawInRect: CGRectMake(0, 0, image.size.width,image.size.height)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //_imagenMeme = smallImage;
   /* CGRect cropRect = CGRectMake(0, 0,  smallImage.size.width,smallImage.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
    //or use the UIImage wherever you like
    myImage = [UIImage imageWithCGImage:imageRef];
    UIGraphicsBeginImageContext(myImage.size);
    [image drawInRect:CGRectMake(0,0,myImage.size.width,myImage.size.height)];
    CGRect rect = CGRectMake(kilabel.frame.origin.x,kilabel.frame.origin.y,kilabel.frame.size.width, kilabel.frame.size.height);
    [kilabel.textColor set];
    NSString * palabra = [_preferencias stringForKey:@"texto"];
    if (palabra.length==0) {
        palabra = @"emprendedor";
        [_preferencias setObject:@"emprendedor" forKey:@"texto"];
    }
    
    
    NSString *mensaje = ki > 330000 ? [NSString stringWithFormat:@"Tu nivel de %@ supera los limites",palabra ] : [NSString stringWithFormat:@"Nivel de %@ ",palabra ];
    
    
    [kilabel.text drawInRect:CGRectIntegral(rect) withAttributes:@{ NSFontAttributeName: kilabel.font }];
    rect = CGRectMake(myImage.size.width/2,myImage.size.height -200,myImage.size.width/2, kilabel.frame.size.height);
    [mensaje drawInRect:CGRectIntegral(rect) withAttributes:@{ NSFontAttributeName: [UIFont fontWithName: @"Trebuchet MS" size: 30.0f] }];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;*/
    return  smallImage;
}

- (void) makeMeme:(UIImage *)image{
    UIImage *myImage;
    CGRect cropRect = CGRectMake(0, 0,  image.size.width,image.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    //or use the UIImage wherever you like
    myImage = [UIImage imageWithCGImage:imageRef];
    UIGraphicsBeginImageContext(myImage.size);
    [image drawInRect:CGRectMake(0,0,myImage.size.width,myImage.size.height)];
    CGRect rect = CGRectMake(kilabel.frame.origin.x,kilabel.frame.origin.y,kilabel.frame.size.width, kilabel.frame.size.height);
    [kilabel.textColor set];
    NSString * palabra = [_preferencias stringForKey:@"texto"];
    if (palabra.length==0) {
        palabra = @"emprendedor";
        [_preferencias setObject:@"emprendedor" forKey:@"texto"];
    }
    
    
    NSString *mensaje = ki > 330000 ? [NSString stringWithFormat:@"Tu nivel de %@ supera los limites",palabra ] : [NSString stringWithFormat:@"Nivel de %@ ",palabra ];
    
    
    [kilabel.text drawInRect:CGRectIntegral(rect) withAttributes:@{ NSFontAttributeName: kilabel.font, NSForegroundColorAttributeName: [UIColor yellowColor] }];
    rect = CGRectMake(0,myImage.size.height -300,myImage.size.width, kilabel.frame.size.height);
    [mensaje drawInRect:CGRectIntegral(rect) withAttributes:@{ NSFontAttributeName: [UIFont fontWithName: @"Trebuchet MS" size: 40.0f], NSForegroundColorAttributeName: [UIColor yellowColor] }];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _imagenMeme = newImage;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    
    static int counter = 0;
    
    if (detected)
    {
        return;
    }
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    if (counter > 50) {
        
        CIImage *ciImage = [[CIImage alloc] initWithImage:image];
        
        int exifOrientation = 6;
        
        
        NSDictionary *imageOptions = @{CIDetectorImageOrientation : @(exifOrientation)};
        
        NSArray *features = [self.faceDetector featuresInImage:ciImage options:imageOptions];
        
        NSLog(@"Caras detectadas %lu", (unsigned long)features.count);
        if (features.count >0){
            CIFaceFeature *face = features[0];
            if (face.hasLeftEyePosition) {
                if (face.leftEyePosition.x-350>0) {
                    kilabel.frame =CGRectMake(face.leftEyePosition.x-350,face.leftEyePosition.y, 300, 200);
                } else {
                    if (face.leftEyePosition.y-300>0) {
                        kilabel.frame =CGRectMake(face.leftEyePosition.x,face.leftEyePosition.y-300, 300, 200);
                    }
                    
                }
                
            }else{
                if (face.hasRightEyePosition) {
                    if (face.rightEyePosition.x-350>0) {
                        kilabel.frame =CGRectMake(face.rightEyePosition.x-350,face.rightEyePosition.y, 300, 200);
                    } else {
                        if (face.rightEyePosition.y-300>0) {
                            kilabel.frame =CGRectMake(face.rightEyePosition.x,face.rightEyePosition.y-300, 300, 200);
                        }
                        
                    }
                    
                }
            }
          
           [_audio play];

            ki = (arc4random() %10000);
            _time = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(imprimeKi) userInfo:nil repeats:YES];
            detected = true;
            [self capturaImagen];
            
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
    if (counterKi == 68) {
        [_time invalidate];
        _time = nil;
    }
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
  
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

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
