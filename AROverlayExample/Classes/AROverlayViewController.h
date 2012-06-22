#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"
#import <AudioToolbox/AudioConverter.h>

namespace synth { class Controller; }
namespace synth { class Envelope; }
namespace synth { class LFO; }
namespace synth { class Oscillator; }
namespace synth { class Note; }
namespace synth { class LowPass; }



// here we'll need #import MobileSynth(or whatever it's called)
#import "AudioOutput.h"
@interface AROverlayViewController : UIViewController <SampleGenerator> {
    @private
    AudioOutput* output;
    synth::Controller* controller_;
   
    AudioStreamBasicDescription outputFormat;
    
}

@property (retain) CaptureSessionManager *captureManager;
@property (nonatomic, retain) UILabel *scanningLabel;


- (OSStatus)generateSamples:(AudioBufferList*)buffers;


@end
