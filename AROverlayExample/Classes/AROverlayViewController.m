#import "AROverlayViewController.h"

#define BETA 3.1415 / 4
#define NLINES 10

@interface AROverlayViewController ()
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end

@implementation AROverlayViewController

@synthesize captureManager;
@synthesize scanningLabel;

- (void)viewDidLoad {
  
	[self setCaptureManager:[[[CaptureSessionManager alloc] init] autorelease]];
  
	[[self captureManager] addVideoInputFrontCamera:NO]; // set to YES for Front Camera, No for Back camera
  
  [[self captureManager] addStillImageOutput];
  
	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = [[[self view] layer] bounds];
    [[[self captureManager] previewLayer] setBounds:layerRect];
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
	[[[self view] layer] addSublayer:[[self captureManager] previewLayer]];
  
  //UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlaygraphic.png"]];
  //[overlayImageView setFrame:CGRectMake(30, 100, 260, 200)];
  //[[self view] addSubview:overlayImageView];
  //[overlayImageView release];
  
  UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [overlayButton setImage:[UIImage imageNamed:@"scanbutton.png"] forState:UIControlStateNormal];
  [overlayButton setFrame:CGRectMake(130, 320, 60, 30)];
  [overlayButton addTarget:self action:@selector(scanButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [[self view] addSubview:overlayButton];
  
  UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 150, 30)];
  [self setScanningLabel:tempLabel];
  [tempLabel release];
	[scanningLabel setBackgroundColor:[UIColor clearColor]];
	[scanningLabel setFont:[UIFont fontWithName:@"Courier" size: 18.0]];
	[scanningLabel setTextColor:[UIColor redColor]]; 
	[scanningLabel setText:@"DD"];
  [scanningLabel setHidden:YES];
	[[self view] addSubview:scanningLabel];	
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectDistance) name:kImageCapturedSuccessfully object:nil];
  
	[[captureManager captureSession] startRunning];
}

- (NSArray*)getRGBAsAtX:(int)xx andY:(int)yy 
{

    
    
    // First get the image into your data buffer
    CGImageRef imageRef = [[[self captureManager] stillImage] CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    NSUInteger count = width * height; 
    NSUInteger lines = NLINES / 2;
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];


    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    int start = (height/2) - lines;
    int end = (height/2) + lines;
    int byteIndex = (bytesPerRow * start) + 00 * bytesPerPixel;
    //int byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel;

    NSLog(@"s: %d e: %d", start, end);
    for (int ii = start*width ; ii < (end+1)*width ; ++ii)
    {
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        byteIndex += 4;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }

    free(rawData);
    
    return result;
}



- (void)scanButtonPressed {
  [[self captureManager] captureStillImage];
}

- (void)detectDistance 
{
    NSLog(@"about to detect Distance ");

    CGFloat curRed, curGreen, curBlue, curAlpha;
    CGFloat mostRed;
    // Import detect distance code here!
    
 // UIImageWriteToSavedPhotosAlbum([[self captureManager] stillImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
     
    [[self scanningLabel] setHidden:NO];
    double d, s;
    double alpha, beta;
    
    
    double minAngle, maxAngle;
    int xBright, yBright;
    
    beta = BETA;

    NSArray * RGBs = [self getRGBAsAtX: 0 andY: 0];
    // Find brightest (red or green) point, perhaps using openCV
    xBright = 0;
    
    yBright = 0;
    int i = 0;
    mostRed = 0.0;
    CGImageRef imageRef = [[[self captureManager] stillImage] CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    for(UIColor* RGB in RGBs){
        i++;
        [RGB getRed:&curRed green:&curGreen blue:&curBlue alpha:&curAlpha];
        curRed = curRed - 1*(curGreen + curBlue)/2;
        if(curRed > mostRed){
            mostRed = curRed;
            xBright = i % width;
            yBright = floor(i/width);
            
        }
        
    }



// Highlight point with some marker (cross?)

// Calculate to find distance


// Assume the image map is roughly linear, for now
// Assumes laser pointer is to the left of the image, in screen coordinates
alpha = minAngle + xBright * maxAngle;


// with 
// Separation S between camera and laser 
// Alpha as angle in the laser pointer (measured with 0 when the laser pointer aims directly toward the camera)
// Beta as angle of the light in the camera (measured identically)
d = s * tan(alpha)*tan(beta) / (tan(beta)-tan(alpha));

    [scanningLabel setText:[NSString localizedStringWithFormat:@"%2d, %4.4f, %2.0f", 
                            xBright, d, mostRed]];
    NSLog(@"Done detecting Distance ");
    
	[[self scanningLabel] setHidden:NO];
// Set label to brightness, point, and distance

//[self performSelector:@selector(hideLabel:) withObject:[self scanningLabel] afterDelay:2];
    [self performSelector:@selector(scanButtonPressed) withObject: nil afterDelay:0.1];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
  if (error != NULL) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
  }
  else {
    [[self scanningLabel] setHidden:YES];
  }
}




- (void)hideLabel:(UILabel *)label {
	[label setHidden:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  [captureManager release], captureManager = nil;
  [scanningLabel release], scanningLabel = nil;
  [super dealloc];
}

@end

