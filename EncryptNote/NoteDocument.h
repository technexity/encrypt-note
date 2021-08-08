//
//  NoteDocument.h
//  EncryptNote
//
//  Created by Nam Tran on 08/08/2021.
//

#import <UIKit/UIKit.h>

@class Note;

NS_ASSUME_NONNULL_BEGIN

@interface NoteDocument : UIDocument

@property (nonatomic, strong) Note * note;

@end

NS_ASSUME_NONNULL_END
