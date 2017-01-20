// Copyright (c) 2015 eeGeo. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import "EegeoCustomAnnotationView.h"
#import "Establishment.h"

@implementation EegeoCustomAnnotationView

- (void)initWithAnnotation:(NSObject<EGAnnotation>*)annotation
{
    [super initWithAnnotation:annotation];
    
    [self addObserver:self
           forKeyPath:@"selected"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:nil];
}

- (void) dealloc
{
    [self removeObserver:self forKeyPath:@"selected"];
    
    [self.title release];
    [self.ratingDate release];
    [self.businessType release];
    
    [self.imageView release];
    
    [super dealloc];
}

- (void)setAnnotationViewLabelsFromAnnotation
{
    [super setAnnotationViewLabelsFromAnnotation];
    Establishment* establishment = (Establishment*)self.annotation;
    [self.title setText:establishment.businessName];
    [self.businessType setText:establishment.businessType];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.cornerRadius = 16;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = 16;
    self.layer.shadowOpacity = 0.8f;
    self.layer.shadowColor = [[UIColor grayColor] CGColor];
    
//    const int margin = 16;
//    
//    self.bounds = CGRectMake(margin,
//                             margin,
//                             self.imageView.bounds.size.width + margin,
//                             self.imageView.bounds.size.height + self.title.bounds.size.height);
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

- (void)handleSelectedChanged
{
    if(self.selected)
    {

    }
    else
    {
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    self.selected = selected;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if(object == self)
    {
        if ([keyPath isEqual:@"selected"])
        {
            [self handleSelectedChanged];
        }
    }
}

@end
