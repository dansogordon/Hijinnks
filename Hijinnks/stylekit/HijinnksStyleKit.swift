//
//  HijinnksStyleKit.swift
//  Hijinnks
//
//  Created by Adebayo Ijidakinro on 2/19/17.
//  Copyright © 2017 Dephyned. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//



import UIKit

public class HijinnksStyleKit : NSObject {

    //// Cache

    private struct Cache {
        static var imageOfTextLogo: UIImage?
        static var textLogoTargets: [AnyObject]?
    }

    //// Drawing Methods

    public dynamic class func drawTextLogo(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 130, height: 53), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 130, height: 53), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 130, y: resizedFrame.height / 53)


        //// Color Declarations
        let textForeground = UIColor(red: 0.454, green: 0.203, blue: 0.544, alpha: 1.000)

        //// Label Drawing
        let labelRect = CGRect(x: 0, y: -0.46, width: 130, height: 53.46)
        let labelTextContent = "Hijinnks"
        let labelStyle = NSMutableParagraphStyle()
        labelStyle.alignment = .center
        let labelFontAttributes = [NSFontAttributeName: UIFont(name: "QuimbyGubernatorial", size: 30)!, NSForegroundColorAttributeName: textForeground, NSParagraphStyleAttributeName: labelStyle]

        let labelTextHeight: CGFloat = labelTextContent.boundingRect(with: CGSize(width: labelRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: labelFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: labelRect)
        labelTextContent.draw(in: CGRect(x: labelRect.minX, y: labelRect.minY + (labelRect.height - labelTextHeight) / 2, width: labelRect.width, height: labelTextHeight), withAttributes: labelFontAttributes)
        context.restoreGState()
        
        context.restoreGState()

    }

    public dynamic class func drawOrView(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 75, height: 75), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 75, height: 75), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 75, y: resizedFrame.height / 75)


        //// Color Declarations
        let fillColor = UIColor(red: 0.189, green: 0.286, blue: 0.607, alpha: 1.000)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 37.5, y: -0))
        bezierPath.addCurve(to: CGPoint(x: -0, y: 37.5), controlPoint1: CGPoint(x: 16.79, y: -0), controlPoint2: CGPoint(x: -0, y: 16.79))
        bezierPath.addLine(to: CGPoint(x: 9.34, y: 37.5))
        bezierPath.addCurve(to: CGPoint(x: 37.5, y: 9.34), controlPoint1: CGPoint(x: 9.34, y: 21.95), controlPoint2: CGPoint(x: 21.95, y: 9.34))
        bezierPath.addCurve(to: CGPoint(x: 65.66, y: 37.5), controlPoint1: CGPoint(x: 53.05, y: 9.34), controlPoint2: CGPoint(x: 65.66, y: 21.95))
        bezierPath.addCurve(to: CGPoint(x: 37.5, y: 65.66), controlPoint1: CGPoint(x: 65.66, y: 53.05), controlPoint2: CGPoint(x: 53.05, y: 65.66))
        bezierPath.addLine(to: CGPoint(x: 37.41, y: 65.66))
        bezierPath.addLine(to: CGPoint(x: 37.41, y: 75))
        bezierPath.addLine(to: CGPoint(x: 37.5, y: 75))
        bezierPath.addCurve(to: CGPoint(x: 75, y: 37.5), controlPoint1: CGPoint(x: 58.21, y: 75), controlPoint2: CGPoint(x: 75, y: 58.21))
        bezierPath.addCurve(to: CGPoint(x: 37.5, y: -0), controlPoint1: CGPoint(x: 75, y: 16.79), controlPoint2: CGPoint(x: 58.21, y: -0))
        bezierPath.close()
        fillColor.setFill()
        bezierPath.fill()
        
        context.restoreGState()

    }

    //// Generated Images

    public dynamic class var imageOfTextLogo: UIImage {
        if Cache.imageOfTextLogo != nil {
            return Cache.imageOfTextLogo!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 130, height: 53), false, 0)
            HijinnksStyleKit.drawTextLogo()

        Cache.imageOfTextLogo = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return Cache.imageOfTextLogo!
    }

    //// Customization Infrastructure

    @IBOutlet dynamic var textLogoTargets: [AnyObject]! {
        get { return Cache.textLogoTargets }
        set {
            Cache.textLogoTargets = newValue
            for target: AnyObject in newValue {
                let _ = target.perform(NSSelectorFromString("setImage:"), with: HijinnksStyleKit.imageOfTextLogo)
            }
        }
    }




    @objc public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.

        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
