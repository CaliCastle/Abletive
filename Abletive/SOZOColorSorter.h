#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SOZOColorSorter : NSObject

+ (instancetype)colorSorterWithGranularity:(NSUInteger)numberOfPartitions;

- (NSArray *)sortColors:(NSArray *)colors;

@end
