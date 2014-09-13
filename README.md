JSMultiScrollView
=================

This class is a subview of UIScrollView used when creating a scrollView with UIScrollViews, UITableViews, or other UIScrollView subclasses as subviews.

The JSMultiScrollView will automatically update the frames and content offsets of these views based on their content size and the scroll position. In addition, the frames of all other views will be adjusted so that they appear to be where you set them.

What is the Purpose
-----------------
The reason that I created this class was because I found myself often wanting to have a table view in the middle of other content in a scroll view, and I wanted the tableview to scroll as a part of the scroll view.

The way I used to handle this is by setting the frame of the table view to be the same as its content size, and add it to the scroll view. However, doing so forces all elements of the table view to be loaded at the same time, causing a performance hit when there are a large number of elements, and effectively defeating the purpose of having a table view at all.

This is why I created the JSMultiScrollView. Instead of loading the whole table view at the same time, this class will set its frame to the same size as the scroll view it is in, and will automatically adjust its content offset when the scroll view is scrolled. Also, if the table view's content size is smaller than the frame, its frame will be set to the same size as its content size.




Features
---------------
The class will automatically determine the frame and content size of your views using KVO, so adding views to the scroll view is no different than adding them to any other UIScrollView, and there is nothing additional that needs to be done.

If you have a UIScrollView or subclass of which you want to act as normal (ie keep the frame you set and scroll separately from the JSMultiScrollView), you can either call the `-setMultiScrolling:toView:` method after the view has been added, or simply call the `-addSubView:multiScrolling:` (instead of `-addSubview:`), with the `multiScrolling` value set to `NO`.

This could be useful for text views which you do not want taking up the whole screen.



License
------------
Copyright (c) 2014 Jsdodgers

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
