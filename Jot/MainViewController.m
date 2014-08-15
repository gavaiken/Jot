#import "MainViewController.h"

#import "JOTMovieRequest.h"
#import "JOTResultCell.h"

@interface MainViewController()<UITextFieldDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, JOTMovieRequestDelegate>
// Views
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UICollectionView *collectionView;
// State
@property (nonatomic, strong) JOTMovieRequest *movieRequest;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSMutableDictionary *searchResultImageDict;
@end

@implementation MainViewController

static NSString * const kJOTResultCellReuseId = @"JOTResultCellReuseId";

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  // Add text field
  self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 30.0f, 300.0f, 30.0f)];
  self.textField.borderStyle = UITextBorderStyleRoundedRect;
  self.textField.delegate = self;
  [self.textField addTarget:self
                     action:@selector(updateSuggestions)
           forControlEvents:UIControlEventEditingChanged];
  [self.view addSubview:self.textField];

  // Add collection view
  CGFloat yOffset = CGRectGetMaxY(self.textField.frame);
  CGFloat padding = 10.0f;
  CGRect collectionViewFrame = CGRectMake(padding,
                                          yOffset + padding,
                                          CGRectGetMaxX(self.view.frame) - (padding * 2),
                                          CGRectGetMaxY(self.view.frame) - yOffset - (padding * 2));
  UICollectionViewLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
  self.collectionView =
      [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:flowLayout];
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
  [self.collectionView registerClass:[JOTResultCell class]
          forCellWithReuseIdentifier:kJOTResultCellReuseId];
  self.collectionView.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:self.collectionView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  NSLog(@"didReceiveMemoryWarning");
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  // Do not allow line breaks
  return NO;
}

#pragma mark - Button

- (void)updateSuggestions {
  _movieRequest = [[JOTMovieRequest alloc] init];
  _movieRequest.delegate = self;
  NSString *searchText = self.textField.text;
  if (searchText.length == 0) {
    return;
  }

  [_movieRequest requestMovieSuggestionsForText:searchText
                                 withCompletion:^(NSArray *results, NSError *error) {
      if (error) {
        NSLog(@"Failed to obtain results for '%@' - Error: %@", searchText, error);
        return;
      }

      dispatch_async(dispatch_get_main_queue(), ^{
          self.searchResults = results;
          self.searchResultImageDict = [NSMutableDictionary dictionary];
          [self.collectionView reloadData];
      });
  }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
  return [self.searchResults count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
  return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  JOTResultCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kJOTResultCellReuseId
                                                      forIndexPath:indexPath];
  NSString *result = self.searchResults[indexPath.row];
  cell.labelView.text = result;
  UIImage *image = self.searchResultImageDict[result];
  cell.imageView.image = image;
  return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"Selected: %ld", (long)indexPath.row);
}

- (void)collectionView:(UICollectionView *)collectionView
    didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return CGSizeMake(self.collectionView.bounds.size.width, 60);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
  return UIEdgeInsetsZero;
}

#pragma mark - JOTMovieRequestDelegate

- (void)retrievedImage:(UIImage *)image forResultAtIndex:(int)index {
  NSString *result = self.searchResults[index];
  self.searchResultImageDict[result] = image;
  NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
  });
}

@end
