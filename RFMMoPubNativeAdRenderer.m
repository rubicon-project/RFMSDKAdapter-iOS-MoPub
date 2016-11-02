//
//  RFMMoPubNativeAdRenderer.m
//  MoPub-RFM Sample
//
//  Created by Rubicon Project on 10/21/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import "RFMMoPubNativeAdRenderer.h"
#import "RFMMoPubNativeAdapter.h"
#import "RFMMoPubNativeRendererSettings.h"
#import "MOPUBNativeVideoAdRendererSettings.h"
#import "MPNativeAdRendererSettings.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPNativeAdRendererImageHandler.h"
#import "MPNativeAdRenderingImageLoader.h"
#import "MPNativeAdRenderer.h"
#import "MPNativeAdRendering.h"
#import "MPNativeAdAdapter.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdError.h"
#import "MPStaticNativeAdRendererSettings.h"


@interface RFMMoPubNativeAdRenderer () <MPNativeAdRendererImageHandlerDelegate>

@property (nonatomic, strong) UIView<MPNativeAdRendering> *adView;
@property (nonatomic, strong) RFMMoPubNativeAdapter<MPNativeAdAdapter> *adapter;
@property (nonatomic) BOOL adViewInViewHierarchy;
@property (nonatomic, strong) Class renderingViewClass;
@property (nonatomic, strong) MPNativeAdRendererImageHandler *rendererImageHandler;

@end


@implementation RFMMoPubNativeAdRenderer

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
    MPNativeAdRendererConfiguration *config = [[MPNativeAdRendererConfiguration alloc] init];
    config.rendererSettings = rendererSettings;
    config.rendererClass = [self class];
    config.supportedCustomEvents = @[@"RFMMoPubNativeCustomEvent"];
    
    return config;
}

- (instancetype)initWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
    if (self = [super init]) {
        RFMMoPubNativeRendererSettings *settings = (RFMMoPubNativeRendererSettings *)rendererSettings;
        _viewSizeHandler = [settings.viewSizeHandler copy];
        _renderingViewClass = settings.renderingViewClass;
        _rendererImageHandler = [MPNativeAdRendererImageHandler new];
        _rendererImageHandler.delegate = self;
    }
    
    return self;
}

- (UIView *)retrieveViewWithAdapter:(id<MPNativeAdAdapter>)adapter error:(NSError **)error {
    if (!adapter) {
        if (error) {
            *error = MPNativeAdNSErrorForRenderValueTypeError();
        }
        
        return nil;
    }
    
    self.adapter = adapter;
    
    [self initAdView];
    
    // Main image
    if ([self shouldLoadMediaView]) {
        UIView *mediaView = [self.adapter mainMediaView];
        mediaView.frame = self.adView.bounds;
        mediaView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        mediaView.userInteractionEnabled = YES;
        
        [self.adView addSubview:mediaView];
    }
    
    // Description
    if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)]) {
        [[self.adView nativeMainTextLabel] setText:[adapter.properties objectForKey:kAdTextKey]];
        [self.adView addSubview:[self.adView nativeMainTextLabel]];
    }
    
    // Title
    if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)]) {
        [[self.adView nativeTitleTextLabel] setText:[adapter.properties objectForKey:kAdTitleKey]];
        [self.adView addSubview:[self.adView nativeTitleTextLabel]];
    }
    
    // Call to action
    if ([self.adView respondsToSelector:@selector(nativeCallToActionTextLabel)] && self.adView.nativeCallToActionTextLabel) {
        [[self.adView nativeCallToActionTextLabel] setText:[adapter.properties objectForKey:kAdCTATextKey]];
        [self.adView addSubview:[self.adView nativeCallToActionTextLabel]];
    }

    // Star rating
    if ([self.adView respondsToSelector:@selector(layoutStarRating:)]) {
        NSNumber *starRatingNum = [adapter.properties objectForKey:kAdStarRatingKey];
        
        if ([starRatingNum isKindOfClass:[NSNumber class]] && starRatingNum.floatValue >= kStarRatingMinValue && starRatingNum.floatValue <= kStarRatingMaxValue) {
            [self.adView layoutStarRating:starRatingNum];
        }
    }
    
    // Ad choices
    if ([self.adapter respondsToSelector:@selector(privacyInformationIconView)] && [self.adView respondsToSelector:@selector(nativePrivacyInformationIconImageView)]) {
        UIView *privacyIconAdView = [self.adapter privacyInformationIconView];
        privacyIconAdView.frame = self.adView.nativePrivacyInformationIconImageView.bounds;
        privacyIconAdView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.adView.nativePrivacyInformationIconImageView.userInteractionEnabled = YES;
        [self.adView.nativePrivacyInformationIconImageView addSubview:privacyIconAdView];
        self.adView.nativePrivacyInformationIconImageView.hidden = NO;
        [self.adView addSubview:[self.adView nativePrivacyInformationIconImageView]];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DAAIconTapped)];
        [self.adView nativePrivacyInformationIconImageView].userInteractionEnabled = YES;
        [[self.adView nativePrivacyInformationIconImageView] addGestureRecognizer:tapRecognizer];
    }
    
    if ([self.adapter respondsToSelector:@selector(defaultActionURL)]) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nativeAdViewTapped)];
        self.adView.userInteractionEnabled = YES;
        [self.adView addGestureRecognizer:tapRecognizer];
    }
    
    return self.adView;
}

