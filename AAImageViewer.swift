//
//  AAImageViewer.swift
//  AAImagePicker
//
//  Created by Muhammad Ahsan Ali on 2020/12/18.
//

import Foundation
import UIKit

public struct AAImageViewOptions {
    
    public enum ImageMode : Int {
        case aspectFit  = 1
        case aspectFill = 2
    }
    
    public let image     : UIImage
    public let imageMode : ImageMode
    public var imageHD   : URL?
    
    public var duration: TimeInterval = 0.35
    public var canSwipe: Bool         = true
    
    weak var fromView: UIView?
    
    fileprivate var fromRect: CGRect!
    fileprivate var convertedRect: CGRect!
    
    public var contentMode : UIView.ContentMode {
        return UIView.ContentMode(rawValue: imageMode.rawValue)!
    }
    
    public init(image: UIImage, imageMode: ImageMode, imageHD: URL?, fromView: UIView) {
        self.image     = image
        self.imageMode = imageMode
        self.imageHD = imageHD
        self.fromView = fromView
    }
    
    public init(image: UIImage, imageMode: ImageMode, imageHD: URL?, fromRect: CGRect) {
        self.image     = image
        self.imageMode = imageMode
        self.imageHD = imageHD
        self.convertedRect = fromRect
    }
    
    func calculate(rect: CGRect, origin: CGPoint? = nil, imageMode: ImageMode? = nil) -> CGRect {
        switch imageMode ?? self.imageMode {
        
        case .aspectFit:
            return rect
            
        case .aspectFill:
            let r = max(rect.size.width / image.size.width, rect.size.height / image.size.height)
            let w = image.size.width * r
            let h = image.size.height * r
            
            return CGRect(
                x      : origin?.x ?? rect.origin.x - (w - rect.width) / 2,
                y      : origin?.y ?? rect.origin.y - (h - rect.height) / 2,
                width  : w,
                height : h
            )
        }
    }
    
    func calculateMaximumZoomScale(_ size: CGSize) -> CGFloat {
        return max(2, max(
            image.size.width  / size.width,
            image.size.height / size.height
        ))
    }
    
}

open class AAImageViewController: UIViewController {
    
    public let imageView  = UIImageView()
    public let scrollView = UIScrollView()
    
    public var imageInfo: AAImageViewOptions
        
    open var dismissCompletion: (() -> Void)?
    
    open var backgroundColor: UIColor = .black {
        didSet {
            view.backgroundColor = backgroundColor
        }
    }
    
    open lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
    }()
    
    // MARK: Initialization
    
    public init(imageInfo: AAImageViewOptions) {
        self.imageInfo = imageInfo
        super.init(nibName: nil, bundle: nil)
        
        if let fromView = imageInfo.fromView, let referenceView = fromView.superview {
            self.imageInfo.fromRect = referenceView.convert(fromView.frame, to: nil)
            
            if fromView.contentMode != imageInfo.contentMode {
                self.imageInfo.convertedRect = imageInfo.calculate(
                    rect: self.imageInfo.fromRect!,
                    imageMode: AAImageViewOptions.ImageMode(rawValue: fromView.contentMode.rawValue)
                )
            } else {
                self.imageInfo.convertedRect = imageInfo.fromRect
            }
        }
        
        if imageInfo.convertedRect != nil {
            self.transitioningDelegate = self
            self.modalPresentationStyle = .overFullScreen
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScrollView()
        setupImageView()
        setupGesture()
        setupImageHD()
        
        edgesForExtendedLayout = UIRectEdge()
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        imageView.frame = imageInfo.calculate(rect: view.bounds, origin: .zero)
        
        scrollView.frame = view.bounds
        scrollView.contentSize = imageView.bounds.size
        scrollView.maximumZoomScale = imageInfo.calculateMaximumZoomScale(scrollView.bounds.size)
    }
    
    // MARK: Setups
    
    fileprivate func setupView() {
        view.backgroundColor = backgroundColor
    }
    
    fileprivate func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
    }
    
    fileprivate func setupImageView() {
        imageView.image = imageInfo.image
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
    }
    
    fileprivate func setupGesture() {
        let single = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        let double = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        double.numberOfTapsRequired = 2
        single.require(toFail: double)
        scrollView.addGestureRecognizer(single)
        scrollView.addGestureRecognizer(double)
        
        if imageInfo.canSwipe == true {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
            pan.delegate = self
            scrollView.addGestureRecognizer(pan)
        }
    }
    
    fileprivate func setupImageHD() {
        guard let imageHD = imageInfo.imageHD else { return }
        
        let request = URLRequest(url: imageHD, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }
            self.imageView.image = image
            self.view.layoutIfNeeded()
        })
        task.resume()
    }
    
    // MARK: Gesture
    
    @objc fileprivate func singleTap() {
        if navigationController == nil || (presentingViewController != nil && navigationController!.viewControllers.count <= 1) {
            dismiss(animated: true, completion: dismissCompletion)
        }
    }
    
    @objc fileprivate func doubleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: scrollView)
        
        if scrollView.zoomScale == 1.0 {
            scrollView.zoom(to: CGRect(x: point.x-40, y: point.y-40, width: 80, height: 80), animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    fileprivate var panViewOrigin : CGPoint?
    fileprivate var panViewAlpha  : CGFloat = 1
    
    @objc fileprivate func pan(_ gesture: UIPanGestureRecognizer) {
        
        func getProgress() -> CGFloat {
            let origin = panViewOrigin!
            let changeX = abs(scrollView.center.x - origin.x)
            let changeY = abs(scrollView.center.y - origin.y)
            let progressX = changeX / view.bounds.width
            let progressY = changeY / view.bounds.height
            return max(progressX, progressY)
        }
        
        func getChanged() -> CGPoint {
            let origin = scrollView.center
            let change = gesture.translation(in: view)
            return CGPoint(x: origin.x + change.x, y: origin.y + change.y)
        }
        
        func getVelocity() -> CGFloat {
            let vel = gesture.velocity(in: scrollView)
            return sqrt(vel.x*vel.x + vel.y*vel.y)
        }
        
        switch gesture.state {
        
        case .began:
            
            panViewOrigin = scrollView.center
            
        case .changed:
            
            scrollView.center = getChanged()
            panViewAlpha = 1 - getProgress()
            view.backgroundColor = backgroundColor.withAlphaComponent(panViewAlpha)
            gesture.setTranslation(CGPoint.zero, in: nil)
            
        case .ended:
            
            if getProgress() > 0.25 || getVelocity() > 1000 {
                dismiss(animated: true, completion: dismissCompletion)
            } else {
                fallthrough
            }
            
        default:
            
            UIView.animate(withDuration: 0.3,
                           animations: {
                            self.scrollView.center = self.panViewOrigin!
                            self.view.backgroundColor = self.backgroundColor
                           },
                           completion: { _ in
                            self.panViewOrigin = nil
                            self.panViewAlpha  = 1.0
                           }
            )
            
        }
    }
    
}

extension AAImageViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.frame = imageInfo.calculate(rect: CGRect(origin: .zero, size: scrollView.contentSize), origin: .zero)
    }
    
}

