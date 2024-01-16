#import <Cordova/CDV.h>
@class UIScoplanCamera;

@interface ScoplanCamera : CDVPlugin {
    UIScoplanCamera *mCamview;
    NSMutableArray *mpictures;
    CDVInvokedUrlCommand *mcallback;
}

- (void)takePictures:(CDVInvokedUrlCommand*)command;
- (void)insertPicture:(NSString*)url;
- (void)dismissCam;
@end