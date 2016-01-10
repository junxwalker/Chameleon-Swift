/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

enum UIViewAutoresizing : Int {
    case None = 0
    case FlexibleLeftMargin = 1 << 0
    case FlexibleWidth = 1 << 1
    case FlexibleRightMargin = 1 << 2
    case FlexibleTopMargin = 1 << 3
    case FlexibleHeight = 1 << 4
    case FlexibleBottomMargin = 1 << 5
}

enum UIViewContentMode : Int {
    case ScaleToFill
    case ScaleAspectFit
    case ScaleAspectFill
    case Redraw
    case Center
    case Top
    case Bottom
    case Left
    case Right
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
}

enum UIViewAnimationCurve : Int {
    case EaseInOut
    case EaseIn
    case EaseOut
    case Linear
}

enum UIViewAnimationTransition : Int {
    case None
    case FlipFromLeft
    case FlipFromRight
    case CurlUp
    case CurlDown
}

enum .s : Int {
    case UIViewAnimationOptionLayoutSubviews = 1 << 0
    // not currently supported
    case UIViewAnimationOptionAllowUserInteraction = 1 << 1
    case UIViewAnimationOptionBeginFromCurrentState = 1 << 2
    case UIViewAnimationOptionRepeat = 1 << 3
    case UIViewAnimationOptionAutoreverse = 1 << 4
    case UIViewAnimationOptionOverrideInheritedDuration = 1 << 5
    // not currently supported
    case UIViewAnimationOptionOverrideInheritedCurve = 1 << 6
    // not currently supported
    case UIViewAnimationOptionAllowAnimatedContent = 1 << 7
    // not currently supported
    case UIViewAnimationOptionShowHideTransitionViews = 1 << 8
    case UIViewAnimationOptionCurveEaseInOut = 0 << 16
    case UIViewAnimationOptionCurveEaseIn = 1 << 16
    case UIViewAnimationOptionCurveEaseOut = 2 << 16
    case UIViewAnimationOptionCurveLinear = 3 << 16
    case UIViewAnimationOptionTransitionNone = 0 << 20
    case UIViewAnimationOptionTransitionFlipFromLeft = 1 << 20
    case UIViewAnimationOptionTransitionFlipFromRight = 2 << 20
    case UIViewAnimationOptionTransitionCurlUp = 3 << 20
    case UIViewAnimationOptionTransitionCurlDown = 4 << 20
    case UIViewAnimationOptionTransitionCrossDissolve = 5 << 20
    case UIViewAnimationOptionTransitionFlipFromTop = 6 << 20
    case UIViewAnimationOptionTransitionFlipFromBottom = 7 << 20
}

class UIView: UIResponder, UIAppearanceContainer, UIAppearance {
    class func layerClass() -> AnyClass {
        return CALayer
    }

    convenience override init(frame: CGRect) {
    }

    func addSubview(subview: UIView) {
        assert((!subview || (subview is UIView)), "the subview must be a UIView")
        if subview && subview.superview != self {
            var oldWindow: UIWindow = subview.window
            var newWindow: UIWindow = self.window
            subview._willMoveFromWindow(oldWindow, toWindow: newWindow)
            subview.willMoveToSuperview(self)
            if subview.superview {
                subview.layer.removeFromSuperlayer()
                subview.superview->subviews.removeObject(subview)
            }
            subview.willChangeValueForKey("superview")
            subviews.append(subview)
            subview->superview = self
            layer.addSublayer(subview.layer)
            subview.didChangeValueForKey("superview")
            if oldWindow.screen != newWindow.screen {
                subview._didMoveToScreen()
            }
            subview._didMoveFromWindow(oldWindow, toWindow: newWindow)
            subview.didMoveToSuperview()
            NSNotificationCenter.defaultCenter().postNotificationName(UIViewDidMoveToSuperviewNotification, object: subview)
            self.didAddSubview(subview)
        }
    }

    func insertSubview(subview: UIView, atIndex index: Int) {
        self.addSubview(subview)
        layer.insertSublayer(subview.layer, atIndex: index)
    }

    func insertSubview(subview: UIView, belowSubview below: UIView) {
        self.addSubview(subview)
        layer.insertSublayer(subview.layer, below: below.layer)
    }

