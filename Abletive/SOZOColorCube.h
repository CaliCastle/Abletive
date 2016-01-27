#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SOZOColorCube : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *colors;

- (void)addColor:(UIColor *)color;
- (UIColor *)meanColor;

@end