extension AAImageViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return GSImageViewerTransition(imageInfo: imageInfo, transitionMode: .present)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return GSImageViewerTransition(imageInfo: imageInfo, transitionMode: .dismiss)
    }
    
}

class GSImageViewerTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let imageInfo      : AAImageViewOptions
    var transitionMode : TransitionMode
    
    enum TransitionMode {
        case present
        case dismiss
    }
    
    init(imageInfo: AAImageViewOptions, transitionMode: TransitionMode) {
        self.imageInfo = imageInfo
        self.transitionMode = transitionMode
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return imageInfo.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        let tempBackground = UIView()
        tempBackground.backgroundColor = UIColor.black
        
        let tempMask = UIView()
        tempMask.backgroundColor = .black
        tempMask.layer.cornerRadius = imageInfo.fromView?.layer.cornerRadius ?? 0
        tempMask.layer.masksToBounds = imageInfo.fromView?.layer.masksToBounds ?? false
        
        let tempImage = UIImageView(image: imageInfo.image)
        tempImage.contentMode = imageInfo.contentMode
        tempImage.mask = tempMask
        
        containerView.addSubview(tempBackground)
        containerView.addSubview(tempImage)
        
        if transitionMode == .present {
            let imageViewer = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! AAImageViewController
            imageViewer.view.layoutIfNeeded()
            
            tempBackground.alpha = 0
            tempBackground.frame = imageViewer.view.bounds
            tempImage.frame = imageInfo.convertedRect
            tempMask.frame = tempImage.convert(imageInfo.fromRect, from: nil)
            
            imageInfo.fromView?.alpha = 0
            
            UIView.animate(withDuration: imageInfo.duration, animations: {
                tempBackground.alpha  = 1
                tempImage.frame = imageViewer.imageView.frame
                tempMask.frame = tempImage.bounds
            }, completion: { _ in
                tempBackground.removeFromSuperview()
                tempImage.removeFromSuperview()
                containerView.addSubview(imageViewer.view)
                transitionContext.completeTransition(true)
            })
        }
        
        else if transitionMode == .dismiss {
            let imageViewer = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! AAImageViewController
            imageViewer.view.removeFromSuperview()
            
            tempBackground.alpha = imageViewer.panViewAlpha
            tempBackground.frame = imageViewer.view.bounds
            
            if imageViewer.scrollView.zoomScale == 1 && imageInfo.imageMode == .aspectFit {
                tempImage.frame = imageViewer.scrollView.frame
            } else {
                tempImage.frame = CGRect(x: imageViewer.scrollView.contentOffset.x * -1, y: imageViewer.scrollView.contentOffset.y * -1, width: imageViewer.scrollView.contentSize.width, height: imageViewer.scrollView.contentSize.height)
            }
            
            tempMask.frame = tempImage.bounds
            
            UIView.animate(withDuration: imageInfo.duration, animations: {
                tempBackground.alpha = 0
                tempImage.frame = self.imageInfo.convertedRect
                tempMask.frame = tempImage.convert(self.imageInfo.fromRect, from: nil)
            }, completion: { _ in
                tempBackground.removeFromSuperview()
                tempImage.removeFromSuperview()
                imageViewer.view.removeFromSuperview()
                self.imageInfo.fromView?.alpha = 1
                transitionContext.completeTransition(true)
            })
        }
    }
}

extension AAImageViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            if scrollView.zoomScale != 1.0 {
                return false
            }
            if imageInfo.imageMode == .aspectFill && (scrollView.contentOffset.x > 0 || pan.translation(in: view).x <= 0) {
                return false
            }
        }
        return true
    }
    
}
