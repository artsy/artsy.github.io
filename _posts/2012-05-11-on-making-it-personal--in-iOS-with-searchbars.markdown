---
layout: post
title: On Making It Personal in iOS with Searchbars
date: 2012-05-11 20:52
comments: true
categories: [iOS, UIKIT, Customisation, mobile]
author: orta
---

We make Folio, a pretty kick-ass iPad app that we give away to our partners to showcase their inventory at art fairs. Whilst making it we tried to ensure that all of the application fits in with the [Artsy](http://artsy.net) website aesthetic, and recently the last natively styled control fell to our mighty code hammers. That was the `UISearchBar`.

![Screenshot of Artsy Folio](http://ortastuff.s3.amazonaws.com/images/custom_searchbar_example.jpg)

When displaying only search results in a table it makes a lot of sense to use Apple's `UISearchDisplayController` as it handles a lot of edge cases for you. However the downside is that you lose some control over how the views interact.

The search bar was the only native control that actually made it into the version 1 release. This was mainly due to it requiring a bit of black magic in order to get it to work the way we wanted. So lets go through the code and rip it to pieces.

<!--more-->

First up, you're going to want to make yourself a subclass of the `UISearchBar`, I'm going to be calling ours `ARSearchBar`. Here's our public header.

``` objc
@interface ARSearchBar : UISearchBar

// Called from The SearchDisplayController Delegate
- (void)showCancelButton:(BOOL)show;
- (void)cancelSearchField;
@end
```

Inside the implementation file we declare private instance variables for keeping track of the textfield and the Cancel button. This is so we can avoid finding them in the view hierarchy when we want to change the frame it during resizing.

``` objc
@interface ARSearchBar (){
    UITextField *foundSearchTextField;
    UIButton *overlayCancelButton;
}
```

So, to look at setting the size we've found it easiest to deal with that in an overrode `setFrame` and setting the height of the new frame before it goes to the super class. As the search bar doesn't change its height between state changes like text insertion it shouldn't pose a problem to have it hardcoded.

``` objc
- (void)setFrame:(CGRect)frame {
    frame.size.height = ARSearchBarHeight;
    [super setFrame:frame];
}
```

What does pose a problem though is making sure that the subviews inside the search bar are positioned correctly with respect to the new height, this is amended in `layoutSubviews`. In our case the textfield should take up almost all of the search bar.

``` objc
- (void)layoutSubviews {
    [super layoutSubviews];

    // resize textfield
    CGRect frame = foundSearchTextField.frame;
    frame.size.height = ViewHeight;
    frame.origin.y = ViewMargin;
    frame.origin.x = ViewMargin;
    frame.size.width -= ViewMargin / 2;
    foundSearchTextField.frame = frame;
}
```

Next up is that we can't access our `foundSearchField` because it's not been found yet! Personally,  I'm a big fan of using nibs for everything ( and pretty pumped about Storyboards too ) so we do our searching in `awakeFromNib` .

``` objc
- (void)awakeFromNib {
    [super awakeFromNib];

    // find textfield in subviews
    for (int i = [self.subviews count] - 1; i >= 0; i--) {
        UIView *subview = [self.subviews objectAtIndex:i];                
        if ([subview.class isSubclassOfClass:[UITextField class]]) {
            foundSearchTextField = (UITextField *)subview;
        }
    }
}
```

This gives us a textfield, next up we want to stylize it. The perfect place for this is just after finding the textfield that you use to search in.

``` objc
- (void)stylizeSearchTextField {
    // Sets the background to a static black by removing the gradient view
    for (int i = [self.subviews count] - 1; i >= 0; i--) {
        UIView *subview = [self.subviews objectAtIndex:i];                

        // This is the gradient behind the textfield
        if ([subview.description hasPrefix:@"<UISearchBarBackground"]) {
            [subview removeFromSuperview];
        }
    }

    // now change the search textfield itself
    foundSearchTextField.borderStyle = UITextBorderStyleNone;
    foundSearchTextField.backgroundColor = [UIColor whiteColor];
    foundSearchTextField.background = nil;
    foundSearchTextField.text = @"";
    foundSearchTextField.clearButtonMode = UITextFieldViewModeNever;
    foundSearchTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TextfieldLeftMargin, 0)];
    foundSearchTextField.placeholder = @"";
    foundSearchTextField.font = [UIFont serifFontWithSize:ARFontSansLarge];
}
```

You might be wondering why we removed the placeholder text? We needed more control over the style and positioning of the placeholder text and the search icon. These are easily controlled by the UISearchDisplayController subclass rather than inside the custom search bar. This is also the place that we can deal with having our custom Cancel button.

``` objc
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [searchBar showCancelButton:YES];
    [UIView animateWithDuration:0.2 animations:^{
        searchPlaceholderLabel.alpha = 0;
    }];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [searchBar showCancelButton:NO];
    [UIView animateWithDuration:0.2 animations:^{
        searchPlaceholderLabel.alpha = 1;
    }];
}
```

The corresponding code for showing and hiding the Cancel button is here. We just animate it in and out by a distance of 80.

``` objc
- (void)showCancelButton:(BOOL)show {
    CGFloat distance = show? -CancelAnimationDistance : CancelAnimationDistance;
    [UIView animateWithDuration:0.25 animations:^{
        overlayCancelButton.frame = CGRectOffset(overlayCancelButton.frame, distance, 0);
    }];
}
```

The original Cancel button is something that we choose to keep around, rather than removing it form the view hierarchy, that's so we can have our overlay Cancel button call its method instead of trying to replicate the cancel functionality ourselves.

To keep track of the Cancel button we need to know when its meant to appear, and when its meant to disappear. Because the Cancel button is created at runtime every time a search is started we need to
know when thats happening so we can hide it, we can do that by registering for `UITextFieldTextDidBeginEditingNotification` on the textfield once it's been found. We do this in `awakeFromNib`.

``` objc
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOriginalCancel) name:UITextFieldTextDidBeginEditingNotification object:foundSearchTextField];


- (void)removeOriginalCancel {
    // remove the original button
    for (int i = [self.subviews count] - 1; i >= 0; i--) {
        UIView *subview = [self.subviews objectAtIndex:i];                
        if ([subview.class isSubclassOfClass:[UIButton class]]) {
        	// This is called every time a search is began,
        	// so make sure to get the right button!
            if (subview.frame.size.height != ViewHeight) {
                subview.hidden = YES;
            }
        }
    }
}
```

Finally we have the styling of the button. I've summed it up here as a lot of it is very application specific.

```objc
- (void)createButton {
    ARFlatButton *cancelButton = [ARFlatButton buttonWithType:UIButtonTypeCustom];
    [[cancelButton titleLabel] setFont:[UIFont sansSerifFontWithSize:ARFontSansSmall]];

    NSString *title = [@"Cancel" uppercaseString];
    [cancelButton setTitle:title forState:UIControlStateNormal];
    [cancelButton setTitle:title forState:UIControlStateHighlighted];

    CGRect buttonFrame = cancelButton.frame;
    buttonFrame.origin.y = ViewMargin;
    buttonFrame.size.height = ViewHeight;
    buttonFrame.size.width = 66;
    buttonFrame.origin.x = self.frame.size.width - buttonFrame.size.width - ViewMargin + CancelAnimationDistance;
    cancelButton.frame = buttonFrame;
    [cancelButton addTarget:self action:@selector(cancelSearchField) forControlEvents:UIControlEventTouchUpInside];

    overlayCancelButton = cancelButton;
    [self addSubview:overlayCancelButton];
    [self bringSubviewToFront:overlayCancelButton];
}

- (void)cancelSearchField {
    // tap the original button!
    for (int i = [self.subviews count] - 1; i >= 0; i--) {
        UIView *subview = [self.subviews objectAtIndex:i];                
        if ([subview.class isSubclassOfClass:[UIButton class]]) {
            if (subview.frame.size.height != ViewHeight) {
                UIButton *realCancel = (UIButton *)subview;
                [realCancel sendActionsForControlEvents: UIControlEventTouchUpInside];
            }
        }
    }    
}
```

The complete code is available [as a gist](https://gist.github.com/2667766) under the MIT license.
