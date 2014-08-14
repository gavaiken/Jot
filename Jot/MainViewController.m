#import "MainViewController.h"

#import "JOTMovieRequest.h"

@interface MainViewController()<UITextFieldDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
// Views
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UICollectionView *collectionView;
// State
@property (nonatomic, strong) NSArray *searchResults;
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
  [self.collectionView registerClass:[UICollectionViewCell class]
          forCellWithReuseIdentifier:kJOTResultCellReuseId];
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
  JOTMovieRequest *movieRequest = [[JOTMovieRequest alloc] init];
  NSString *searchText = self.textField.text;
  if (searchText.length == 0) {
    return;
  }

  [movieRequest requestMovieSuggestionsForText:searchText
                                withCompletion:^(NSArray *results, NSError *error) {
      if (error) {
        NSLog(@"Failed to obtain results for '%@' - Error: %@", searchText, error);
      }

      dispatch_async(dispatch_get_main_queue(), ^{
          self.searchResults = results;
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
  UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kJOTResultCellReuseId
                                                             forIndexPath:indexPath];
  cell.backgroundColor = [UIColor whiteColor];
  return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)collectionView:(UICollectionView *)collectionView
    didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return CGSizeMake(100, 100);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
  return UIEdgeInsetsZero;
}

@end
