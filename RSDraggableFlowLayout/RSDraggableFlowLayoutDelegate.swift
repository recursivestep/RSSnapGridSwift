//
//  RSDraggableFlowLayoutDelegate.swift
//  RSSnapGrid
//
//  Created by Mark Williams on 31/07/2014.
//  Copyright (c) 2014 Mark Williams. All rights reserved.
//

import Foundation
import UIKit

public protocol RSDraggableFlowLayoutDelegate : UICollectionViewDelegateFlowLayout {
	func flowLayout(layout: RSDraggableFlowLayout, updatedCellSlotContents slotContents: [Int])
	func flowLayout(layout: RSDraggableFlowLayout, canMoveItemAtIndex index: Int) -> Bool
	func flowLayout(layout: RSDraggableFlowLayout, prepareItemForDrag indexPath: NSIndexPath)
}