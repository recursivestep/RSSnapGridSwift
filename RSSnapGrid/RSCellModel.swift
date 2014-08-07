//
//  RSCellModel.swift
//  RSSnapGrid
//
//  Created by Mark Williams on 23/07/2014.
//  Copyright (c) 2014 Mark Williams. All rights reserved.
//

import Foundation
import UIKit

class RSCellModel {
	
	func cellForSlot(slotIndex: Int) -> Int {
		return self.cellOrder[slotIndex]
	}

	func colorForCell(cellIndex: Int) -> UIColor {
		return self.cellColors[cellIndex]
	}

	func textForCell(cellIndex: Int) -> String {
		return self.cellText[cellIndex]
	}

	func updateCellsWithSlotPositions(slotPositions: [Int]) {
		var newOrder: [Int] = [Int]()
		for i in 0..<slotPositions.count {
			let indexOfOldSlot = slotPositions[i]
			let newSlotIndex: Int = self.cellOrder[indexOfOldSlot]
			newOrder.append(newSlotIndex)
		}
		self.cellOrder = newOrder;
	}

	init(numberOfCells: Int) {
		for cellCount in 0...numberOfCells-1 {
			cellOrder.append(cellCount)
			cellColors.append(randomColor())
			cellText.append(String(cellCount))
		}
	}

	private var cellOrder:[Int] = []
	private var cellColors:[UIColor] = []
	private var cellText:[String] = []

	private func randomColor() -> UIColor {
		let r = Double(arc4random() % 255)
		let g = Double(arc4random() % 255)
		let b = Double(arc4random() % 255)
		return UIColor(red:CGFloat(r/255), green:CGFloat(g/255), blue:CGFloat(b/255), alpha:1)
	}
}