//
//  RSDraggableFlowLayout.swift
//  RSSnapGrid
//
//  Created by Mark Williams on 31/07/2014.
//  Copyright (c) 2014 Mark Williams. All rights reserved.
//

import Foundation
import UIKit

public class RSDraggableFlowLayout : UICollectionViewFlowLayout {
	public var dragGestureRecognizer: UIGestureRecognizer?
	public var delegate: RSDraggableFlowLayoutDelegate?

	public func gestureCallback(gestureRecognizer: UIGestureRecognizer) {
		// Get touch point
		let p = gestureRecognizer.locationInView(self.collectionView)

		// Start dragging cell on long touch
		if gestureRecognizer.state == .Began {
			self.startDraggingFromPoint(p)
		}

		// Move cell that is being dragged to latest touch position
		if gestureRecognizer.state == .Changed {
			self.updateDragLocation(p)
		}

		// Stop dragging
		if gestureRecognizer.state == .Ended {
			self.stopDragging(p)
		}
	}

	private lazy var originalCellLocations: [CGPoint] = [CGPoint]()
	private lazy var currentSlotContents: [Int] = [Int]()
	private var animator:UIDynamicAnimator?
	private var attachmentBehavior:UIAttachmentBehavior?
	private var selectedPath: Int?
	private var currentPath: Int?

	private func populateCellOrigins() {
		// Record origin of all the cells so we can snap them back as required.
		for i in 0..<self.collectionView.numberOfItemsInSection(0) {
			let path = NSIndexPath(forRow: i, inSection: 0)
			let cell = self.layoutAttributesForItemAtIndexPath(path)
			self.originalCellLocations.append(cell.center)
		}
		
		// Current slot contents starts off the same
		for i in 0..<self.collectionView.numberOfItemsInSection(0) {
			self.currentSlotContents.append(i)
		}
	}

	func distanceBetweenPoints(point1: CGPoint, point2: CGPoint) -> Double {
		let xDist = (point2.x - point1.x)
		let yDist = (point2.y - point1.y)
		return Double(sqrt((xDist * xDist) + (yDist * yDist)))
	}

	func selectedIndexPath() -> NSIndexPath {
		return NSIndexPath(forItem: self.selectedPath!, inSection: 0)
	}

	func pathForCellIn(slotIndex: Int) -> NSIndexPath {
		let index = self.currentSlotContents[slotIndex]
		let path = NSIndexPath(forItem: index, inSection: 0)
		return path
	}

	func closestSlotPathForPoint(p: CGPoint) -> Int? {
		for i in 0..<self.originalCellLocations.count {
			let point = self.originalCellLocations[i]
			if self.distanceBetweenPoints(p, point2: point) < 30 {
				return i
			}
		}
		return nil
	}

	func startDraggingFromPoint(p :CGPoint) {
		// Check with delegate that we're allowed to move the cell at this point
		let pathForObjectAtPoint = self.collectionView.indexPathForItemAtPoint(p)
		let canMoveCell = self.delegate?.flowLayout(self, canMoveItemAtIndex: pathForObjectAtPoint.row)
		if false == canMoveCell {
			return
		}

		// Need to know where everything starts off
		self.populateCellOrigins()

		// Need to know the path of the cell we're moving
		self.selectedPath = pathForObjectAtPoint.row
		// the path of the cell we're currently over
		self.currentPath = self.selectedPath
		
		// Get the cell we're going to drag
		let selectedCell = self.layoutAttributesForItemAtIndexPath(self.selectedIndexPath())

		// Animator for dynamics
		self.animator = UIDynamicAnimator(collectionViewLayout: self)

		// Attatch the cell we're dragging to the touch (drag) point
		self.attachmentBehavior = UIAttachmentBehavior(item: selectedCell, attachedToAnchor: p)
		self.animator?.addBehavior(self.attachmentBehavior)
		
		// Change appearance of drag cell so user can see it is selected
		self.prepareSelectedCellAppearanceForDrag(selectedCell, animated:true)

	}

	func updateDragLocation(p :CGPoint) {
		// Check drag is in progress
		if !self.selectedPath {
			return;
		}

		// Touch point has moved to move the item we're dragging to match it
		self.attachmentBehavior!.anchorPoint = p
		
		// We're dragging a cell around and we want to use the center of that as the location for testing
		// whether we should swap cells around (as opposed to raw touch point).
		let cell = self.collectionView.cellForItemAtIndexPath(self.selectedIndexPath())
		let testPoint = CGPointMake(CGRectGetMidX(cell.frame), CGRectGetMidY(cell.frame))
		
		// Which slot are we hovering over
		let toSlotIndex = self.closestSlotPathForPoint(testPoint)
		let fromSlotIndex = self.currentPath
		
		// Nothing to do if we're not over a slot
		if nil == toSlotIndex {
			return
		}

		// Nothing to do if we're over a cell that can't be moved
		let canMoveCell = self.delegate?.flowLayout(self, canMoveItemAtIndex: toSlotIndex!)
		if false == canMoveCell {
			return
		}

		// If we've moved to a new slot then snap cells to new positions as appropriate
		if toSlotIndex != fromSlotIndex {
			self.currentPath = toSlotIndex
			self.snapItemsToReorderPositions(fromSlotIndex!, toIndex:toSlotIndex!)
		}
	}

