//
//  Note.h
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Note : NSObject <NSCoding, NSSecureCoding>

@property (nonatomic, assign) NSInteger     noteId;
@property (nonatomic, copy) NSString     * noteName;
@property (nonatomic, copy) NSString     * noteText;
@property (nonatomic, assign) BOOL         requireUnlocked;
@property (nonatomic, copy) NSDate      * createdDate;

- (instancetype)init;
- (instancetype)initWithNoteName:(NSString *)noteName;
- (instancetype)initWithNoteName:(NSString *)noteName requireUnlocked:(BOOL)requireUnlocked;
- (instancetype)initWithNoteName:(NSString *)noteName noteText:(NSString *)noteText requireUnlocked:(BOOL)requireUnlocked;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end

NS_ASSUME_NONNULL_END
