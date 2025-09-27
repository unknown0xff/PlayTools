//
//  UIWindow.m
//  PlayTools
//
// disable warnings
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

// os
#import <UIKit/UIKit.h>

// objc
#import <objc/message.h>

// project
#import "StanHook.h"

@interface DTSettings : NSObject

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, assign) CGFloat safeAreaTop;
@property (nonatomic, assign) CGFloat safeAreaBottom;
@property (nonatomic, assign) CGFloat safeAreaLeft;
@property (nonatomic, assign) CGFloat safeAreaRight;

+ (instancetype)sharedInstance;

@end


@implementation DTSettings

- (instancetype) init {
    self = [super init];
    if (self) {
        // iPhone 15 Pro Max
        self.width = 430;
        self.height = 932;
        self.scale = 3.0;
        
        self.safeAreaTop = 59.0;
        self.safeAreaBottom = 34.0;
        self.safeAreaLeft = 0.0;
        self.safeAreaRight = 0.0;
    }
    return self;
}


+ (instancetype)sharedInstance {
    static DTSettings *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DTSettings alloc] init];
    });
    return instance;
}

@end

Xclass(UIWindow)

/*- (UIEdgeInsets)safeAreaInsets {
    DTSettings *settings = [DTSettings sharedInstance];
    
    UIEdgeInsets insets = {
        .top = settings.safeAreaTop,
        .bottom = settings.safeAreaBottom,
        .left = settings.safeAreaLeft,
        .right = settings.safeAreaRight
    };
    
    return insets;
}*/

- (void)makeKeyAndVisible {
    //# NSLog(@"makeKeyAndVisible");
    
    UIScene *scene = [UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
    
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        DTSettings *settings = [DTSettings sharedInstance];
        windowScene.sizeRestrictions.minimumSize = CGSizeMake(settings.width, settings.height);
        windowScene.sizeRestrictions.maximumSize = CGSizeMake(settings.width, settings.height);
    }
        
    [Xself makeKeyAndVisible];
}

Xend


Xclass(NSWindow)

- (void)__close {
    //# NSLog(@"NSWindow _close %@", self);
    exit(0);
}

- (void)__removeResizeableMask {
    NSObject *window = (NSObject *)self;
    NSNumber *styleMaskNum = [window performSelector:@selector(valueForKey:) withObject:@"styleMask"];
    NSUInteger styleMask = [styleMaskNum unsignedIntegerValue];
    NSUInteger resizableMask = 1 << 3;
    styleMask = styleMask & ~resizableMask;
    [window performSelector:@selector(setValue:forKey:) withObject:@(styleMask) withObject:@"styleMask"];
}

- (void)becomeKeyWindow {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self __removeResizeableMask];
        
        NSObject *window = (NSObject *)self;
        NSObject *btnClose = [window performSelector:@selector(standardWindowButton:) withObject:0];
        
        //# [btn performSelector:@selector(setTarget:) withObject:self];
        //# [btn performSelector:@selector(setAction:) withObject:(id)@selector(setAction:)];
        ((void(*)(id, SEL, id))objc_msgSend)(btnClose, @selector(setTarget:), self);
        ((void(*)(id, SEL, SEL))objc_msgSend)(btnClose, @selector(setAction:), @selector(__close));
        
    });
    
    [Xself becomeKeyWindow];
}

Xend
