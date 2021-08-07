//
//  Note.h
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Note : NSObject

@property (nonatomic, assign) NSInteger uuid;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, assign) BOOL locked;

@end

NS_ASSUME_NONNULL_END