	func stopDragging(p :CGPoint) {
		// Check drag is in progress
		if !self.selectedPath {
			return;
		}

		// Stopped dragging so tell the owner so it can update it's model to match
		self.delegate?.flowLayout(self, updatedCellSlotContents: self.currentSlotContents)
		self.collectionView.reloadData()

		let selectedCell = self.layoutAttributesForItemAtIndexPath(self.selectedIndexPath())
		selectedCell.zIndex = 0

		// Clean up all the mechanisms we used to enable the drag / snapping
		self.animator!.removeAllBehaviors()
		self.animator = nil
		self.attachmentBehavior = nil
		self.selectedPath = nil
		self.currentPath = nil
		self.originalCellLocations.removeAll(keepCapacity: true)
		self.currentSlotContents.removeAll(keepCapacity: true)
	}
	
	func prepareSelectedCellAppearanceForDrag(selectedCell: UICollectionViewLayoutAttributes, animated: Bool) {
		// Make a few changes to the cell that is being dragged so that user can tell.

		// Make it top
		selectedCell.zIndex = 3

		self.delegate?.flowLayout(self, prepareItemForDrag: self.selectedIndexPath())
	}

	func snapItemsToReorderPositions(fromIndex: Int, toIndex: Int) {
		// Move  current position and all earlier ones to the position above
		if toIndex > fromIndex {
			for var pos = toIndex; pos > fromIndex; pos-- {
				if pos != fromIndex {
					self.doSnapFromPosition(pos, direction:-1)
				}
			}
		} else { // or current position and all subsequent ones to position below
			for var pos = toIndex; pos < fromIndex; pos++ {
				if pos != fromIndex {
					self.doSnapFromPosition(pos, direction:+1)
				}
			}
		}
		// Update current slot contents
		self.updateSlotContentsOfSlotsFromIndex(fromIndex, toIndex:toIndex)
	}

	func doSnapFromPosition(fromPosition: Int, direction: Int) {
		// Snap individual cell

		// Get cell
		let pathOfCellInSlot = self.pathForCellIn(fromPosition)
		let fromCell = self.layoutAttributesForItemAtIndexPath(pathOfCellInSlot)

		// Get points to snap from and to
		let snapPoint = self.originalCellLocations[fromPosition+direction]
		let fromPoint = self.originalCellLocations[fromPosition]
		
		// This clause is in case a cell was already being snapped and had it's position updated
		if CGPointEqualToPoint(snapPoint, fromCell.center) {
			fromCell.center = fromPoint
		}

		// Update the point to which it is snapping
		self.updateSnapPointForCell(fromCell, point: snapPoint)
	}

	func updateSnapPointForCell(cell: UICollectionViewLayoutAttributes, point: CGPoint) {
		// Get snap behavior - should only be one per snap animator
		for candidateBehavior in self.animator!.behaviors {
			if let customSnapBehavior = candidateBehavior as? RSSnapBehavior {
				if customSnapBehavior.indexPath.isEqual(cell.indexPath) {
					self.animator!.removeBehavior(customSnapBehavior)
				}
			}
		}

		// Create snap behavior to correct point (not possible to update snap point of existing behavior so always create a new one)
		let newSnapBehavior = RSSnapBehavior(item: cell, point: point, indexPath: cell.indexPath)
		self.animator!.addBehavior(newSnapBehavior)

		// Default snap behavior has rotation. Some people prefer that but it looks cleaner without
		// TODO: allow user to pass in dynamic behavior to customise animation effects.
		let dynamicItem = UIDynamicItemBehavior(items:[cell])
		dynamicItem.allowsRotation = false
		self.animator!.addBehavior(dynamicItem)
	}

	func updateSlotContentsOfSlotsFromIndex(fromIndex: Int, toIndex:Int) {
		// Update current slot contents
		if fromIndex < toIndex {
			let startValue = self.currentSlotContents[fromIndex]
			for var index = fromIndex; index < toIndex; index++ {
				self.currentSlotContents[index] = self.currentSlotContents[index+1]
			}
			self.currentSlotContents[toIndex] = startValue
		} else {
			let endValue = self.currentSlotContents[fromIndex]
			for var index = fromIndex; index > toIndex; index-- {
				self.currentSlotContents[index] = self.currentSlotContents[index-1]
			}
			self.currentSlotContents[toIndex] = endValue
		}
	}

	public override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]! {
		// Array of attributes to return
		var allAttributes = [AnyObject]()

		// Get the default layout attributes from super class
		var existingAttributes = super.layoutAttributesForElementsInRect(rect)

		// Add items from existing attributes that aren't duplicated by items owned by animators
		if let concreteAnimator = self.animator {
			let animatedItems: [AnyObject] = concreteAnimator.itemsInRect(rect)
			allAttributes += animatedItems

			// Get paths of animated attributes
			var existingPaths = [NSIndexPath]()
			for animatedAttribute in allAttributes {
				existingPaths.append(animatedAttribute.indexPath)
			}

			// then add from existing if they're not in animated
			for existingAttribute in existingAttributes {
				if !find(existingPaths,  existingAttribute.indexPath) {
					allAttributes.append(existingAttribute)
				}
			}
		} else {
			return existingAttributes
		}
		return allAttributes
	}

	public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath!) -> UICollectionViewLayoutAttributes! {
		let attributes = self.animator?.layoutAttributesForCellAtIndexPath(indexPath)
		if attributes {
			return attributes
		}
		return super.layoutAttributesForItemAtIndexPath(indexPath)
	}
}