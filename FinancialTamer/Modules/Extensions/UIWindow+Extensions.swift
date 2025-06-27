//
//  UIWindow+Extensions.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 26.06.2025.
//

import SwiftUI

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}