    func insertSubview(subview: UIView, aboveSubview above: UIView) {
        self.addSubview(subview)
        layer.insertSublayer(subview.layer, above: above.layer)
    }

    func removeFromSuperview() {
        if superview != nil {
            var oldWindow: UIWindow = self.window
            superview.willRemoveSubview(self)
            self._willMoveFromWindow(oldWindow, toWindow: nil)
            self.willMoveToSuperview(nil)
            self.willChangeValueForKey("superview")
            layer.removeFromSuperlayer()
            superview->subviews.removeObject(self)
            self.superview = nil
            self.didChangeValueForKey("superview")
            self._abortGestureRecognizers()
            NSNotificationCenter.defaultCenter().postNotificationName(UIViewDidMoveToSuperviewNotification, object: self)
            self._didMoveFromWindow(oldWindow, toWindow: nil)
            self.didMoveToSuperview()
        }
    }

    func bringSubviewToFront(subview: UIView) {
        if subview.superview == self {
            layer.insertSublayer(subview.layer, above: layer.sublayers().lastObject())
        }
    }

    func sendSubviewToBack(subview: UIView) {
        if subview.superview == self {
            layer.insertSublayer(subview.layer, atIndex: 0)
        }
    }

    func convertRect(toConvert: CGRect, fromView: UIView) -> CGRect {
        var origin: CGPoint = self.convertPoint(CGPointMake(CGRectGetMinX(toConvert), CGRectGetMinY(toConvert)), fromView: fromView)
        var bottom: CGPoint = self.convertPoint(CGPointMake(CGRectGetMaxX(toConvert), CGRectGetMaxY(toConvert)), fromView: fromView)
        return CGRectMake(origin.x, origin.y, bottom.x - origin.x, bottom.y - origin.y)
    }

    func convertRect(toConvert: CGRect, toView: UIView) -> CGRect {
        var origin: CGPoint = self.convertPoint(CGPointMake(CGRectGetMinX(toConvert), CGRectGetMinY(toConvert)), toView: toView)
        var bottom: CGPoint = self.convertPoint(CGPointMake(CGRectGetMaxX(toConvert), CGRectGetMaxY(toConvert)), toView: toView)
        return CGRectMake(origin.x, origin.y, bottom.x - origin.x, bottom.y - origin.y)
    }

    func convertPoint(toConvert: CGPoint, fromView: UIView) -> CGPoint {
        // NOTE: this is a lot more complex than it needs to be - I just noticed the docs say this method requires fromView and self to
        // belong to the same UIWindow! arg! leaving this for now because, well, it's neat.. but also I'm too tired to really ponder
        // all the implications of a change to something so "low level".
        if fromView != nil {
            // If the screens are the same, then we know they share a common parent CALayer, so we can convert directly with the layer's
            // conversion method. If not, though, we need to do something a bit more complicated.
            if fromView && (self.window.screen == fromView.window.screen) {
                return fromView.layer.convertPoint(toConvert, toLayer: self.layer)
            }
            else {
                // Convert coordinate to fromView's window base coordinates.
                toConvert = fromView.layer.convertPoint(toConvert, toLayer: fromView.window.layer)
                // Now convert from fromView's window to our own window.
                toConvert = fromView.window.convertPoint(toConvert, toWindow: self.window)
            }
        }
        // Convert from our window coordinate space into our own coordinate space.
        return self.window.layer.convertPoint(toConvert, toLayer: self.layer)
    }

    func convertPoint(toConvert: CGPoint, toView: UIView) -> CGPoint {
        // NOTE: this is a lot more complex than it needs to be - I just noticed the docs say this method requires toView and self to
        // belong to the same UIWindow! arg! leaving this for now because, well, it's neat.. but also I'm too tired to really ponder
        // all the implications of a change to something so "low level".
        // See note in convertPoint:fromView: for some explaination about why this is done... :/
        if toView && (self.window.screen == toView.window.screen) {
            return self.layer.convertPoint(toConvert, toLayer: toView.layer)
        }
        else {
            // Convert to our window's coordinate space.
            toConvert = self.layer.convertPoint(toConvert, toLayer: self.window.layer)
            if toView != nil {
                // Convert from one window's coordinate space to another.
                toConvert = self.window.convertPoint(toConvert, toWindow: toView.window)
                // Convert from toView's window down to toView's coordinate space.
                toConvert = toView.window.layer.convertPoint(toConvert, toLayer: toView.layer)
            }
            return toConvert
        }
    }

