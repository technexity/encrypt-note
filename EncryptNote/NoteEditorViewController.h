//
//  NoteEditorViewController.h
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@class MasterNoteViewController;

NS_ASSUME_NONNULL_BEGIN

@interface NoteEditorViewController : UIViewController

@property (nonatomic, weak) MasterNoteViewController * viewController;

@property (nonatomic, strong) Note * note;

@end

NS_ASSUME_NONNULL_END
