//
//  NoteMetadata.h
//  EncryptNote
//
//  Created by Nam Tran on 09/08/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoteMetadata : NSObject<NSCoding, NSSecureCoding>

@property (nonatomic, copy) NSString     * noteName;
@property (nonatomic, assign) BOOL        requireUnlocked;
@property (nonatomic, copy) NSDate      * createdDate;

- (instancetype)init;
- (instancetype)initWithNoteName:(NSString *)noteName;
- (instancetype)initWithNoteName:(NSString *)noteName requireUnlocked:(BOOL)requireUnlocked;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end

NS_ASSUME_NONNULL_END
