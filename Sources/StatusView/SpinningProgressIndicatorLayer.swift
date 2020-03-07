//
//  SpinningProgressIndicatorLayer.swift
//
//  Copyright 2009 Kelan Champagne. All rights reserved.
//  Swift version by Stefan Klieme.
//

#if canImport(UIKit)
import UIKit
#else
import Cocoa
#endif

class SpinningProgressIndicatorLayer: CALayer {
    
    struct AnimationKey {
        static let rotation = "rotationAnimation"
        static let fade = "opacity"
    }
    //    let INDETERMINATE_FADE_ANIMATION = true
    
    struct FinGeometry {
        var bounds = CGRect.zero
        var anchorPoint = CGPoint.zero
        var position = CGPoint.zero
        var cornerRadius : CGFloat = 0.0
    }
    
    struct PieGeometry {
        var bounds = CGRect.zero
        var outerEdgeLength : CGFloat = 0.0
        var outlineWidth : CGFloat = 0.0
    }
    
    fileprivate var indeterminateCycleDuration : CFTimeInterval
    fileprivate var foreColor = STColor.clear.cgColor
    fileprivate var fullOpacity : Float
    fileprivate var indeterminateMinimumOpacity : Float
    fileprivate var numFins : UInt
    fileprivate var finLayersRoot : CALayer
    fileprivate var finLayers : Array<CALayer>
    fileprivate var finLayerRotationValues : Array<CGFloat>
    fileprivate var pieLayersRoot : CALayer
    fileprivate var pieOutline : CAShapeLayer!
    fileprivate var pieChartShape : CAShapeLayer!
    
    fileprivate var referenceSizeForShadowResizing  : CGSize {
        didSet {
            initialShadowRadius = self.shadowRadius
            initialShadowOffset = self.shadowOffset
            updateShadowDimensions()
        }
    }
    
    fileprivate var initialShadowRadius : CGFloat = 0.0
    fileprivate var initialShadowOffset = CGSize.zero
    
    var isRunning : Bool
    var isDeterminate : Bool = false {
        didSet {
            setupType()
        }
    }
    
    var color : STColor  { // "copy" because we don't retain it -- we create a CGColor from it
        get {
            #if os(macOS)
            return NSColor(cgColor: foreColor)!
            #else
            return UIColor(cgColor: foreColor)
            #endif
        }
        set {
            // Need to convert from NSColor to CGColor
            foreColor = newValue.cgColor
            
            // Update all of the fins to this new color, at once, immediately
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            for fin in finLayers {
                fin.backgroundColor = foreColor
            }
            
            if pieOutline != nil { pieOutline.strokeColor = foreColor }
            if pieChartShape != nil { pieChartShape.strokeColor = foreColor }
            
            CATransaction.commit()
        }
    }
    var resizeShadows : Bool
    
    var doubleValue : Double {
        didSet {
            if !determinateTweenTime.isNaN {
                CATransaction.begin()
                
                // This controls the transition from one doubleValue to the next.
                CATransaction.setAnimationDuration(determinateTweenTime)
            }
            
            pieChartShape.strokeEnd = CGFloat(doubleValue / maxValue)
            
            if !determinateTweenTime.isNaN {
                CATransaction.commit()
            }
        }
    }
    
    // For determinate-mode only.
    var maxValue : Double = 0.0
    
    var determinateProgressOpacity : Float {
        get { return pieChartShape.opacity }
        set { pieChartShape.opacity = newValue }
    }
    
    var determinateTweenTime : CFTimeInterval = 0.0 // Smoothes animation to new doubleValue. 0.0: disable smooth transition, hard jump.
    
    //MARK: - Init
    
    convenience override init()
    {
        self.init(indeterminateCycleDuration:CFTimeInterval(0.7), determinateTweenTime:CFTimeInterval.nan) // Use Core Animation default.
    }
    
