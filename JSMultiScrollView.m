//
//  JSMultiScrollView.m
//  StackOverflow
//
//  Created by Justin Saletta on 9/12/14.
//  Copyright (c) 2014 jsdodgers. All rights reserved.
//

#import "JSMultiScrollView.h"


@interface JSScrollSubview : NSObject

@property (nonatomic, strong) UIView *subview;
//@property (nonatomic) float changedSize;
@property (nonatomic) CGSize userSetContentSize;
@property (nonatomic) CGRect userSetFrame;
@property (nonatomic, strong) JSScrollSubview *previous;
@property (nonatomic, strong) JSScrollSubview *next;
@property (nonatomic) BOOL multiScrolls;
@property (nonatomic, strong) UIPanGestureRecognizer *gesture;
@property (nonatomic) int shouldSetFrame;
@property (nonatomic) int shouldSetContentSize;

- (id)initWithSubview:(UIView *)subview;

@end

@implementation JSScrollSubview

- (id)initWithSubview:(UIView *)subview {
	if ((self = [self init])) {
		_subview = subview;
		_shouldSetFrame = 0;
		_shouldSetContentSize = 0;
		_userSetFrame = subview.frame;
		if ([subview respondsToSelector:@selector(contentSize)]) {
			_userSetContentSize = [[subview valueForKeyPath:NSStringFromSelector(@selector(contentSize))] CGSizeValue];
		}
		if ([subview isKindOfClass:[UIScrollView class]]) _multiScrolls = YES;
	}
	return self;
}

@end

@interface JSMultiScrollView ()

@property (nonatomic, strong) UIScrollView *containerScrollView;
@property (nonatomic, weak) id<UIScrollViewDelegate> realDelegate;
@property (nonatomic, strong) JSScrollSubview *topMostView;
@property (nonatomic, strong) JSScrollSubview *bottomMostView;
@property (nonatomic) CGSize userSetContentSize;
@property (nonatomic) BOOL drawn;
@property (nonatomic) BOOL setFakeOffset;
@property (nonatomic) CGPoint fakeOffset;
@end

@implementation JSMultiScrollView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[super setDelegate:self];
		self.containerScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
		[self.containerScrollView setScrollsToTop:NO];
		[self.containerScrollView setBackgroundColor:[UIColor clearColor]];
		[self.containerScrollView removeGestureRecognizer:self.containerScrollView.panGestureRecognizer];
		[self.containerScrollView addGestureRecognizer:self.panGestureRecognizer];
		[super addSubview:self.containerScrollView];
	}
	return self;
}

- (void)addSubview:(UIView *)view multiScrolling:(BOOL)multiScrolling {
	[self addSubview:view];
	[self setMultiScrolling:multiScrolling forView:view];
}

- (void)addSubview:(UIView *)view {
	NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
	NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
	NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
	[array removeObject:@""];
	if (![[array objectAtIndex:3] isEqualToString:@"<redacted>"]) {
		[self.containerScrollView addSubview:view];
		[self setMultiScrollValuesForView:view];
	}
	else {
		[super addSubview:view];
	}
	[self setNeedsLayout];
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
	NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
	NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
	NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
	[array removeObject:@""];
	if (![[array objectAtIndex:3] isEqualToString:@"<redacted>"]) {
		[self.containerScrollView insertSubview:view aboveSubview:siblingSubview];
		[self setMultiScrollValuesForView:view];
	}
	else {
		[super insertSubview:view aboveSubview:siblingSubview];
	}
	[self setNeedsLayout];
}


- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
	NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
	NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
	NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
	[array removeObject:@""];
	if (![[array objectAtIndex:3] isEqualToString:@"<redacted>"]) {
		[self.containerScrollView insertSubview:view atIndex:index];
		[self setMultiScrollValuesForView:view];
	}
	else {
		[super insertSubview:view atIndex:index];
	}
	[self setNeedsLayout];
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
	NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
	NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
	NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
	[array removeObject:@""];
	if (![[array objectAtIndex:3] isEqualToString:@"<redacted>"]) {
		[self.containerScrollView insertSubview:view belowSubview:siblingSubview];
		[self setMultiScrollValuesForView:view];
	}
	else {
		[super insertSubview:view belowSubview:siblingSubview];
	}
	[self setNeedsLayout];
}


