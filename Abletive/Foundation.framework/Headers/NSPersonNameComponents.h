/*	NSPersonNameComponents.h
	Copyright (c) 2015, Apple Inc. All rights reserved.
 */

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE(10_11, 9_0)
@interface NSPersonNameComponents : NSObject <NSCopying, NSSecureCoding>{
@private
    id _private;
}

/* Name bestowed upon an individual by one's parents, e.g. Johann */
@property (copy, nullable) NSString *givenName;

/* Name passed from one generation to another to indicate lineage, e.g. Bach  */
@property (copy, nullable) NSString *familyName;

/* Secondary given name chosen to differentiate those with the same first name, e.g. Sebastian  */
@property (copy, nullable) NSString *middleName;

/* Pre-nominal letters denoting title, salutation, or honorific, e.g. Dr., Mrs. */
@property (copy, nullable) NSString *namePrefix;

/* Post-nominal letters denoting degree, accreditation, or other honor, e.g. Jr., Ph.D. */
@property (copy, nullable) NSString *nameSuffix;

/* Name substituted for full proper name for the purposes of familiarity, e.g. "Yogi" for "Lawrence Peter Berra" */
@property (copy, nullable) NSString *nickname;

/* Each element of the phoneticRepresentation should correspond to an element of the original PersonNameComponents instance.
   The phoneticRepresentation of the phoneticRepresentation object itself will be ignored. nil by default, must be instantiated.
*/
@property (copy, nullable) NSPersonNameComponents *phoneticRepresentation;

@end

NS_ASSUME_NONNULL_END