    init(indeterminateCycleDuration : CFTimeInterval, determinateTweenTime : CFTimeInterval)
    {
        self.indeterminateCycleDuration = indeterminateCycleDuration
        self.determinateTweenTime = determinateTweenTime
        self.numFins = 12
        finLayers = Array<CALayer>()
        finLayersRoot = CALayer()
        pieLayersRoot  = CALayer()
        //_finLayersRoot.anchorPoint = CGPointMake(0.5, 0.5) // This is the default.
        finLayerRotationValues = Array<CGFloat>()
        fullOpacity = 1.0
        indeterminateMinimumOpacity = 0.05
        isRunning = false
        resizeShadows = false
        isDeterminate = false
        maxValue = 100.0
        doubleValue = 0.0
        referenceSizeForShadowResizing = CGSize(width: 100.0, height: 100.0)
        
        super.init()
        self.color = STColor.black
        self.addSublayer(finLayersRoot)
        self.bounds = CGRect(x:0.0, y:0.0, width:10.0, height:10.0)
        
        createFinLayers()
        createDeterminateLayers()
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeFinLayers()
    }
    
    //MARK: - Overrides
    
    override var bounds : CGRect
        {
        didSet {
            // Do the resizing all at once, immediately.
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            
            // Resize the fins.
            let finBounds = bounds
            let finGeo = finGeometryFor(bounds: finBounds)
            
            finLayersRoot.bounds = finBounds
            finLayersRoot.position = yrkCGRectGet(center:finBounds)
            for fin in finLayers {
                fin.bounds = finGeo.bounds
                fin.anchorPoint = finGeo.anchorPoint
                fin.position = finGeo.position
                fin.cornerRadius = finGeo.cornerRadius
            }
            
            // Scale pie.
            let pieGeo = pieGeometryFor(bounds: bounds)
            let pieGeoBounds = pieGeo.bounds
            
            pieLayersRoot.bounds = pieGeoBounds
            pieLayersRoot.position = yrkCGRectGet(center:pieGeoBounds)
            
            if pieOutline != nil {
                updateDimensionsOf(outlineShape:pieOutline, for: pieGeo)
            }
            if pieChartShape != nil {
                updateDimensionsOf(pieChartShape:pieChartShape, for: pieGeo)
            }
            
            updateShadowDimensions()
            
            CATransaction.commit()
        }
    }
    
    func updateShadowDimensions()
    {
        if resizeShadows {
            let scaleFactors = shadowScaleFactorsFor(bounds:self.bounds)
            let scaleFactor = shorterDimensionFor(size: scaleFactors)
            
            var scaledShadowOffset = initialShadowOffset
            scaledShadowOffset.width *= scaleFactor
            scaledShadowOffset.height *= scaleFactor
            
            shadowRadius = initialShadowRadius * scaleFactor
            shadowOffset = scaledShadowOffset
            
            // We could resize the sublayers’ shadows here.
        }
    }
    
    
    //MARK: - Animation
    
    func startProgressAnimation()
    {
        isRunning = true
        
        addSublayer(finLayersRoot)
        animateFinLayers()
    }
    
    func stopProgressAnimation()
    {
        isRunning = false
        
        deanimateFinLayers()
        finLayersRoot.removeFromSuperlayer()
    }
    
    func toggleProgressAnimation()
    {
        if isRunning {
            stopProgressAnimation()
        }
        else {
            startProgressAnimation()
        }
    }
    
    
    //MARK: - Helper Methods
    
    func setupType()
    {
        if isDeterminate {
            setupDeterminate()
        } else {
            setupIndeterminate()
        }
    }
    
    func setupIndeterminate()
    {
        pieLayersRoot.removeFromSuperlayer()
        addSublayer(finLayersRoot)
    }
    
    func setupDeterminate()
    {
        stopProgressAnimation()
        finLayersRoot.removeFromSuperlayer()
        addSublayer(pieLayersRoot)
    }
    
    func shadowScaleFactorsFor(bounds : CGRect) -> CGSize
    {
        let initialSize = referenceSizeForShadowResizing
        var scaleFactors = bounds.size
        scaleFactors.width /= initialSize.width
        scaleFactors.height /= initialSize.height
        return scaleFactors
    }
    