- (void)setMultiScrollValuesForView:(UIView *)view {
	JSScrollSubview *s = [[JSScrollSubview alloc] initWithSubview:view];
	if (!self.topMostView) {
		self.topMostView = s;
		if (!self.bottomMostView)
			self.bottomMostView = self.topMostView;
	}
	else {
		JSScrollSubview *s2 = self.topMostView;
		BOOL inserted = NO;
		while (s2) {
			if (view.frame.origin.y < s2.subview.frame.origin.y) {
				s2.previous.next = s;
				s.previous = s2.previous;
				s2.previous = s;
				s.next = s2;
				if (s2==self.topMostView) self.topMostView = s;
				inserted = YES;
				break;
			}
			s2 = s2.next;
		}
		if (!inserted) {
			self.bottomMostView.next = s;
			s.previous = self.bottomMostView;
			self.bottomMostView = s;
		}
	}
	if ([view isKindOfClass:[UIScrollView class]]) {
		UIScrollView *sv = (UIScrollView *)view;
		s.gesture = sv.panGestureRecognizer;
		if ([sv isKindOfClass:[JSMultiScrollView class]]) {
			JSMultiScrollView *s = (JSMultiScrollView *)sv;
			[s.containerScrollView removeGestureRecognizer:sv.panGestureRecognizer];
		}
		[sv removeGestureRecognizer:sv.panGestureRecognizer];
		[sv setScrollsToTop:NO];
	}
	if ([view respondsToSelector:@selector(frame)])
		[view addObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
	if ([view respondsToSelector:@selector(contentSize)])
		[view addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
	if ([view respondsToSelector:@selector(superview)])
		[view addObserver:self forKeyPath:NSStringFromSelector(@selector(superview)) options:0 context:NULL];
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
	if (delegate!=self)
		self.realDelegate = delegate;
	else [super setDelegate:delegate];
}

- (void)setContentSize:(CGSize)contentSize {
	[self setContentSize:contentSize userSet:YES];
}

- (void)setContentSize:(CGSize)contentSize userSet:(BOOL)userSet {
	if (userSet) {
		self.userSetContentSize = contentSize;
		[self setNeedsLayout];
	}
	else {
		[super setContentSize:contentSize];
	}
}


- (UIScrollView *)containerScrollView {
	if (!_containerScrollView) _containerScrollView = [[UIScrollView alloc] init];
	return _containerScrollView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:NSStringFromSelector(@selector(superview))]) {
		if ([object superview]!=self.containerScrollView) {
			JSScrollSubview *s = self.topMostView;
			while (s) {
				if (s.subview == object) {
					s.previous.next = s.next;
					s.next.previous = s.previous;
					if (s==self.topMostView) self.topMostView = s.next;
					if (s==self.bottomMostView) self.bottomMostView = s.previous;
					s.next = nil;
					s.previous = nil;
					break;
				}
				s = s.next;
			}
			@try {
				if ([object respondsToSelector:@selector(frame)])
					[object removeObserver:self forKeyPath:NSStringFromSelector(@selector(frame))];
				if ([object respondsToSelector:@selector(contentSize)])
					[object removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
				if ([object respondsToSelector:@selector(superview)])
					[object removeObserver:self forKeyPath:NSStringFromSelector(@selector(superview))];
			} @catch (NSException * __unused exception) {}
		}
	}
	else if ([keyPath isEqualToString:NSStringFromSelector(@selector(frame))]) {
		JSScrollSubview *s = self.topMostView;
		while (s) {
			if (s.subview == object) {
				if (s.shouldSetFrame==0) {
					CGRect rect = [[change valueForKey:@"new"] CGRectValue];
					float change2 = rect.origin.y - s.userSetFrame.origin.y;
					s.userSetFrame = rect;
					[self reorderView:s change:change2];
					if ([change valueForKey:@"old"]) {
						CGRect old = [[change valueForKey:@"old"] CGRectValue];
						s.shouldSetFrame++;
						[s.subview setFrame:old];
					}
					[self setNeedsLayout];
				}
				else {
					s.shouldSetFrame--;
				}
				break;
			}
			s = s.next;
		}
	}
	else if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
		JSScrollSubview *s = self.topMostView;
		while (s) {
			if (s.subview == object) {
				if (s.shouldSetContentSize==0) {
					s.userSetContentSize = [[change valueForKey:@"new"] CGSizeValue];
					[self setNeedsLayout];
				}
				else {
					s.shouldSetContentSize--;
				}
				break;
			}
			s = s.next;
		}
	}
}

