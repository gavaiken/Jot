#import "JOTMovieRequest.h"

@implementation JOTMovieRequest

static NSString * const kJOTErrorDomain = @"JOTErrorDomain";
static NSString * const kIMDBSuggestURLFormat = @"http://sg.media-imdb.com/suggests/%@/%@.json";

- (void)requestMovieSuggestionsForText:(NSString *)text
                        withCompletion:(void (^)(NSArray *results, NSError *error))completion {
  if (!completion || !(text.length > 0)) {
    return;
  }

  // Query parameters must be lowercase.
  text = [[text lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
  NSString *URLString =
      [NSString stringWithFormat:kIMDBSuggestURLFormat, [text substringToIndex:1], text];
  NSURL *URL = [NSURL URLWithString:URLString];
  NSURLRequest *request = [NSURLRequest requestWithURL:URL];
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDataTask *task =
      [session dataTaskWithRequest:request
                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      NSHTTPURLResponse *httpResponse;
      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        httpResponse = (NSHTTPURLResponse *)response;
      }

      if (!(httpResponse && httpResponse.statusCode == 200)) {
        completion(nil, [JOTMovieRequest genericError]);
        return;
      }

      NSString *jsonpString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

      // Strip javascript
      NSRange jsonStart = [jsonpString rangeOfString:@"("];
      jsonStart.location++;
      NSRange jsonEnd = [jsonpString rangeOfString:@")" options:NSBackwardsSearch];
      jsonEnd.location--;

      NSString *jsonString;
      if (jsonStart.length > 0 && jsonEnd.length > 0) {
        NSRange range = NSUnionRange(jsonStart, jsonEnd);
        jsonString = [jsonpString substringWithRange:range];
      }

      if (!jsonString) {
        completion(nil, [JOTMovieRequest genericError]);
        return;
      }

      NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
      NSError *deserializationError;
      id object = [NSJSONSerialization JSONObjectWithData:jsonData
                                                  options:0
                                                    error:&deserializationError];
      if (error) {
        completion(nil, error);
        return;
      }

      if (![object isKindOfClass:[NSDictionary class]]) {
        completion(nil, [JOTMovieRequest genericError]);
        return;
      }

      NSDictionary *resultsDict = (NSDictionary *)object;
      NSArray *results = [self toArrayFromResultsDict:resultsDict];
      completion(results, nil);
  }];

  // Start the request
  [task resume];
}

- (NSArray *)toArrayFromResultsDict:(NSDictionary *)resultsDict {
  NSMutableArray *results = [[NSMutableArray alloc] init];
  if (!resultsDict) {
    return results;
  }

  if (![resultsDict[@"d"] isKindOfClass:[NSArray class]]) {
    return results;
  }

  NSArray *resultsArray = resultsDict[@"d"];
  for (NSDictionary *resultDict in resultsArray) {
    [results addObject:resultDict[@"l"]];
  }

  return results;
}

+ (NSError *)genericError {
  return [NSError errorWithDomain:kJOTErrorDomain
                             code:0
                         userInfo:nil];
}

@end
