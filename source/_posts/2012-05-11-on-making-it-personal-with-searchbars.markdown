---
layout: post
title: On Making It Personal With Searchbars
date: 2012-05-11 20:52
comments: true
categories: [iOS, UIKIT, Customisation]
author: orta therox
github-url: https://www.github.com/orta
twitter-url: http://twitter.com/orta
blog-url: http://orta.github.com
---

We make a pretty kick-ass iPad app. Whilst making it we tried to ensure that all of the application fits in with the [art.sy](http://art.sy) website aesthetic, and recently the last natively styled control fell to our mighty code hammers. That was the UISearchBar.

When displaying only search results in a table it makes a lot of sense to use Apple's [UISearchDisplayController](http://developer.apple.com/library/ios/#documentation/uikit/reference/UISearchDisplayController_Class/Reference/Reference.html#//apple_ref/occ/cl/UISearchDisplayController) as it handles a lot of edge cases for you. However the downside is that you lose some control over how the views interact.

The Search Bar was the only native control that actually made it into the version 1 release. This was mainly due to it requiring a bit of black magic in order to get it to work how you like. So lets go through the code and rip it to pieces.

<!--more-->

First up, you're going to want to make yourself a subclass of the UISearchBar, I'm going to be calling ours ARSearchBar. Here's our public header.

``` objc
@interface ARSearchBar : UISearchBar

// Called from The SearchDisplayController Delegate
- (void)showCancelButton:(BOOL)show;
- (void)cancelSearchField;
@end
```

and inside the implementation file we declare some private instance variables for things we will be needing later.

``` objc
@interface ARSearchBar (){
    UITextField *foundSearchTextField;
    UIButton *overlayCancelButton;
}
```

So, to look at setting the size we've found it easiest to deal with setting the height of the SearchBar in our subclass on setFrame and setting the height of the new frame before it goes to the subclass. As the search bar doesn't change its height inbetween state changes like text insertion it's not posed a problem.

``` objc
- (void)setFrame:(CGRect)frame {
    frame.size.height = ARSearchBarHeight;
    [super setFrame:frame];
}
``` 

What does pose a problem though is making sure that the subviews inside the Search Bar are positioned correctly with respect to the new height, this is amended in layoutSubviews. In our case the textfield should take up almost all of the search bar.

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

Next up is that we can't access our foundSearchField because it's not been found yet! Personally I'm a big fan of using nibs for everything ( and pretty pumped about Storyboards too ) so we do our searching in awakeFromNib 

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

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOriginalCancel) name:UITextFieldTextDidBeginEditingNotification object:foundSearchTextField];
}
```

So this gives us a resized space, next up we want to stylize it. The perfect place for this is just after finding the textfield that you use to search in. 


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

You might be wondering why we removed the placeholder text, we needed more control over the style and positioning of the placeholder that is easily controlled by the UISearchDisplayController subclass rather than the custom search bar. This is also the place that we can deal with having our custom cancel button.

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

The corresponding code for showing and hiding the cancel button is here

``` objc
- (void)showCancelButton:(BOOL)show {
    CGFloat distance = show? -CancelAnimationDistance : CancelAnimationDistance;
    [UIView animateWithDuration:0.25 animations:^{
        overlayCancelButton.frame = CGRectOffset(overlayCancelButton.frame, distance, 0);
    }];
}
```

The original cancel button is something that we choose to keep around, rather than removing it form the view heirarchy, that's so we can have our overlay cancel button call its method instead of  trying to replicate the cancel functionality ourselves.

To keep track of the cancel button we need to know when its meant to appear, and when its meant to disappear. Because the cancel button is created at runtime everytime a search is started we need to 
know when thats happening so we can hide it, we can do that by registering for `UITextFieldTextDidBeginEditingNotification` on the textfield once it's been found. 

``` objc
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOriginalCancel) name:UITextFieldTextDidBeginEditingNotification object:foundSearchTextField];


- (void)removeOriginalCancel {
    // remove the original button
    for (int i = [self.subviews count] - 1; i >= 0; i--) {
        UIView *subview = [self.subviews objectAtIndex:i];                
        if ([subview.class isSubclassOfClass:[UIButton class]]) {
        	// This is called everytime a search is began, 
        	// so make sure to get the right button!
            if (subview.frame.size.height != ViewHeight) {
                subview.hidden = YES;
            }
        }
    }
}
```

Finally we have the styling of the button, I've summed it up here as a lot of it is very application specific.

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

I've included a copy of the full files [in a gist here](https://gist.github.com/2667766) so people can see it all together

<script src="https://gist.github.com/2667766.js"> </script>