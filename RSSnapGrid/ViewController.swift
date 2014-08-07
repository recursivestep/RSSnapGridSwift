//
//  ViewController.swift
//  RSSnapGrid
//
//  Created by Mark Williams on 23/07/2014.
//  Copyright (c) 2014 Mark Williams. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
 
	@IBOutlet var numberOfCells:UISlider!
	@IBOutlet var widthOfCells:UISlider!
	@IBOutlet var heightOfCells:UISlider!
	@IBOutlet var spaceBetweenCells:UISlider!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
		if segue.identifier == "pushCollection" {
			let collectionViewController: RSTestCollectionViewController = segue.destinationViewController as RSTestCollectionViewController
			collectionViewController.numberOfCells = Int(self.numberOfCells.value)
			collectionViewController.widthOfCells = Double(self.widthOfCells.value)
			collectionViewController.heightOfCells = Double(self.heightOfCells.value)
			collectionViewController.spaceBetweenCells = Double(self.spaceBetweenCells.value)
			
			collectionViewController.model = RSCellModel(numberOfCells: Int(self.numberOfCells.value))
		}
	}
}
