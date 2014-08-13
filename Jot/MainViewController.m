#import "MainViewController.h"

#import "JOTMovieRequest.h"

@interface MainViewController()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation MainViewController

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  // Add text field
  self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 30.0f, 300.0f, 30.0f)];
  self.textField.borderStyle = UITextBorderStyleRoundedRect;
  self.textField.delegate = self;
  [self.view addSubview:self.textField];

  // Add button
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button.frame = CGRectMake(110.0f, CGRectGetMaxY(self.textField.frame) + 10, 100.0f, 30.0f);
  [button addTarget:self
             action:@selector(updateSuggestions)
       forControlEvents:UIControlEventTouchUpInside];
  [button setTitle:@"Search" forState:UIControlStateNormal];
  [self.view addSubview:button];

  // Add text view
  self.textView = [[UITextView alloc] init];
  CGFloat yOffset = CGRectGetMaxY(button.frame);
  CGFloat padding = 10.0f;
  self.textView.frame = CGRectMake(padding,
                              yOffset + padding,
                              CGRectGetMaxX(self.view.frame) - (padding * 2),
                              CGRectGetMaxY(self.view.frame) - yOffset - (padding * 2));
  self.textView.layer.borderWidth = 1.0f;
  self.textView.layer.borderColor = [[UIColor grayColor] CGColor];
  self.textView.userInteractionEnabled = NO;
  [self.view addSubview:self.textView];
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

      NSString *resultString = [results componentsJoinedByString:@"\n"];
      dispatch_async(dispatch_get_main_queue(), ^{
          self.textView.text = resultString;
      });
  }];
}

@end
