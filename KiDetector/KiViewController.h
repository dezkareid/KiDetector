//
//  KiViewController.h
//  KiDetector
//
//  Created by Joel Humberto Gómez Paredes on 16/06/14.
//  Copyright (c) 2014 Joel Humberto Gómez Paredes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioPlayer.h>


@interface KiViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;

@property (strong,nonatomic) NSTimer *time;

@property (strong, nonatomic) AVAudioPlayer *audio;

@property (strong, nonatomic) AVAudioPlayer *soundButton;

@property(nonatomic,retain) AVCaptureSession * sesion;

@property (nonatomic, strong) CIDetector *faceDetector;

@property (weak, nonatomic) IBOutlet UIView *kiarea;

- (IBAction)takeshot:(id)sender;
- (IBAction)reiniciar:(id)sender;

@end
