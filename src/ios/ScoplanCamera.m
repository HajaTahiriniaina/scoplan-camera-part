#import "ScoplanCamera.h"
#import "UIScoplanCamera.h"
#import "UIImagePickerDelegate.h"

@interface ScoplanCamera()
@property (nonatomic)  UIImagePickerDelegate * pickerdelegate;
@property (nonatomic) UIView * overLayView;
@property (nonatomic) UIImagePickerController *cameraUI;
@end

@implementation ScoplanCamera

- (void)pluginInitialize {
    
}

-(void)cancelClicked:(id)sender{
    NSLog(@"cancelOrok");
    [self dismisCam];
}

-(void)takenClicked:(id)sender{
    NSLog(@"shoot");
    [self shoot];
}

- (void)insertPicture:(NSString*)url{
    [mpictures addObject:url];
}

- (void)dismisCam{
    UIView *toRemove = [self.webView viewWithTag:111];
    if(toRemove != NULL){
        dispatch_async( dispatch_get_main_queue(), ^{
            [toRemove removeFromSuperview];
        });
    }
    [self.cameraUI dismissViewControllerAnimated:TRUE completion:nil];
    CDVPluginResult* pluginResult = [CDVPluginResult
                                     resultWithStatus:CDVCommandStatus_OK
                                     messageAsArray:mpictures];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:mcallback.callbackId];
}

- (void) takePictures:(CDVInvokedUrlCommand*)command {
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
    mcallback = command;
    mpictures = [[NSMutableArray alloc]init];
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* pluginResult = [CDVPluginResult
            resultWithStatus:CDVCommandStatus_NO_RESULT
                                         messageAsArray:self->mpictures];
        [pluginResult setKeepCallback:[[NSNumber alloc] initWithBool:TRUE]];
        self.pickerdelegate = [[UIImagePickerDelegate alloc]init];
        [self.pickerdelegate setCam:self];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.webView addSubview:self.overLayView];
            self.overLayView = [[[NSBundle mainBundle] loadNibNamed:@"multiCam" owner:self.viewController options:nil] objectAtIndex:0];
            UIButton *takeBtn = (UIButton *)[self.overLayView viewWithTag:1];
            [takeBtn addTarget: self action: @selector(takenClicked:) forControlEvents: UIControlEventTouchUpInside];
            UIButton *cancelBtn = (UIButton *)[self.overLayView viewWithTag:2];
            dispatch_async( dispatch_get_main_queue(), ^{
                 [cancelBtn setTitle:@"Annuler" forState:UIControlStateNormal];
            } );
            [cancelBtn addTarget: self action: @selector(cancelClicked:) forControlEvents: UIControlEventTouchUpInside];
            ((UIImageView *)[self.overLayView viewWithTag:3]).image = nil;
            [self startCameraControllerFromViewController:self.viewController usingDelegate:self->_pickerdelegate];
        } );
    }];
}

- (void) shoot{
    [self.cameraUI takePicture];
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    self.cameraUI = [[UIImagePickerController alloc] init];
    self.cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.cameraUI.showsCameraControls = NO;
    self.cameraUI.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    self.cameraUI.allowsEditing = NO;
    self.cameraUI.delegate = delegate;
    self.overLayView.frame = self.cameraUI.cameraOverlayView.frame;
    self.cameraUI.cameraOverlayView = self.overLayView;
    float camHeight = ([[UIScreen mainScreen] bounds].size.height/2)*15/100;
    self.cameraUI.cameraViewTransform = CGAffineTransformTranslate(self.cameraUI.cameraViewTransform, 0, camHeight);
    [controller presentViewController:self.cameraUI animated:YES completion:nil];
    return YES;
}


@end