- (void)DAAIconTapped {
    if ([self.adapter respondsToSelector:@selector(displayContentForDAAIconTap)]) {
        [self.adapter displayContentForDAAIconTap];
    }
}

- (void)nativeAdViewTapped {
    if ([self.adapter respondsToSelector:@selector(displayContentForNativeAdTap)]) {
        [self.adapter displayContentForNativeAdTap];
    }
}

- (void)adViewWillMoveToSuperview:(UIView *)superview {
    self.adViewInViewHierarchy = (superview != nil);
    
    if (superview) {
        // Icon image
        if ([self.adapter.properties objectForKey:kAdIconImageKey] && [self.adView respondsToSelector:@selector(nativeIconImageView)]) {
            [self.rendererImageHandler loadImageForURL:[NSURL URLWithString:[self.adapter.properties objectForKey:kAdIconImageKey]] intoImageView:[self.adView nativeIconImageView]];
        }
        
        // Main image
        if (!([self.adapter respondsToSelector:@selector(mainMediaView)] && [self.adapter mainMediaView])) {
            if ([self.adapter.properties objectForKey:kAdMainImageKey] && [self.adView respondsToSelector:@selector(nativeMainImageView)]) {
                [self.rendererImageHandler loadImageForURL:[NSURL URLWithString:[self.adapter.properties objectForKey:kAdMainImageKey]] intoImageView:[self.adView nativeMainImageView]];
            }
        }
        
        // Custom assets
        if ([self.adView respondsToSelector:@selector(layoutCustomAssetsWithProperties:imageLoader:)]) {
            // Create a simplified image loader for the ad view to use.
            MPNativeAdRenderingImageLoader *imageLoader = [[MPNativeAdRenderingImageLoader alloc] initWithImageHandler:self.rendererImageHandler];
            [self.adView layoutCustomAssetsWithProperties:self.adapter.properties imageLoader:imageLoader];
        }
    }
}


#pragma mark - MPNativeAdRendererImageHandlerDelegate

- (BOOL)nativeAdViewInViewHierarchy {
    return self.adViewInViewHierarchy;
}

#pragma mark - Private

- (void)initAdView {
    if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)]) {
        self.adView = (UIView<MPNativeAdRendering> *)[[[self.renderingViewClass nibForAd]
                                                       instantiateWithOwner:nil options:nil] firstObject];
    } else {
        self.adView = [[self.renderingViewClass alloc] init];
    }
    
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (BOOL) shouldLoadMediaView {
    return [self.adapter respondsToSelector:@selector(mainMediaView)] && [self.adapter mainMediaView];
}

@end
