//
//  RSSnapBehavior.swift
//  RSSnapGrid
//
//  Created by Mark Williams on 31/07/2014.
//  Copyright (c) 2014 Mark Williams. All rights reserved.
//

import Foundation
import UIKit

class RSSnapBehavior : UISnapBehavior {
	let snapPoint: CGPoint
	let indexPath: NSIndexPath
	init(item: UIDynamicItem, point: CGPoint, indexPath: NSIndexPath) {
		self.snapPoint = point
		self.indexPath = indexPath
		super.init(item: item, snapToPoint: point)
	}
}