- (void)reorderView:(JSScrollSubview *)sView change:(float)change {
	JSScrollSubview *s = sView;
	while ((s = (change>0?sView.next:sView.previous))) {
		if (change>0 &&sView.userSetFrame.origin.y>s.userSetFrame.origin.y) {
			s.next.previous = sView;
			sView.previous.next = s;
			s.previous = sView.previous;
			sView.next = s.next;
			s.next = sView;
			sView.previous = s;
			if (s==self.bottomMostView) self.bottomMostView = sView;
			if (sView == self.topMostView) self.topMostView = s;
		}
		else if (change < 0 && sView.userSetFrame.origin.y<s.userSetFrame.origin.y) {
			s.previous.next = sView;
			sView.next.previous = s;
			s.next = sView.next;
			sView.previous = s.previous;
			s.previous = sView;
			sView.next = s;
			if (s==self.topMostView) self.topMostView = sView;
			if (sView == self.bottomMostView) self.bottomMostView = s;
		}
		else {
			break;
		}
	}
}

- (float)scrollingViewSizes {
	float size = 0.0f;
	JSScrollSubview *s = self.topMostView;
	while (s) {
		if ([s isKindOfClass:[UIScrollView class]] && s.multiScrolls) {
			UIScrollView *scroll = (UIScrollView *)s.subview;
			size += scroll.contentSize.height - scroll.frame.size.height;
		}
		s = s.next;
	}
	return size;
}

- (void)setMultiScrolling:(BOOL)multiScrolling forView:(UIView *)view {
	JSScrollSubview *s = self.topMostView;
	while (s) {
		if (s.subview == view) {
			if (multiScrolling && !s.multiScrolls) {
				UIScrollView *sv = (UIScrollView *)s.subview;
				if (sv.panGestureRecognizer) {
					s.gesture = sv.panGestureRecognizer;
					
					if ([sv isKindOfClass:[JSMultiScrollView class]]) {
						JSMultiScrollView *s = (JSMultiScrollView *)sv;
						[s.containerScrollView removeGestureRecognizer:sv.panGestureRecognizer];
					}
					[sv removeGestureRecognizer:sv.panGestureRecognizer];
				}
			}
			else if (!multiScrolling && s.multiScrolls) {
				if (s.gesture) {
					UIScrollView *sv = (UIScrollView *)s.subview;
					[sv addGestureRecognizer:s.gesture];
					if ([sv isKindOfClass:[JSMultiScrollView class]]) {
						JSMultiScrollView *sv2 = (JSMultiScrollView *)sv;
						[sv2.containerScrollView addGestureRecognizer:sv.panGestureRecognizer];
					}
				}
			}

			[s setMultiScrolls:multiScrolling];
			return;
		}
		s = s.next;
	}
}

- (CGRect)originalFrameForView:(UIView *)view {
	JSScrollSubview *s = self.topMostView;
	while (s) {
		if (s.subview == view) return s.userSetFrame;
		s = s.next;
	}
	return CGRectZero;
}

- (CGSize)originalSizeForView:(UIView *)view {
	JSScrollSubview *s = self.topMostView;
	while (s) {
		if (s.subview == view) return s.userSetContentSize;
		s = s.next;
	}
	return CGSizeZero;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[self.containerScrollView setFrame:self.bounds];
	[self setNeedsLayout];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[UIView animateKeyframesWithDuration:(!self.drawn?0.0f:0.3) delay:0.0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^() {
		float change = 0.0f;
		float contentSizeChange = 0.0f;
		float fakeOffsetChange = 0.0f;
		JSScrollSubview *s = self.topMostView;
		while (s) {
			UIView *v = s.subview;
			CGRect fr = s.userSetFrame;
			fr.origin.y+=change;
			if ([v isKindOfClass:[UIScrollView class]] && s.multiScrolls) {
				UIScrollView *sv = (UIScrollView *)v;
				fr.size.height = MIN(self.frame.size.height,sv.contentSize.height);//s.userSetContentSize.height);//sv.contentSize.height);
				change += fr.size.height - s.userSetFrame.size.height;
				contentSizeChange += sv.contentSize.height - fr.size.height;
				if (s.userSetFrame.origin.y + s.userSetFrame.size.height < self.fakeOffset.y) fakeOffsetChange = change + contentSizeChange;
			}
			if (!CGRectEqualToRect(fr, v.frame)) {
				s.shouldSetFrame++;
				[v setFrame:fr];
			}
			s = s.next;
		}
		CGSize cs = self.userSetContentSize;
		cs.height += change + contentSizeChange;
		[self setContentSize:cs userSet:NO];
		if (self.setFakeOffset) {
			self.setFakeOffset = NO;
			[self setContentOffset:CGPointMake(self.fakeOffset.x, self.fakeOffset.y + fakeOffsetChange)];
		}
		self.drawn = YES;
	} completion:^(BOOL finished) {
		
	}];
}

