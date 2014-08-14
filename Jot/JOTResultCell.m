#import "JOTResultCell.h"

@implementation JOTResultCell

#pragma mark - UICollectionViewCell overrides

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor whiteColor];
    _labelView = [[UILabel alloc] initWithFrame:self.bounds];
    [self addSubview:_labelView];
  }
  return self;
}

@end
