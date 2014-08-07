//
//  RSExampleCollectionViewCell.swift
//  RSSnapGrid
//
//  Created by Mark Williams on 27/07/2014.
//  Copyright (c) 2014 Mark Williams. All rights reserved.
//

import UIKit

class RSExampleCollectionViewCell: UICollectionViewCell {

	var text: String {
		get {
			return self.label!.text
		}
		set {
			self.label!.text = newValue
		}
	}

	override var backgroundColor: UIColor? {
		get {
			return super.backgroundColor
		}
		set {
			super.backgroundColor = newValue
			self.label!.backgroundColor = newValue
			self.contentView.backgroundColor = newValue
		}
	}

	@IBOutlet var label:UILabel?

//	init(frame: CGRect) {
//		super.init(frame: frame)
//		// Initialization code
//	}
}
