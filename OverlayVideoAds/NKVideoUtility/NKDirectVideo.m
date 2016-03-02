//
//  NKDirectVideo.m
//  OverlayVideoAds
//
//  Created by Nikunj Modi on 3/1/16.
//  Copyright © 2016 Niks. All rights reserved.
//
#import "AppDelegate.h"
#import "NKDirectVideo.h"

CGFloat const kDirectThumbnailLocation = 1.0;

@interface NKDirectVideo()
@property (nonatomic, strong) MPMoviePlayerViewController *player;
@end

@implementation NKDirectVideo

#pragma mark - NKVideo Protocol

- (instancetype)initWithContent:(NSURL *)contentURL {
    self = [super init];
    if (self) {
        self.contentURL = contentURL;
    }
    return self;
}

- (void)parseWithCompletion:(void(^)(NSError *error))callback {
    NSAssert(self.contentURL, @"Direct URLs to natively supported formats such as MP4 do not require calling this method.");
}

- (void)thumbImage:(NKQualityOptions)quality completion:(void(^)(UIImage *thumbImage, NSError *error))callback {
    NSAssert(callback, @"usingBlock cannot be nil");
    
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:self.player queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        MPMoviePlayerController *newPlayer = note.object;
        
        if ([newPlayer.contentURL.absoluteString isEqualToString:[self videoURL:quality].absoluteString]) {
            UIImage *thumb = note.userInfo[@"MPMoviePlayerThumbnailImageKey"];
            NSError *error = note.userInfo[@"MPMoviePlayerThumbnailErrorKey"];
            
            if (thumb) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) callback(thumb, error);
                });
            }
            
            //TODO: check callback might not happen if thumb could not be loaded
        }
    }];
    
    self.player = [[MPMoviePlayerViewController alloc] initWithContentURL:[self videoURL:quality]];
    [self.player.moviePlayer setShouldAutoplay:NO];
    [self.player.moviePlayer prepareToPlay];
    [self.player.moviePlayer requestThumbnailImagesAtTimes:@[@(kDirectThumbnailLocation)] timeOption:MPMovieTimeOptionExact];
}

- (NSURL *)videoURL:(NKQualityOptions)quality {
    return self.contentURL;
}

#pragma warning Move to Parent class

- (MPMoviePlayerViewController *)movieViewController:(NKQualityOptions)quality {
    
    //CGFloat playWidth = 18.f;
    //CGFloat playHeight = 22.f;
    
    self.player = [[MPMoviePlayerViewController alloc] initWithContentURL:[self videoURL:quality]];
    [self.player.moviePlayer setShouldAutoplay:NO];
    [self.player.moviePlayer prepareToPlay];
    self.player.moviePlayer.controlStyle = MPMovieControlStyleNone;
    [self.player.moviePlayer.view addSubview:[self customeView]];
    return self.player;
}