    func setNeedsDisplay() {
        layer.setNeedsDisplay()
    }

    func setNeedsDisplayInRect(invalidRect: CGRect) {
        layer.needsDisplayInRect = invalidRect
    }

    func drawRect(rect: CGRect) {
    }

    func sizeToFit() {
        var frame: CGRect = self.frame
        frame.size = self.sizeThatFits(frame.size)
        self.frame = frame
    }

    func sizeThatFits(size: CGSize) -> CGSize {
        return size
    }

    func setNeedsLayout() {
    }

    func layoutIfNeeded() {
    }

    func layoutSubviews() {
    }

    func pointInside(_ point: CGPoint, withEvent event: UIEvent?) -> Bool {
    }

    func hitTest(point: CGPoint, withEvent event: UIEvent) -> UIView {
    }

    func viewWithTag(tag: Int) -> UIView {
    }

    func isDescendantOfView(view: UIView) -> Bool {
        if view != nil {
            var testView: UIView = self
            while testView {
                if testView == view {
                    return true
                }
                else {
                    testView = testView.superview
                }
            }
        }
        return false
    }

    func addGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
    }
    // not implemented

    func removeGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
    }
    // not implemented

    func didAddSubview(subview: UIView) {
    }

    func didMoveToSuperview() {
    }

    func didMoveToWindow() {
    }

    func willMoveToSuperview(newSuperview: UIView) {
    }

    func willMoveToWindow(newWindow: UIWindow) {
    }

    func willRemoveSubview(subview: UIView) {
    }

    class func animateWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void, completion: (finished: Bool) -> Void) {
    }

    class func animateWithDuration(duration: NSTimeInterval, animations: () -> Void, completion: (finished: Bool) -> Void) {
    }

    class func animateWithDuration(duration: NSTimeInterval, animations: () -> Void) {
    }

    class func transitionWithView(view: UIView, duration: NSTimeInterval, options: UIViewAnimationOptions, animations: () -> Void, completion: (finished: Bool) -> Void) {
    }

    class func transitionFromView(fromView: UIView, toView: UIView, duration: NSTimeInterval, options: UIViewAnimationOptions, completion: (finished: Bool) -> Void) {
    }

    class func beginAnimations(animationID: String, context: ) {
    }

    class func commitAnimations() {
    }

    class func setAnimationBeginsFromCurrentState(beginFromCurrentState: Bool) {
    }

    class func setAnimationCurve(curve: UIViewAnimationCurve) {
    }

    class func setAnimationDelay(delay: NSTimeInterval) {
    }

    class func setAnimationDelegate(delegate: AnyObject) {
    }

    class func setAnimationDidStopSelector(selector: Selector) {
    }

    class func setAnimationDuration(duration: NSTimeInterval) {
    }

    class func setAnimationRepeatAutoreverses(repeatAutoreverses: Bool) {
    }

    class func setAnimationRepeatCount(repeatCount: CGFloat) {
    }

    class func setAnimationTransition(transition: UIViewAnimationTransition, forView view: UIView, cache: Bool) {
    }

    class func setAnimationWillStartSelector(selector: Selector) {
    }

    class func areAnimationsEnabled() -> Bool {
    }

    class func setAnimationsEnabled(enabled: Bool) {
    }
    var frame: CGRect
    var bounds: CGRect
    var center: CGPoint
    var transform: CGAffineTransform
    var superview: UIView {
        get {
            return self.superview
        }
    }

    var window: UIWindow! {
        get {
            return superview.window
        }
    }

    var subviews: [AnyObject] {
        get {
            var sublayers: [AnyObject] = layer.sublayers
            var subviews: [AnyObject] = [AnyObject](minimumCapacity: sublayers.count)
            // This builds the results from the layer instead of just using _subviews because I want the results to match
            // the order that CALayer has them. It's unclear in the docs if the returned order from this method is guarenteed or not,
            // however several other aspects of the system (namely the hit testing) depends on this order being correct.
            for layer: CALayer in sublayers {
                var potentialView: AnyObject = layer.delegate
                if subviews.containsObject(potentialView) {
                    subviews.append(potentialView)
                }
            }
            return subviews
        }
    }

    var alpha: CGFloat
    var opaque: Bool
    var clearsContextBeforeDrawing: Bool
    var backgroundColor: UIColor
    var layer: CALayer {
        get {
            return self.layer
        }
    }

    var clipsToBounds: Bool
    var autoresizesSubviews: Bool
    var autoresizingMask: UIViewAutoresizing
    var contentStretch: CGRect
    var tag: Int
    var hidden: Bool
    var userInteractionEnabled: Bool
    var contentMode: UIViewContentMode
    var contentScaleFactor: CGFloat
    var multipleTouchEnabled: Bool
    // state is maintained, but it has no effect
    var exclusiveTouch: Bool
    // state is maintained, but it has no effect
    var gestureRecognizers: [AnyObject]
    var self.superview: UIView
    var self.viewController: UIViewController
    var self.subviews: NSMutableSet
    var self.implementsDrawRect: Bool
    var self.gestureRecognizers: NSMutableSet


    class func initialize() {
        if self == UIView {
            self.animationGroups = [AnyObject]()
        }
    }

    class func _instanceImplementsDrawRect() -> Bool {
        return UIView.instanceMethodForSelector("drawRect:") != self.instanceMethodForSelector("drawRect:")
    }

    convenience override init() {
        return self(frame: CGRectZero)
    }

    convenience override init(frame theFrame: CGRect) {
        if (self.init()) {
            self.implementsDrawRect = self._instanceImplementsDrawRect()
            self.clearsContextBeforeDrawing = true
            self.autoresizesSubviews = true
            self.userInteractionEnabled = true
            self.subviews = NSMutableSet()
            self.gestureRecognizers = NSMutableSet()
            self.layer = self.layerClass()()
            self.layer.delegate = self
            self.layer.layoutManager = UIViewLayoutManager.layoutManager()
            self.contentMode = .ScaleToFill
            self.contentScaleFactor = 0
            self.frame = theFrame
            self.alpha = 1
            self.opaque = true
            self.setNeedsDisplay()
        }
    }

    func dealloc() {
        gestureRecognizers.makeObjectsPerformSelector("_setView:", withObject: nil)
        subviews.allObjects().makeObjectsPerformSelector("_removeFromDeallocatedSuperview")
        self.layer.layoutManager = nil
        self.layer.delegate = nil
        layer.removeFromSuperlayer()
    }

    func _setViewController(theViewController: UIViewController) {
        self.viewController = theViewController
    }

    func _viewController() -> UIViewController {
        return viewController
    }

    func nextResponder() -> UIResponder {
        return self._viewController() as! UIResponder ?? superview as! UIResponder
    }

    func _UIAppearanceContainer() -> AnyObject {
        return self.superview
    }

    func _willMoveFromWindow(fromWindow: UIWindow, toWindow: UIWindow) {
        if fromWindow != toWindow {
            // need to manage the responder chain. apparently UIKit (at least by version 4.2) seems to make sure that if a view was first responder
            // and it or it's parent views are disconnected from their window, the first responder gets reset to nil. Honestly, I don't think this
            // was always true - but it's certainly a much better and less-crashy design. Hopefully this check here replicates the behavior properly.
            if self.isFirstResponder() {
                self.resignFirstResponder()
            }
            self._UIAppearanceSetNeedsUpdate()
            self.willMoveToWindow(toWindow)
            for subview: UIView in self.subviews {
                subview._willMoveFromWindow(fromWindow, toWindow: toWindow)
            }
            self._viewController().beginAppearanceTransition((toWindow != nil), animated: false)
        }
    }

    func _didMoveToScreen() {
        if implementsDrawRect && self.contentScaleFactor != self.window.screen.scale {
            self.contentScaleFactor = self.window.screen.scale
        }
        else {
            self.setNeedsDisplay()
        }
        for subview: UIView in self.subviews {
            subview._didMoveToScreen()
        }
    }

    func _didMoveFromWindow(fromWindow: UIWindow, toWindow: UIWindow) {
        if fromWindow != toWindow {
            self.didMoveToWindow()
            for subview: UIView in self.subviews {
                subview._didMoveFromWindow(fromWindow, toWindow: toWindow)
            }
            var controller: UIViewController = self._viewController()
            if controller != nil {
                if self._isAnimating() {
                    var completionBlock = self._animationCompletionBlock()
                    self._setAnimationCompletionBlock({(finished: Bool) -> Void in
                        controller.endAppearanceTransition()
                        if completionBlock != nil {
                            completionBlock(finished)
                        }
                    })
                }
                else {
                    // this is sort of strange, but testing against iOS 6 seems to indicate that appearance transitions
                    // that don't occur within an animation block still do something like this.. it waits until the runloop
                    // cycles before really finishing. I can think of some good reasons for this behavior, so I think it
                    // makes sense to try to replicate it, but I know the real thing doesn't do it like this... :/
                    // (although to be fair, the real thing doesn't do anything much like I'm doing it, so...)
                    controller.performSelector("endAppearanceTransition", withObject: nil, afterDelay: 0)
                }
            }
        }
    }

    func _abortGestureRecognizers() {
        // note - the real UIKit supports multitouch so it only really interruptes the current touch
        // and not all of them, but this is easier for now since we don't support that anyway.
        UIApplicationInterruptTouchesInView(self)
    }

    func _removeFromDeallocatedSuperview() {
        self.superview = nil
        self._abortGestureRecognizers()
    }

    func viewWithTag(tagToFind: Int) -> UIView {
        var foundView: UIView? = nil
        if self.tag == tagToFind {
            foundView = self
        }
        else {
            for view: UIView in self.subviews.reverseObjectEnumerator() {
                foundView = view.viewWithTag(tagToFind)
                if foundView! {

                }
            }
        }
        return foundView!
    }

    func displayLayer(theLayer: CALayer) {
        // Okay, this is some crazy stuff right here. Basically, the real UIKit avoids creating any contents for its layer if there's no drawRect:
        // specified in the UIView's subview. This nicely prevents a ton of useless memory usage and likley improves performance a lot on iPhone.
        // It took great pains to discover this trick and I think I'm doing this right. By having this method empty here, it means that it overrides
        // the layer's normal display method and instead does nothing which results in the layer not making a backing store and wasting memory.
        // Here's how CALayer appears to work:
        // 1- something call's the layer's -display method.
        // 2- arrive in CALayer's display: method.
        // 2a-  if delegate implements displayLayer:, call that.
        // 2b-  if delegate doesn't implement displayLayer:, CALayer creates a buffer and a context and passes that to drawInContext:
        // 3- arrive in CALayer's drawInContext: method.
        // 3a-  if delegate implements drawLayer:inContext:, call that and pass it the context.
        // 3b-  otherwise, does nothing
        // So, what this all means is that to avoid causing the CALayer to create a context and use up memory, our delegate has to lie to CALayer
        // about if it implements displayLayer: or not. If we say it does, we short circuit the layer's buffer creation process (since it assumes
        // we are going to be setting it's contents property ourselves). So, that's what we do in the override of respondsToSelector: below.
        // backgroundColor is influenced by all this as well. If drawRect: is defined, we draw it directly in the context so that blending is all
        // pretty and stuff. If it isn't, though, we still want to support it. What the real UIKit does is it sets the layer's backgroundColor
        // iff drawRect: isn't specified. Otherwise it manages it itself. Again, this is for performance reasons. Rather than having to store a
        // whole bitmap the size of view just to hold the backgroundColor, this allows a lot of views to simply act as containers and not waste
        // a bunch of unnecessary memory in those cases - but you can still use background colors because CALayer manages that effeciently.
        // note that the last time I checked this, the layer's background color was being set immediately on call to -setBackgroundColor:
        // when there was no -drawRect: implementation, but I needed to change this to work around issues with pattern image colors in HiDPI.
        self.layer.backgroundColor = self.backgroundColor._bestRepresentationForProposedScale(self.window.screen.scale).CGColor
    }

    func respondsToSelector(aSelector: Selector) -> Bool {
        // For notes about why this is done, see displayLayer: above.
        if aSelector == "displayLayer:" {
            return !implementsDrawRect
        }
        else {
            return super.respondsToSelector(aSelector)
        }
    }

    func drawLayer(layer: CALayer, inContext ctx: CGContextRef) {
        // We only get here if the UIView subclass implements drawRect:. To do this without a drawRect: is a huge waste of memory.
        // See the discussion in drawLayer: above.
        let bounds: CGRect = CGContextGetClipBoundingBox(ctx)
        UIGraphicsPushContext(ctx)
        CGContextSaveGState(ctx)
        if clearsContextBeforeDrawing {
            CGContextClearRect(ctx, bounds)
        }
        if backgroundColor! {
            backgroundColor!.setFill()
            CGContextFillRect(ctx, bounds)
        }
        /*
             NOTE: This kind of logic would seem to be ideal and result in the best font rendering when possible. The downside here is that
             the rendering is then inconsistent throughout the app depending on how certain views are constructed or configured.
             I'm not sure what to do about this. It appears to be impossible to subpixel render text drawn into a transparent layer because
             of course there are no pixels behind the text to use when doing the subpixel blending. If it is turned on in that case, it looks
             bad depending on what is ultimately composited behind it. Turning it off everywhere makes everything "equally bad," in a sense,
             but at least stuff doesn't jump out as obviously different. However this doesn't look very nice on OSX. iOS appears to not use
             any subpixel smoothing anywhere but doesn't seem to look bad when using it. There are many possibilities for why. Some I can
             think of are they are setting some kind of graphics context mode I just haven't found yet, the rendering engines are
             fundamentally different, the fonts themselves are actually different, the DPI of the devices, voodoo, or the loch ness monster.
             */
        /*
             UPDATE: I've since flattened some of the main views in Twitterrific/Ostrich and so now I'd like to have subpixel turned on for
             the Mac, so I'm putting this code back in here. It tries to be smart about when to do it (because if it's on when it shouldn't
             be the results look very bad). As the note above said, this can and does result in some inconsistency with the rendering in
             the app depending on how things are done. Typical UIKit code is going to be lots of layers and thus text will mostly look bad
             with straight ports but at this point I really can't come up with a much better solution so it'll have to do.
             */
        /*
             UPDATE AGAIN: So, subpixel with light text against a dark background looks kinda crap and we can't seem to figure out how
             to make it not-crap right now. After messing with some fonts and things, we're currently turning subpixel off again instead.
             I have a feeling this may go round and round forever because some people can't stand subpixel and others can't stand not
             having it - even when its light-on-dark. We could turn it on here and selectively disable it in Twitterrific when using the
             dark theme, but that seems weird, too. We'd all rather there be just one approach here and skipping smoothing at least means
             that the whole app is consistent (views that aren't flattened won't look any different from the flattened views in terms of
             text rendering, at least). Bah.
             */
        //const BOOL shouldSmoothFonts = (_backgroundColor && (CGColorGetAlpha(_backgroundColor.CGColor) == 1)) || self.opaque;
        //CGContextSetShouldSmoothFonts(ctx, shouldSmoothFonts);
        CGContextSetShouldSmoothFonts(ctx, false)
        CGContextSetShouldSubpixelPositionFonts(ctx, true)
        CGContextSetShouldSubpixelQuantizeFonts(ctx, true)
        UIColor.blackColor().set()
        self.drawRect(bounds)
        CGContextRestoreGState(ctx)
        UIGraphicsPopContext()
    }

    convenience override init(theLayer: CALayer, forKey event: String) {
        if animationsEnabled && animationGroups.lastObject() && theLayer == layer {
            return animationGroups.lastObject().actionForView(self, forKey: event) ?? NSNull() as! AnyObject
        }
        else {
            return NSNull()
        }
    }

    func _superviewSizeDidChangeFrom(oldSize: CGSize, to newSize: CGSize) {
        if autoresizingMask != .None {
            var frame: CGRect = self.frame
            let delta: CGSize = CGSizeMake(newSize.width - oldSize.width, newSize.height - oldSize.height)
        }
    }
}
/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QuartzCore
    let UIViewFrameDidChangeNotification: String = "UIViewFrameDidChangeNotification"

    let UIViewBoundsDidChangeNotification: String = "UIViewBoundsDidChangeNotification"

    let UIViewDidMoveToSuperviewNotification: String = "UIViewDidMoveToSuperviewNotification"

    let UIViewHiddenDidChangeNotification: String = "UIViewHiddenDidChangeNotification"

    var self.animationGroups: [AnyObject]

    var self.animationsEnabled: Bool = true

//#define hasAutoresizingFor(x) ((_autoresizingMask & (x)) == (x))