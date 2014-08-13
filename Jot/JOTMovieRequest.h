#import <Foundation/Foundation.h>

@interface JOTMovieRequest : NSObject

- (void)requestMovieSuggestionsForText:(NSString *)text
                        withCompletion:(void (^)(NSArray *results, NSError *error))completion;

@end
