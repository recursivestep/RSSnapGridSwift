//
//  RSTestCollectionViewController.swift
//  RSSnapGrid
//
//  Created by Mark Williams on 28/07/2014.
//  Copyright (c) 2014 Mark Williams. All rights reserved.
//

import UIKit
import RSDraggableFlowLayout

let reuseIdentifier = "ExampleCell"

class RSTestCollectionViewController: UICollectionViewController, RSDraggableFlowLayoutDelegate {

	var numberOfCells = 0
	var widthOfCells = 0.0
	var heightOfCells = 0.0
	var spaceBetweenCells = 0.0
	var model: RSCellModel? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

		// Set up collection view
		self.collectionView.backgroundColor = UIColor.whiteColor()
		self.edgesForExtendedLayout = UIRectEdge.All
		self.automaticallyAdjustsScrollViewInsets = true
		
		
		// Set layout delegate
		// TODO:
		if let layout = self.collectionViewLayout as? RSDraggableFlowLayout {
			layout.dragGestureRecognizer = UILongPressGestureRecognizer(target: layout, action: "gestureCallback:")
			self.collectionView.addGestureRecognizer(layout.dragGestureRecognizer)
			layout.delegate = self
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
		// Currently only supports a single section
        return 1
    }

    override func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        // Currently only supports a single section
		return self.numberOfCells
    }

    override func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as RSExampleCollectionViewCell

        // Configure the cell

		let cellIndex = self.model?.cellForSlot(indexPath.row)
		cell.text = self.model!.textForCell(cellIndex!)
		cell.backgroundColor = self.model!.colorForCell(cellIndex!)
		return cell
    }

	// MARK: UICollectionViewDelegateFlowLayout

	func collectionView(collectionView: UICollectionView!, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
		return CGSizeMake(CGFloat(self.widthOfCells), CGFloat(self.heightOfCells))
	}

	func collectionView(collectionView: UICollectionView!, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: NSInteger) -> CGFloat {
		return CGFloat(self.spaceBetweenCells)
	}

	func collectionView(collectionView: UICollectionView!, layout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: NSInteger) -> CGFloat {
		return CGFloat(self.spaceBetweenCells)
	}
	
	// MARK: RSDraggableFlowLayoutDelegate

	func flowLayout(layout: RSDraggableFlowLayout, updatedCellSlotContents slotContents: [Int]) {
		self.model?.updateCellsWithSlotPositions(slotContents)
	}

	func flowLayout(layout: RSDraggableFlowLayout, canMoveItemAtIndex index: Int) -> Bool {
		if index == (self.numberOfCells - 1) {
			return false
		}
		return true
	}

	func flowLayout(layout: RSDraggableFlowLayout, prepareItemForDrag indexPath: NSIndexPath) {
		let dragCellAttributes: UICollectionViewLayoutAttributes = self.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath)
		var bounds: CGRect = dragCellAttributes.bounds
		bounds.size.width *= 1.2
		bounds.size.height *= 1.2
		dragCellAttributes.bounds = bounds
	}

	// MARK: UICollectionViewDelegate

	override func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
		let vc = UIViewController()
		let cell = self.collectionView.cellForItemAtIndexPath(indexPath)
		vc.view.backgroundColor = cell.backgroundColor
		self.view.addSubview(vc.view)
		
		let rect = CGRectMake(CGRectGetMidX(cell.frame), CGRectGetMidY(cell.frame), 0, 0)
		vc.view.frame = rect
		
		UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
				vc.view.frame = self.view.frame
			}, completion: { _ in
				vc.view.removeFromSuperview()
				self.navigationController.pushViewController(vc, animated: false)
			})
	}
}
