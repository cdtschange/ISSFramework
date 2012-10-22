//
//  PSTCollectionViewCell.h
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewCommon.h"

@class PSTCollectionViewLayout, PSTCollectionView, PSTCollectionViewLayoutAttributes;

@interface PSTCollectionReusableView : UIView

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;

// Override in subclasses. Called before instance is returned to the reuse queue.
- (void)prepareForReuse;

// Apply layout attributes on cell.
- (void)applyLayoutAttributes:(PSTCollectionViewLayoutAttributes *)layoutAttributes;

- (void)willTransitionFromLayout:(PSTCollectionViewLayout *)oldLayout toLayout:(PSTCollectionViewLayout *)newLayout;
- (void)didTransitionFromLayout:(PSTCollectionViewLayout *)oldLayout toLayout:(PSTCollectionViewLayout *)newLayout;

@end

@interface PSTCollectionReusableView (Internal)
@property (nonatomic, unsafe_unretained) PSTCollectionView *collectionView;
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic, strong, readonly) PSTCollectionViewLayoutAttributes *layoutAttributes;
@end


// We need to be careful and keep the same ivar layout as UICollectionViewCell,
// else we might crash with after using class_setSuperclass if subclasses change the ivar layout.
@interface PSTCollectionViewCell : PSTCollectionReusableView {
    UILongPressGestureRecognizer *_menuGesture; // unused
    id _selectionSegueTemplate; // unused.
    id _highlightingSupport; // Apple uses UICellHighlightingSupport. Currently unused.
    struct {
        unsigned int selected:1;
        unsigned int highlighted:1;
        // currently unused
        unsigned int showingMenu:1;
        unsigned int clearSelectionWhenMenuDisappears:1;
        unsigned int waitingForSelectionAnimationHalfwayPoint:1;
    } _collectionCellFlags;
}

@property (nonatomic, readonly) UIView *contentView; // add custom subviews to the cell's contentView

// Cells become highlighted when the user touches them.
// The selected state is toggled when the user lifts up from a highlighted cell.
// Override these methods to provide custom PS for a selected or highlighted state.
// The collection view may call the setters inside an animation block.
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

// The background view is a subview behind all other views.
// If selectedBackgroundView is different than backgroundView, it will be placed above the background view and animated in on selection.
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *selectedBackgroundView;

@end
