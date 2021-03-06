//
//  ViewController.swift
//  Example
//
//  Created by Andrei Hogea on 27/02/2019.
//  Copyright © 2019 Andrei Hogea. All rights reserved.
//

import UIKit
import Drawer

class ViewController: UIViewController {

    private let contentVC = ContentViewController.instantiate()
    var drawer: DrawerCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawer = DrawerCoordinator(contentViewController: contentVC,
                                   backgroundViewController: self.tabBarController!,
                                   drawerBackgroundType: .withColor(UIColor.black.withAlphaComponent(0.5)))
    }
    
}

