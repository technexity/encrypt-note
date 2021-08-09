//
//  NoteDocument.h
//  EncryptNote
//
//  Created by Nam Tran on 08/08/2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NoteMetadata;
@class NoteData;

@interface NoteDocument : UIDocument

@property (nonatomic, strong, readonly) NoteMetadata * noteMetadata;
@property (nonatomic, strong, readonly) NoteData    * noteData;

@property (nonatomic, strong) NSString            * noteName;
@property (nonatomic, assign) BOOL                 requireUnlocked;
@property (nonatomic, strong) NSString            * noteContent;

@property (nonatomic, strong, readonly) NSString    * description;

@end

NS_ASSUME_NONNULL_END
