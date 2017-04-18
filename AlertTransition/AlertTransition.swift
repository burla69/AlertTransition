//
//  AlertTransition.swift
//  AlertTransition
//
//  Created by 韩帅 on 2017/4/17.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import UIKit

/// If alert controller conforms to AlertFrameProtocol, the CGRect will be the final frame of alert. If alert controller do not conforms to it, alert will in center of screen, and it's height and width will be calculated from constraints.
public protocol AlertFrameProtocol {
    var alertFrame: CGRect { get }
}


public extension AlertTransition {
    enum TransitionState {
        case presented, dismissed
    }
    
    /// Alert background Type，UIColor or UIBlurEffect. If you want a color with alpha component, use withAlphaComponent in UIColor, eg: UIColor.blue.withAlphaComponent(0.5)
    enum BackgroundType {
        case color(UIColor)
        case blurEffect(style: UIBlurEffectStyle, alpha: CGFloat)
    }
}


open class AlertTransition: NSObject {
    
    
    // MARK: - for client
    
    /// Set animation duration
    public var duration: TimeInterval = 0.25
    /// Set Alert background color or use UIBlurEffect
    public var backgroundType: BackgroundType = .color(UIColor(white: 0.0, alpha: 0.5))
    /// If this property is YES, the alert will dismiss when you click on outside
    public var shouldDismissOutside = true
    
    
    // MARK: - for subclass
    
    /// Set Custom UIPercentDrivenInteractiveTransition and UIPresentationController, often set in init method of subclass
    public var interactionTransitionType: PercentDrivenInteractiveTransition.Type?
    public var presentationControllerType: UIPresentationController.Type = PresentationController.self
    /// The InteractionTransition initialize from interactionTransitionType at suitable time
    public internal(set) var interactionTransition: PercentDrivenInteractiveTransition?
    
    /// The alert controller
    public internal(set) weak var toController: UIViewController!
    /// The controller alert from
    public internal(set) weak var fromController: UIViewController?
    
    /// Is current transition present or dismiss
    public fileprivate(set) var transitionState = TransitionState.presented
    
    
    // MARK: - Init
    
    public init(fromController: UIViewController? = nil) {
        super.init()
        self.fromController = fromController
    }
    
    public override convenience init() {
        self.init(fromController: nil)
    }
    
    
    // MARK: - Methods should override by subclass
    
    /// Called in animateTransition(using transitionContext:),  when animation completed don’t forget to add `context.completeTransition(true/false)`
    open func performPresentedTransition(presentingView: UIView, presentedView: UIView,context: UIViewControllerContextTransitioning) { }
    open func performDismissedTransition(presentingView: UIView, presentedView: UIView,context: UIViewControllerContextTransitioning) { }
}


// MARK: - UIViewControllerTransitioningDelegate

extension AlertTransition: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionState = .presented
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionState = .dismissed
        return self
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = presentationControllerType.init(presentedViewController: presented, presenting: presenting)
        (presentationController as? PresentationController)?.transition = self
        return presentationController
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (interactionTransition?.isTransiting ?? false) ? interactionTransition : nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (interactionTransition?.isTransiting ?? false) ? interactionTransition : nil
    }
}


// MARK: - UIViewControllerAnimatedTransitioning

extension AlertTransition: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        transitionContext.toView?.frame = transitionContext.finalFrame(for: toController)
        
        if transitionState == .presented {
            interactionTransition?.setup(presentedView: transitionContext.toView!)
            
            performPresentedTransition(presentingView: transitionContext.fromController!.view, presentedView: transitionContext.toView!, context: transitionContext)
        } else {
            performDismissedTransition(presentingView: transitionContext.toController!.view, presentedView: transitionContext.fromView!, context: transitionContext)
        }
    }
}
