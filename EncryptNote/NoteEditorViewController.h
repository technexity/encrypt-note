//
//  NoteEditorViewController.h
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import <UIKit/UIKit.h>
#import "NoteDocument.h"
#import "Entry.h"

@class MasterNoteViewController;

NS_ASSUME_NONNULL_BEGIN

@interface NoteEditorViewController : UIViewController

@property (nonatomic, strong) NoteDocument * document;
@property (nonatomic, strong) Entry * entry;

@property (nonatomic, assign) BOOL createNew;
@property (nonatomic, weak) MasterNoteViewController * viewController;

@end

NS_ASSUME_NONNULL_END
