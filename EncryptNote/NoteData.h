//
//  NoteData.h
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoteData : NSObject <NSCoding, NSSecureCoding>

@property (nonatomic, copy) NSString     * noteName;
@property (nonatomic, copy) NSString     * noteContent;

- (instancetype)init;
- (instancetype)initWithNoteName:(NSString *)noteName;
- (instancetype)initWithNoteName:(NSString *)noteName noteContent:(NSString *)noteContent;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end

NS_ASSUME_NONNULL_END
