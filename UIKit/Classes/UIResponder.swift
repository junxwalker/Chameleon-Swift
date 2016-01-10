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

class UIResponder: NSObject {
    func nextResponder() -> UIResponder {
        return nil
    }

    func isFirstResponder() -> Bool {
        return (self._responderWindow()._firstResponder() == self)
    }

    func canBecomeFirstResponder() -> Bool {
        return false
    }

    func becomeFirstResponder() -> Bool {
        if self.isFirstResponder() {
            return true
        }
        else {
            var window: UIWindow! = self._responderWindow()
            var firstResponder: UIResponder = window._firstResponder()
            if window && self.canBecomeFirstResponder() {
                var didResign: Bool = false
                if firstResponder && firstResponder.canResignFirstResponder() {
                    didResign = firstResponder.resignFirstResponder()
                }
                else {
                    didResign = true
                }
                if didResign {
                    window._setFirstResponder(self)
                    if self.conformsToProtocol() {
                        // I have no idea how iOS manages this stuff, but here I'm modeling UIMenuController since it also uses the first
                        // responder to do its work. My thinking is that if there were an on-screen keyboard, something here could detect
                        // if self conforms to UITextInputTraits and UIKeyInput and/or UITextInput and then build/fetch the correct keyboard
                        // and assign that to the inputView property which would seperate the keyboard and inputs themselves from the stuff
                        // that actually displays them on screen. Of course on the Mac we don't need an on-screen keyboard, but there's
                        // possibly an argument to be made for supporting custom inputViews anyway.
                        var controller: UIInputController = UIInputController.sharedInputController()
                        controller.inputAccessoryView = self.inputAccessoryView
                        controller.inputView = self.inputView
                        controller.keyInputResponder = self as! UIResponder<UIKeyInput>
                        controller.setInputVisible(true, animated: true)
                        // key input won't very well work without this
                        window.makeKeyWindow()
                    }
                    return true
                }
            }
            return false
        }
    }

    func canResignFirstResponder() -> Bool {
        return true
    }

    func resignFirstResponder() -> Bool {
        if self.isFirstResponder() {
            self._responderWindow()._setFirstResponder(nil)
            UIInputController.sharedInputController().setInputVisible(false, animated: true)
        }
        return true
    }

    func canPerformAction(action: Selector, withSender sender: AnyObject) -> Bool {
        if self.instancesRespondToSelector(action) {
            return true
        }
        else {
            return self.nextResponder().canPerformAction(action, withSender: sender)
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.nextResponder().touchesBegan(touches, withEvent: event)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.nextResponder().touchesMoved(touches, withEvent: event)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.nextResponder().touchesEnded(touches, withEvent: event)
    }

    func touchesCancelled(touches: Set<AnyObject>, withEvent event: UIEvent) {
        self.nextResponder().touchesCancelled(touches, withEvent: event)
    }

    func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        self.nextResponder().motionBegan(motion, withEvent: event)
    }

    func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        self.nextResponder().motionEnded(motion, withEvent: event)
    }

    func motionCancelled(motion: UIEventSubtype, withEvent event: UIEvent) {
        self.nextResponder().motionCancelled(motion, withEvent: event)
    }
    var keyCommands: [AnyObject] {
        get {
            return nil
        }
    }

    var inputAccessoryView: UIView {
        get {
            return nil
        }
    }

    var inputView: UIView {
        get {
            return nil
        }
    }

    var undoManager: NSUndoManager {
        get {
            return self.nextResponder().undoManager()
        }
    }

    func _responderWindow() -> UIWindow {
        if (self is UIView) {
            return self as! UIView.window()
        }
        else {
            return self.nextResponder()._responderWindow()
        }
    }
    // curiously, the documentation states that all of the following methods do nothing by default but that
    // "immediate UIKit subclasses of UIResponder, particularly UIView, forward the message up the responder chain."
    // oddly, though, if I use class_getInstanceMethod() to print the address of the actual C function being used
    // by UIView, UIViewController, and UIResponder, they all point to the same function. So.... someone is wrong.
    // I'm going to leave it like this for now because this is a lot simpler, IMO, and seems nicely logical.
}
enum .s : Int {
    case UIKeyModifierAlphaShift = 1 << 16
    // capslock
    case UIKeyModifierShift = 1 << 17
    case UIKeyModifierControl = 1 << 18
    case UIKeyModifierAlternate = 1 << 19
    case UIKeyModifierCommand = 1 << 20
    case UIKeyModifierNumericPad = 1 << 21
}

    let UIKeyInputUpArrow: String

    let UIKeyInputDownArrow: String

    let UIKeyInputLeftArrow: String

    let UIKeyInputRightArrow: String

    let UIKeyInputEscape: String

class UIKeyCommand: NSObject, NSCopying, NSSecureCoding {
    class func keyCommandWithInput(input: String, modifierFlags: UIKeyModifierFlags, action: Selector) -> UIKeyCommand {
        // TODO
        return nil
    }
    var input: String {
        get {
            return self.input
        }
    }

    var modifierFlags: UIKeyModifierFlags {
        get {
            return self.modifierFlags
        }
    }

    class func supportsSecureCoding() -> Bool {
        return true
    }

    convenience required init(coder decoder: NSCoder) {
        // note, this requires NSSecureCoding, so you have to do something like this:
        //id obj = [decoder decodeObjectOfClass:[MyClass class] forKey:@"myKey"];
        // TODO
        return self()
    }

    func encodeWithCoder(encoder: NSCoder) {
        // TODO
    }

    convenience override init(zone: NSZone) {
        // this should be okay, because this is an immutable object

    }
}
extension NSObject {
    func copy(sender: AnyObject) {
    }

    func cut(sender: AnyObject) {
    }

    func delete(sender: AnyObject) {
    }

    func paste(sender: AnyObject) {
    }

    func select(sender: AnyObject) {
    }

    func selectAll(sender: AnyObject) {
    }

    func makeTextWritingDirectionLeftToRight(sender: AnyObject) {
    }

    func makeTextWritingDirectionRightToLeft(sender: AnyObject) {
    }

    func toggleBoldface(sender: AnyObject) {
    }

    func toggleItalics(sender: AnyObject) {
    }

    func toggleUnderline(sender: AnyObject) {
    }

    func increaseSize(sender: AnyObject) {
    }

    func decreaseSize(sender: AnyObject) {
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

    let UIKeyInputUpArrow: String = "UIKeyInputUpArrow"

    let UIKeyInputDownArrow: String = "UIKeyInputDownArrow"

    let UIKeyInputLeftArrow: String = "UIKeyInputLeftArrow"

    let UIKeyInputRightArrow: String = "UIKeyInputRightArrow"

    let UIKeyInputEscape: String = "UIKeyInputEscape"