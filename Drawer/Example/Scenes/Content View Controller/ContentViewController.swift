//
//  ContentViewController.swift
//  DrawerExample
//
//  Created by Andrei Hogea on 26/02/2019.
//  Copyright (c) 2019 Andrei Hogea. All rights reserved.
//

import UIKit
import Drawer

class ContentViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var collapseButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Properties
    
    var embedDelegate: EmbeddableContentDelegate?
    private var animationDuration: TimeInterval = 1
   
    // title animations
    private var runningAnimators: [UIViewPropertyAnimator] = []
    private var titleAnimator: UIViewPropertyAnimator!
    private let titleScaleMax: CGFloat = 1.6

    // MARK: - Init
    
    class func instantiate() -> ContentViewController {
        let name = "\(ContentViewController.self)"
        let storyboard = UIStoryboard(name: name, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: name) as! ContentViewController
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleAnimator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1)
        titleAnimator.addAnimations {
            
        }
        adjustDrawer(with: 400, with: 100)
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 2
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowOpacity = 0.3
        view.clipsToBounds = false
        view.layer.masksToBounds = false
    }
    
    private func adjustDrawer(with maxHeight: CGFloat, with minHeight: CGFloat) {

        let options: [Drawer.Configuration.Key : Any] = [
            .animationDuration: 0.5,
            .fullHeight: maxHeight,
            .minimumHeight: minHeight,
            .initialState: Drawer.State.minimized,
            .cornerRadius: Drawer.Configuration.CornerRadius(fullSize: 20,
                                                             minimized: 0)
        ]

        let contentConfiguration = Drawer.Configuration(options: options,
                                                        dismissCompleteCallback: nil)
        
        embedDelegate?.handle(action: .layoutUpdated(config: contentConfiguration))
    }
    
    // MARK: - Callbacks -
    
    @IBAction func expandTapped(_ sender: Any) {
        embedDelegate?.handle(action: .changeState(to: .fullScreen))
    }
    
    @IBAction func collapseTapped(_ sender: Any) {
        embedDelegate?.handle(action: .changeState(to: .minimize))
    }
    
}

extension ContentViewController: Embeddable {
    func willChangeState(to state: EmbeddableState) {
        runningAnimators.forEach({
            $0.stopAnimation(false)
            $0.finishAnimation(at: .current)
        })
        let transform: CGAffineTransform
        let collapseAlpha: CGFloat
        let expandAlpha: CGFloat
        
        guard runningAnimators.isEmpty else { return }

        switch state {
        case .minimized:
            transform = .identity
            collapseAlpha = 0
            expandAlpha = 1
        case .fullSize:
            transform = CGAffineTransform(scaleX: titleScaleMax, y: titleScaleMax).concatenating(CGAffineTransform(translationX: 25, y: 0))
            collapseAlpha = 1
            expandAlpha = 0
        default:
            transform = .identity
            collapseAlpha = 0
            expandAlpha = 1
        }
        
        titleAnimator.addAnimations {
            self.titleLabel.transform = transform
            self.collapseButton.alpha = collapseAlpha
            self.expandButton.alpha = expandAlpha
        }
        titleAnimator.addCompletion {_ in
            self.titleLabel.transform = transform
            self.collapseButton.alpha = collapseAlpha
            self.expandButton.alpha = expandAlpha
            self.runningAnimators.removeAll()
        }
        
        titleAnimator.startAnimation()
        runningAnimators.append(titleAnimator)
    }
    
    func didChangeState(to state: EmbeddableState) {
        switch state {
        case .minimized:
            collapseButton.alpha = 0
            expandButton.alpha = 1
        case .fullSize:
            collapseButton.alpha = 1
            expandButton.alpha = 0
        case .closed:
            break
        }
        
        runningAnimators.forEach({
            $0.stopAnimation(false)
            $0.finishAnimation(at: .end)
        })
    }
    
    func didScroll(with progress: CGFloat, from state: Drawer.State) {
        runningAnimators.forEach({$0.pauseAnimation()})
        switch state {
        case .fullSize:
            collapseButton.alpha = 1 - progress
            expandButton.alpha = progress
            titleAnimator.fractionComplete = progress
        case .minimized:
            collapseButton.alpha = progress
            expandButton.alpha = 1 - progress
            titleAnimator.fractionComplete =  progress
        }
        
        runningAnimators.forEach({$0.continueAnimation(withTimingParameters: nil, durationFactor: 0)})
    }
    
}
