//
//  MasterNoteViewController.h
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NoteData;
@class Entry;
@class NoteEditorViewController;

@interface MasterNoteViewController : UIViewController

- (void)detailViewControllerDidClose:(NoteEditorViewController *)detailViewCtrl;
- (void)deleteEntry:(Entry *)entry;

@end

NS_ASSUME_NONNULL_END
