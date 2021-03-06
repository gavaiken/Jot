#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol JOTMovieRequestDelegate
- (void)retrievedImage:(UIImage *)image forResultAtIndex:(int)index;
@end

@interface JOTMovieRequest : NSObject
@property (nonatomic, weak) id<JOTMovieRequestDelegate> delegate;
- (void)requestMovieSuggestionsForText:(NSString *)text
                        withCompletion:(void (^)(NSArray *results, NSError *error))completion;
@end