    func createFinLayers()
    {
        removeFinLayers()
        
        let selfBounds = self.bounds
        finLayersRoot.bounds = selfBounds
        finLayersRoot.position = yrkCGRectGet(center:selfBounds)
        
        // Create new fin layers
        let finBounds = finLayersRoot.bounds
        let finGeo : FinGeometry = finGeometryFor(bounds:finBounds)
        
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        
        let rotationAngleBetweenFins : CGFloat =  .pi * -2.0 / CGFloat(numFins)
        
        finLayerRotationValues.removeAll()
        
        for index in 0..<numFins {
            let newFin = CALayer()
            
            let rotationAngle = rotationAngleBetweenFins * CGFloat(index)
            
            newFin.bounds = finGeo.bounds
            newFin.anchorPoint = finGeo.anchorPoint
            newFin.position = finGeo.position
            newFin.transform = CATransform3DMakeRotation(rotationAngle, 0.0, 0.0, 1.0)
            newFin.cornerRadius = finGeo.cornerRadius
            newFin.backgroundColor = foreColor
            
            finLayerRotationValues.append(rotationAngle)
            
            newFin.opacity = initialOpacityForFinAt(index)
            
            finLayersRoot.addSublayer(newFin)
            finLayers.append(newFin)
        }
        
        CATransaction.commit()
    }
    
    func initialOpacityForFinAt(_ index : UInt) -> Float
    {
        let fadePercent : CGFloat = 1.0 - CGFloat(index) /  CGFloat(numFins - 1)
        return indeterminateMinimumOpacity + ((fullOpacity - indeterminateMinimumOpacity) * Float(fadePercent))
    }
    
    func animateFinLayers()
    {
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        deanimateFinLayers()
        
        //        if INDETERMINATE_FADE_ANIMATION {
        var index : CFTimeInterval = 0
        
        for finLayer in finLayers {
            let now = finLayer.convertTime(CACurrentMediaTime(), from:nil)
            
            finLayer.opacity = indeterminateMinimumOpacity
            let fadeOut = CABasicAnimation(keyPath: AnimationKey.fade)
            fadeOut.fromValue = fullOpacity
            fadeOut.toValue = indeterminateMinimumOpacity
            
            fadeOut.duration = indeterminateCycleDuration
            let timeOffset : CFTimeInterval = indeterminateCycleDuration - (indeterminateCycleDuration * index / CFTimeInterval(numFins - 1))
            fadeOut.beginTime = now - timeOffset
#if swift(>=4.2)
            fadeOut.fillMode = CAMediaTimingFillMode.backwards
#else
            fadeOut.fillMode = kCAFillModeBackwards
#endif
            fadeOut.repeatCount = Float.infinity
            finLayer.add(fadeOut, forKey:AnimationKey.fade)
            index += 1
        }
        //        } else {
        //            let animation = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        //            animation.duration = indeterminateCycleDuration
        //            animation.cumulative = false
        //            animation.repeatCount = Float.infinity
        //            animation.values = finLayerRotationValues
        //            animation.removedOnCompletion = false
        //            animation.calculationMode = kCAAnimationDiscrete
        //
        //            finLayersRoot.addAnimation(animation, forKey:RotationAnimationKey)
        //        }
        
        CATransaction.commit()
    }
    
    func deanimateFinLayers()
    {
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        
        //        if INDETERMINATE_FADE_ANIMATION {
        for finLayer in finLayers {
            finLayer.removeAnimation(forKey: AnimationKey.fade)
        }
        //        } else {
        //            finLayersRoot.removeAnimationForKey(RotationAnimationKey)
        //        }
        
        CATransaction.commit()
    }
    
    func removeFinLayers()
    {
        for finLayer in finLayers {
            finLayer.removeFromSuperlayer()
        }
        finLayers.removeAll()
    }
    
