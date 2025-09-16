#include "GSVolBar.h"

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

// Флаг включения/отключения
static BOOL volumeBarEnabled = YTMU(@"YTMUltimateIsEnabled") && YTMU(@"volBar");

@interface YTMWatchView: UIView
@property (readonly, nonatomic) BOOL isExpanded;
@property (nonatomic, strong) UIView *tabView;
@property (nonatomic) long long currentLayout;

- (void)updateVolBarVisibility;
@end

#import <objc/runtime.h>

%hook YTMWatchView

- (void)setVolumeBar:(GSVolBar *)bar {
    objc_setAssociatedObject(self, @selector(volumeBar), bar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GSVolBar *)volumeBar {
    return objc_getAssociatedObject(self, @selector(volumeBar));
}

- (instancetype)initWithColorScheme:(id)scheme {
    self = %orig;

    if (self && volumeBarEnabled) {
        self.volumeBar = [[GSVolBar alloc] initWithFrame:CGRectMake(
            self.frame.size.width / 2 - (self.frame.size.width / 2) / 2,
            0,
            self.frame.size.width / 2,
            25
        )];

        [self addSubview:self.volumeBar];
    }

    return self;
}

- (void)layoutSubviews {
    %orig;

    if (volumeBarEnabled) {
        self.volumeBar.frame = CGRectMake(
            self.frame.size.width / 2 - (self.frame.size.width / 2) / 2,
            CGRectGetMinY(self.tabView.frame) - 25,
            self.frame.size.width / 2,
            25
        );
    }
}

- (void)updateColorsAfterLayoutChangeTo:(long long)arg1 {
    %orig;

    if (volumeBarEnabled) {
        [self updateVolBarVisibility];
    }
}

- (void)updateColorsBeforeLayoutChangeTo:(long long)arg1 {
    %orig;

    if (volumeBarEnabled) {
        self.volumeBar.hidden = YES;
    }
}

%new
- (void)updateVolBarVisibility {
    if (volumeBarEnabled) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.volumeBar.hidden = !(self.isExpanded && self.currentLayout == 2);
        });
    }
}

%end
