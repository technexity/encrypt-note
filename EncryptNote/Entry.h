//
//  Entry.h
//  EncryptNote
//
//  Created by Nam Tran on 09/08/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NoteMetadata;

@interface Entry : NSObject

@property (strong) NSURL         * fileURL;
@property (strong) NoteMetadata    * metadata;
@property (strong) NSFileVersion   * version;

- (instancetype)initWithFileURL:(NSURL *)fileURL metadata:(NoteMetadata *)metadata version:(NSFileVersion *)version;

@end

NS_ASSUME_NONNULL_END