    // These are proportional to the size of the drawn determinate progress indicator.
    let OutlineWidthPercentage : CGFloat = 1.0 / 16.0
    let PieChartPaddingPercentage : CGFloat = (1.0 / 16.0 / 2.0) // The padding around the pie chart.
    let DeterminateLayersMarginPercentage : CGFloat = 0.98 // Selected to look good with current indeterminate settings.
    
    fileprivate func pieGeometryFor(bounds : CGRect) -> PieGeometry
    {
        var pieGeo =  PieGeometry()
        
        // Make sure the circles will fit the frame.
        
        var outerEdgeLength = shorterDimensionFor(size:bounds.size)
        outerEdgeLength *= DeterminateLayersMarginPercentage
        let xInset = (bounds.width - outerEdgeLength) / 2.0
        let yInset = (bounds.height - outerEdgeLength) / 2.0
        
        pieGeo.outerEdgeLength = outerEdgeLength
        pieGeo.bounds = bounds.insetBy(dx: xInset, dy: yInset)
        pieGeo.outlineWidth = pieGeo.outerEdgeLength * OutlineWidthPercentage // This used to be rounded.
        return pieGeo
    }
    
    fileprivate func updateDimensionsOf(outlineShape : CAShapeLayer, for geometry : PieGeometry)
    {
        let outlineInset = geometry.outlineWidth / 2
        let outlineRect = geometry.bounds.insetBy(dx: outlineInset, dy: outlineInset)
        
        var outlineTransform = CGAffineTransformForRotatingRectAround(center:outlineRect, angle:radiansFrom(degrees:90.0))
        let outlineFlip = CGAffineTransformForScalingRectAround(center:outlineRect, sx:-1.0, sy:1.0) // Flip left<->right.
        outlineTransform = outlineTransform.concatenating(outlineFlip)
        
        let outlinePath = CGPath(ellipseIn: outlineRect, transform: &outlineTransform)
        outlineShape.path = outlinePath
        
        outlineShape.lineWidth = geometry.outlineWidth
    }
    
    fileprivate func updateDimensionsOf(pieChartShape : CAShapeLayer, for geometry : PieGeometry)
    {
        let outerRadius : CGFloat = geometry.outerEdgeLength / 2.0
        
        // The pie chart is drawn using a circular line
        // with a line width equal to twice the radius.
        // So we draw from every point on this line, which you can picture as a centerline,
        // radius units towards and away from the center, reaching the center exactly.
        // This way, we get a full circle, if the full length of the line is draw.
        let pieChartExtraInset : CGFloat = (geometry.outerEdgeLength * PieChartPaddingPercentage)
        let pieChartInset : CGFloat = (outerRadius + geometry.outlineWidth + pieChartExtraInset) / 2
        let pieChartCenterlineRadius : CGFloat = outerRadius - pieChartInset
        let pieChartOutlineRadius : CGFloat = pieChartCenterlineRadius * 2
        let pieChartRect : CGRect = geometry.bounds.insetBy(dx: pieChartInset, dy: pieChartInset)
        
        var pieChartTransform = CGAffineTransformForRotatingRectAround(center :pieChartRect, angle:radiansFrom(degrees:90.0))
        let pieChartFlip = CGAffineTransformForScalingRectAround(center:pieChartRect, sx:-1.0, sy:1.0) // Flip left<->right.
        pieChartTransform = pieChartTransform.concatenating(pieChartFlip)
        
        let pieChartPath = CGPath(ellipseIn: pieChartRect, transform: &pieChartTransform)
        pieChartShape.path = pieChartPath
        
        pieChartShape.lineWidth = pieChartOutlineRadius
    }
    
