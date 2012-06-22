#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"
// here we'll need #import MobileSynth(or whatever it's called)
@interface AROverlayViewController : UIViewController {
    
}

@property (retain) CaptureSessionManager *captureManager;
@property (nonatomic, retain) UILabel *scanningLabel;

@end
