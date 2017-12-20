
# ifndef __UISTYLIZEDTEXTEDITOR_51BA67C4E3EA4D47B10B009C5E457A80_H_INCLUDED
# define __UISTYLIZEDTEXTEDITOR_51BA67C4E3EA4D47B10B009C5E457A80_H_INCLUDED

@protocol UIStylizedTextEditorDelegate;

@interface UIStylizedTextEditor : UIScrollViewExt

@property (nonatomic, assign) id<UIStylizedTextEditorDelegate> delegate;
@property (nonatomic, retain) NSStylizedString *string;

@end

@protocol UIStylizedTextEditorDelegate <UIStylizedStringDelegate>

@end

# endif