- (CGPoint)getFakeContentOffset {
	float change = 0.0f;
	float contentSizeChange = 0.0f;
	float fakeOffsetChange = 0.0f;
	float realOffsetY = self.contentOffset.y;
	JSScrollSubview *s = self.topMostView;
	while (s) {
		UIView *v = s.subview;
		CGRect fr = s.userSetFrame;
		fr.origin.y+=change;
		if ([v isKindOfClass:[UIScrollView class]] && s.multiScrolls) {
			UIScrollView *sv = (UIScrollView *)v;
			fr.size.height = MIN(self.frame.size.height,sv.contentSize.height);//s.userSetContentSize.height);//sv.contentSize.height);
			change += fr.size.height - s.userSetFrame.size.height;
			contentSizeChange += sv.contentSize.height - fr.size.height;
			if (fr.origin.y + fr.size.height < realOffsetY) fakeOffsetChange = change + contentSizeChange;
			//		if (s.userSetFrame.origin.y + s.userSetFrame.size.height < self.fakeOffset.y) fakeOffsetChange = change + contentSizeChange;
		}
		s = s.next;
	}
	CGPoint off = self.contentOffset;
	off.y -= fakeOffsetChange;
	return off;
}

- (void)setContentOffset:(CGPoint)contentOffset {
	[super setContentOffset:contentOffset];
	[self setNewOffset:self];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
	[super setContentOffset:contentOffset animated:animated];
	[UIView animateWithDuration:0.3 animations:^() {
		[self setNewOffset:self];
	}];
}

- (void)setContentOffsetFake:(CGPoint)contentOffset {
	self.setFakeOffset = YES;
	self.fakeOffset = contentOffset;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
		[self.realDelegate scrollViewDidScroll:scrollView];
	[self setNewOffset:scrollView];
}

- (void)setNewOffset:(UIScrollView *)scrollView {

	float offset = scrollView.contentOffset.y;
	float originalOffset = offset;
	JSScrollSubview *s = self.topMostView;
	while (s) {
		if (![s.subview isKindOfClass:[UIScrollView class]] || !s.multiScrolls) {
			s = s.next;
			continue;
		}
		UIScrollView *scroll = (UIScrollView *)s.subview;
		float diff = MAX(0,MIN(offset - scroll.frame.origin.y, (scroll.contentSize.height - scroll.frame.size.height)));
		[scroll setContentOffset:CGPointMake(scroll.contentOffset.x, diff)];
		offset -= diff;
		s = s.next;
	}
	CGRect fr = self.containerScrollView.frame;
	fr.origin.y = originalOffset;
	[self.containerScrollView setFrame:fr];
	[self.containerScrollView setContentOffset:CGPointMake(self.containerScrollView.contentOffset.x, offset)];
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if (self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
		[self.realDelegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if (self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
		[self.realDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
		[self.realDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
	if (self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)])
		return [self.realDelegate scrollViewShouldScrollToTop:scrollView];
	return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
	if (self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)])
		[self.realDelegate scrollViewDidScrollToTop:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
	if (self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
		[self.realDelegate scrollViewWillBeginDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
		[self.realDelegate scrollViewDidEndDecelerating:scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	if (self.realDelegate && [self.realDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)])
		return [self.realDelegate viewForZoomingInScrollView:scrollView];
	return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	if (self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)])
		[self.realDelegate scrollViewWillBeginZooming:scrollView withView:view];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
	if (self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
		[self.realDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	if (self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewDidZoom:)])
		[self.realDelegate scrollViewDidZoom:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	if (self.realDelegate && [self.realDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
		[self.realDelegate scrollViewDidEndScrollingAnimation:scrollView];
}


- (void)dealloc {
	JSScrollSubview *s = self.topMostView;
	while (s) {
		@try {
			UIView *view = s.subview;
			if ([view respondsToSelector:@selector(frame)])
				[view removeObserver:self forKeyPath:NSStringFromSelector(@selector(frame))];
			if ([view respondsToSelector:@selector(contentSize)])
				[view removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
			if ([view respondsToSelector:@selector(superview)])
				[view removeObserver:self forKeyPath:NSStringFromSelector(@selector(superview))];
			s = s.next;
		} @catch (NSException * __unused exception) {}
		
	}
}


- (NSString *)printFromTop {
	JSScrollSubview *s = self.topMostView;
	NSString *str = [NSString stringWithFormat:@"%@",s.subview];
	while ((s = s.next)) {
		str = [str stringByAppendingString:[NSString stringWithFormat:@"\n%@",s.subview]];
	}
	return str;
}

- (NSString *)printFromBottom {
	JSScrollSubview *s = self.bottomMostView;
	NSString *str = [NSString stringWithFormat:@"%@",s.subview];
	while ((s = s.next)) {
		str = [str stringByAppendingString:[NSString stringWithFormat:@"\n%@",s.subview]];
	}
	return str;
}


@end
