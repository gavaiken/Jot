#import "JOTResultCell.h"

@implementation JOTResultCell

#pragma mark - UICollectionViewCell overrides

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor whiteColor];

    // Create label
    CGRect labelFrame = CGRectOffset(self.bounds, 50, 0);
    labelFrame.size.width -= 50;
    _labelView = [[UILabel alloc] initWithFrame:labelFrame];
    [self addSubview:_labelView];

    // Create image view
    CGRect imageFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, 40, 60);
    _imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    _imageView.backgroundColor = [UIColor blueColor];
    [self addSubview:_imageView];
  }
  return self;
}

@end
