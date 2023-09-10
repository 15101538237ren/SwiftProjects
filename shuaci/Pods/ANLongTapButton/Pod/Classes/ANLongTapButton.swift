//
//  ANLongTapButton.swift
//
//  Created by Sergey Demchenko on 11/5/15.
//  Copyright © 2015 antrix1989. All rights reserved.
//

import UIKit

@IBDesignable
public class ANLongTapButton: UIButton
{
    @IBInspectable public var barWidth: CGFloat = 10
    @IBInspectable public var barColor: UIColor = UIColor.yellow
    @IBInspectable public var barTrackColor: UIColor = UIColor.gray
    @IBInspectable public var bgCircleColor: UIColor = UIColor.blue
    @IBInspectable public var startAngle: CGFloat = -90
    @IBInspectable public var timePeriod: TimeInterval = 3
    
    /// Invokes when timePeriod has elapsed.
    public var didTimePeriodElapseBlock : (() -> Void) = { () -> Void in }
    
    /// Invokes when either time period has elapsed or when user cancels touch.
    public var didFinishBlock : (() -> Void) = { () -> Void in }
    
    var timePeriodTimer: Timer?
    var circleLayer: CAShapeLayer?
    var isFinished = true
    
    public override func prepareForInterfaceBuilder()
    {
        let center = self.center()
        let radius = self.radius()
        
        if let context = UIGraphicsGetCurrentContext() {
            drawBackground(context:context, center: center, radius: radius)
            drawBackgroundCircle(context:  context, center: center, radius: radius)
            drawTrackBar(context: context, center: center, radius: radius)
            drawProgressBar(context: context, center: center, radius: radius)
        }
    }
    
    public override func awakeFromNib()
    {
        super.awakeFromNib()
        
        addTarget(self, action: #selector(start), for: .touchDown)
        addTarget(self, action: #selector(cancel), for: .touchUpInside)
        addTarget(self, action: #selector(cancel), for: .touchCancel)
        addTarget(self, action: #selector(cancel), for: .touchDragExit)
        addTarget(self, action: #selector(cancel), for: .touchDragOutside)
    }
    
    public override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        
        let center = self.center()
        let radius = self.radius()
        
        if let context = UIGraphicsGetCurrentContext() {
            context.clear(rect)
            drawBackground(context: context, center: center, radius: radius)
            drawBackgroundCircle(context: context, center: center, radius: radius)
            drawTrackBar(context: context, center: center, radius: radius)
        }
    }
    
    // MARK: - Internal
    
    @objc func myPerformeCode(){
        self.timePeriodTimer?.invalidate()
        self.timePeriodTimer = nil
        self.isFinished = true
        self.didFinishBlock()
        self.didTimePeriodElapseBlock()
    }
    
    @objc func start(sender: AnyObject, forEvent event: UIEvent)
    {
        isFinished = false
        reset()
        
        timePeriodTimer = Timer.scheduledTimer(timeInterval: timePeriod, target: self, selector: #selector(myPerformeCode), userInfo: nil, repeats: false)
        
        
        let center = self.center()
        var radius = self.radius()
        radius = radius - (barWidth / 2)
        
        circleLayer = CAShapeLayer()
        circleLayer!.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: degreesToRadians(value: startAngle), endAngle: degreesToRadians(value: startAngle + 360), clockwise: true).cgPath
        circleLayer!.fillColor = UIColor.clear.cgColor
        circleLayer!.strokeColor = barColor.cgColor
        circleLayer!.lineWidth = barWidth
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = timePeriod
        animation.isRemovedOnCompletion = true
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        circleLayer!.add(animation, forKey: "drawCircleAnimation")
        self.layer.addSublayer(circleLayer!)
    }
    
    @objc func cancel(sender: AnyObject, forEvent event: UIEvent)
    {
        if !isFinished {
            isFinished = true
            didFinishBlock()
        }
        
        reset()
    }
    
    @objc func reset()
    {
        timePeriodTimer?.invalidate()
        timePeriodTimer = nil
        circleLayer?.removeAllAnimations()
        circleLayer?.removeFromSuperlayer()
        circleLayer = nil
    }
    
    func drawBackground(context: CGContext, center: CGPoint, radius: CGFloat)
    {
        if let backgroundColor = self.backgroundColor {
            context.setFillColor(backgroundColor.cgColor);
            context.fill(bounds)
        }
    }
    
    func drawBackgroundCircle(context: CGContext, center: CGPoint, radius: CGFloat)
    {
        context.setFillColor(bgCircleColor.cgColor)
        context.beginPath()
        context.addArc(center: center, radius: radius, startAngle: 0, endAngle: 360, clockwise: false)
        context.closePath()
        context.fillPath()
    }
    
    func drawTrackBar(context: CGContext, center: CGPoint, radius: CGFloat)
    {
        if (barWidth > radius) {
            barWidth = radius;
        }
        
        context.setFillColor(barTrackColor.cgColor)
        context.beginPath()
        context.addArc(center: center, radius: radius, startAngle: degreesToRadians(value: startAngle), endAngle: degreesToRadians(value: startAngle + 360), clockwise: false);
        context.addArc(center: center, radius: radius - barWidth, startAngle: degreesToRadians(value: startAngle + 360), endAngle: degreesToRadians(value: startAngle), clockwise: true);
        context.closePath()
        context.fillPath()
    }
    
    func drawProgressBar(context: CGContext, center: CGPoint, radius: CGFloat)
    {
        if (barWidth > radius) {
            barWidth = radius;
        }
        
        context.setFillColor(barColor.cgColor)
        context.beginPath()
        context.addArc(center: center, radius: radius, startAngle: degreesToRadians(value: startAngle), endAngle: degreesToRadians(value: startAngle + 90), clockwise: false);
        
        context.addArc(center: center, radius: radius - barWidth, startAngle: degreesToRadians(value: startAngle + 90), endAngle: degreesToRadians(value: startAngle), clockwise: true);
        context.closePath()
        context.fillPath()
    }
    
    // MARK: - Private
    
    private func center() -> CGPoint
    {
        return CGPointMake(bounds.size.width / 2, bounds.size.height / 2)
    }
    
    private func radius() -> CGFloat
    {
        let center = self.center()
        
        return min(center.x, center.y)
    }
    
    private func degreesToRadians (value: CGFloat) -> CGFloat { return value * CGFloat(Double.pi) / CGFloat(180.0) }
}