- (void)play:(NKQualityOptions)quality {
    if (!self.player) [self movieViewController:quality];
    
    //[[UIApplication sharedApplication].keyWindow.rootViewController presentMoviePlayerViewControllerAnimated:self.player];
    NSLog(@"%@",[self.currentVC description]);
    [[NSNotificationCenter defaultCenter] removeObserver:self.player
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.player.moviePlayer];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // Register this class as an observer instead
    [[NSNotificationCenter defaultCenter] addObserver:self.currentVC
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.player.moviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self.player
                                                    name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:self.player.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self.currentVC selector:@selector(moviePlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player.moviePlayer];
#pragma clang diagnostic pop
    [self.currentVC presentMoviePlayerViewControllerAnimated:self.player];
    [self.player.moviePlayer play];
}
-(UIView *)customeView{
    
    CGFloat playWidth = 18.f;
    CGFloat playHeight = 22.f;
    
    AppDelegate *myDelegate = [UIApplication sharedApplication].delegate;
    //Overlay main view
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,myDelegate.window.frame.size.width, myDelegate.window.frame.size.height)];
    [overlayView setBackgroundColor:[UIColor clearColor]];
    //Ovelay top view
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, overlayView.frame.size.width, 50)];
    [topView setBackgroundColor:[UIColor lightGrayColor]];
    UIFont * customFont = [UIFont fontWithName:@"Avenir-Medium" size:16]; //custom font
    UIButton *btnDone = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40, 20)];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
        [btnDone addTarget:self.currentVC action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    #pragma clang diagnostic pop
    btnDone.titleLabel.font = customFont;
    [topView addSubview:btnDone];
    
    UIFont * customFontLabel = [UIFont fontWithName:@"Avenir-Medium" size:13]; //custom font
    UILabel *timeElapsedLabel = [[UILabel alloc] initWithFrame:CGRectMake(btnDone.frame.origin.x + btnDone.frame.size.width + 10, 12, 30, 20)];
    timeElapsedLabel.backgroundColor = [UIColor clearColor];
    timeElapsedLabel.font = customFontLabel;
    timeElapsedLabel.textColor = [UIColor lightTextColor];
    timeElapsedLabel.textAlignment = NSTextAlignmentRight;
    timeElapsedLabel.text = @"--:--";
    timeElapsedLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    timeElapsedLabel.layer.shadowRadius = 1.f;
    timeElapsedLabel.layer.shadowOffset = CGSizeMake(1.f, 1.f);
    timeElapsedLabel.layer.shadowOpacity = 0.8f;
    timeElapsedLabel.tag = 365367;
    
    UILabel *timeRemainingLabel = [[UILabel alloc] initWithFrame:CGRectMake(myDelegate.window.frame.size.width-40, 12, 30, 20)];
    timeRemainingLabel.backgroundColor = [UIColor clearColor];
    timeRemainingLabel.font = customFontLabel;
    timeRemainingLabel.textColor = [UIColor lightTextColor];
    timeRemainingLabel.textAlignment = NSTextAlignmentLeft;
    timeRemainingLabel.text = @"--:--";
    timeRemainingLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    timeRemainingLabel.layer.shadowRadius = 1.f;
    timeRemainingLabel.layer.shadowOffset = CGSizeMake(1.f, 1.f);
    timeRemainingLabel.layer.shadowOpacity = 0.8f;
    timeRemainingLabel.tag = 365368;
    
    //duration slider
    //CGFloat timeRemainingXWidht = timeRemainingLabel.frame.origin.x+30;
    CGFloat timeRemainingX = timeRemainingLabel.frame.origin.x;
    CGFloat timeElapsedXWidht = timeElapsedLabel.frame.origin.x+30;
    CGFloat timeElapsedX = timeElapsedLabel.frame.origin.x;
    
    UISlider *durationSlider = [[UISlider alloc] initWithFrame:CGRectMake(timeElapsedXWidht+5,17,(timeRemainingX-10)-(timeElapsedX+30),10)];
    durationSlider.value = 0.f;
    durationSlider.continuous = YES;
    durationSlider.userInteractionEnabled = FALSE;
    [durationSlider setMinimumTrackTintColor:[UIColor colorWithRed:178.0/255.0 green:0/255.0 blue:161.0/255.0 alpha:1.0]];
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"slider-default-handle.png"] forState:UIControlStateNormal];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
        [durationSlider addTarget:self.currentVC action:@selector(durationSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    #pragma clang diagnostic pop
    durationSlider.tag = 365369;
    
    [topView addSubview:timeElapsedLabel];
    [topView addSubview:timeRemainingLabel];
    [topView addSubview:durationSlider];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //activityIndicator.frame = CGRectMake(60, 15, 10, 10);
    activityIndicator.center = myDelegate.window.center;
    activityIndicator.tag = 365365;
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator startAnimating];
    [overlayView addSubview:activityIndicator];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, overlayView.frame.size.height-64, overlayView.frame.size.width, 64)];
    [bottomView setBackgroundColor:[UIColor lightGrayColor]];
    UIButton *playPauseButton = [[UIButton alloc] initWithFrame:CGRectMake(myDelegate.window.frame.size.width/2 - playWidth/2, bottomView.frame.size.height/2 - playHeight/2, playWidth, playHeight)];
     [playPauseButton setImage:[UIImage imageNamed:@"moviePause.png"] forState:UIControlStateNormal];
     [playPauseButton setImage:[UIImage imageNamed:@"moviePlay.png"] forState:UIControlStateSelected];
     [playPauseButton setSelected:self.player.moviePlayer.playbackState == MPMoviePlaybackStatePlaying ? NO : YES];
     playPauseButton.tag = 365366;
     #pragma clang diagnostic push
     #pragma clang diagnostic ignored "-Wundeclared-selector"
     [playPauseButton addTarget:self.currentVC action:@selector(playPausePressed) forControlEvents:UIControlEventTouchUpInside];
     #pragma clang diagnostic pop
    
     [bottomView addSubview:playPauseButton];
     [overlayView addSubview:topView];
     [overlayView addSubview:bottomView];
    return overlayView;
}
@end