    func createDeterminateLayers()
    {
        removeDeterminateLayers()
        
        // Based on DRPieChartProgressView by David Rönnqvist:
        // https://github.com/JanX2/cocoaheads-coreanimation-samplecode
        
        let pieGeo = pieGeometryFor(bounds:self.bounds)
        
        let pieGeoBounds = pieGeo.bounds
        pieLayersRoot.bounds = pieGeoBounds
        pieLayersRoot.position = yrkCGRectGet(center:pieGeoBounds)
        
        // Create new determinate layers.
        
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        
        let foregroundColor = foreColor
        let clearColor = STColor.clear.cgColor
        
        // Calculate the radius for the outline. Since strokes are centered,
        // the shape needs to be inset half the stroke width.
        pieOutline = CAShapeLayer()
        pieOutline.opacity = fullOpacity
        updateDimensionsOf(outlineShape:pieOutline!, for: pieGeo)
        
        // Draw only the line of the circular outline shape.
        pieOutline.fillColor =    clearColor
        pieOutline.strokeColor =  foregroundColor
        
        // Create the pie chart shape layer. It should fill from the center,
        // all the way out (excluding some extra space (equal to the width of
        // the outline)).
        pieChartShape = CAShapeLayer()
        pieChartShape.opacity = fullOpacity
        updateDimensionsOf(pieChartShape:pieChartShape, for: pieGeo)
        
        // We don't want to fill the pie chart since that will be visible
        // even when we change the stroke start and stroke end. Instead
        // we only draw the stroke with the width calculated above.
        pieChartShape.fillColor = clearColor
        pieChartShape.strokeColor = foregroundColor
        
        // Add sublayers.
        pieLayersRoot.addSublayer(pieOutline)
        pieLayersRoot.addSublayer(pieChartShape)
        
        pieChartShape.strokeStart = 0.0
        pieChartShape.strokeEnd = 0.0
        
        CATransaction.commit()
    }
    
    func removeDeterminateLayers()
    {
        if let sublayers = pieLayersRoot.sublayers {
            for pieLayer in sublayers {
                pieLayer.removeFromSuperlayer()
            }
        }
    }
    
    func radiansFrom(degrees : CGFloat) -> CGFloat
    {
        return degrees * .pi / 180.0
    }
    
    fileprivate func CGAffineTransformForRotatingRectAround(center rect : CGRect, angle : CGFloat) -> CGAffineTransform
    {
        var transform = CGAffineTransform.identity
        
        transform = transform.translatedBy(x: rect.midX, y: rect.midY)
        transform = transform.rotated(by: angle)
        transform = transform.translatedBy(x: -rect.midX, y: -rect.midY)
        
        return transform
    }
    
    fileprivate func CGAffineTransformForScalingRectAround(center rect : CGRect, sx : CGFloat, sy : CGFloat)  -> CGAffineTransform
    {
        var transform = CGAffineTransform.identity
        
        transform = transform.translatedBy(x: rect.midX, y: rect.midY)
        transform = transform.scaledBy(x: sx, y: sy)
        transform = transform.translatedBy(x: -rect.midX, y: -rect.midY)
        
        return transform
    }
    
    fileprivate func finGeometryFor(bounds : CGRect) -> FinGeometry {
        let finBounds = finBoundsFor(bounds:bounds)
        return FinGeometry(bounds: finBounds,
                           anchorPoint: finAnchorPoint(),
                           position: CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2),
                           cornerRadius: finBounds.size.width / 2)
    }
    
    let FinWidthPercent : CGFloat = 0.095
    let FinHeightPercent : CGFloat = 0.30
    let FinAnchorPointVerticalOffsetPercent : CGFloat = -0.63 // Aesthetically pleasing value. Also indirectly determines margin.
    
    fileprivate func finBoundsFor(bounds : CGRect) -> CGRect {
        let size = bounds.size
        let minSide = shorterDimensionFor(size:size)
        let width : CGFloat = minSide * FinWidthPercent
        let height : CGFloat = minSide * FinHeightPercent
        
        return CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    fileprivate func finAnchorPoint() -> CGPoint {
        // Horizentally centered, vertically offset.
        return CGPoint(x: 0.5, y: FinAnchorPointVerticalOffsetPercent)
    }
    
    fileprivate func yrkCGRectGet(center rect : CGRect) -> CGPoint {
        return CGPoint(x: rect.midX, y: rect.midY);
    }
    
    fileprivate func shorterDimensionFor(size : CGSize ) -> CGFloat {
        return min(size.width, size.height);
    }
    
}
