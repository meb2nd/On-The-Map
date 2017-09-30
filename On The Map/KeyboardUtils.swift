//
//  KeyboardUtils.swift
//  On The Map
//
//  Created by Pete Barnes on 9/30/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Keyboard Offset Functions
func getKeyboardOffset(forTextInput textInput: UITextInput?, view: UIView, _ notification: Notification) -> CGFloat {
    let userInfo = (notification as NSNotification).userInfo
    let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
    
    // Make sure text input does not move out of view
    if let activeField = textInput as? UITextField {
        let textFieldOrigin = activeField.convert(activeField.frame.origin, to: view)
        return calculateOffset(fromTextInputOrigin: textFieldOrigin, fieldFrame: activeField.frame, keyBoardSize: keyboardSize)
        
    } else if let activeField = textInput as? UITextView {
        let textFieldOrigin = activeField.convert(activeField.frame.origin, to: view)
        return calculateOffset(fromTextInputOrigin: textFieldOrigin, fieldFrame: activeField.frame, keyBoardSize: keyboardSize)
        
    } else {
        return keyboardSize.cgRectValue.height
    }
}

private func calculateOffset (fromTextInputOrigin textInputOrigin: CGPoint, fieldFrame: CGRect, keyBoardSize: NSValue)  -> CGFloat {
    let offset = textInputOrigin.y - fieldFrame.height
    return keyBoardSize.cgRectValue.height > offset ? offset: keyBoardSize.cgRectValue.height
}
