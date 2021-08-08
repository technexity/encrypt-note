//
//  MasterNoteViewController.h
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import <UIKit/UIKit.h>

@class Note;

NS_ASSUME_NONNULL_BEGIN

@interface MasterNoteViewController : UIViewController

- (void)saveNote:(Note *)note;

@end

NS_ASSUME_NONNULL_END
