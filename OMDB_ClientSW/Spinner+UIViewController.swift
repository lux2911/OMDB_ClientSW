//
//  Spinner+UIViewController.swift
//  OMDB_ClientSW
//
//  Created by Tomislav Luketic on 10/28/16.
//  Copyright © 2016 Tomislav Luketic. All rights reserved.
//

import UIKit

extension UIViewController
{
	
	func showSpinnerInWindow()
	{
		let ai = UIActivityIndicatorView.init()
		ai.tag=888
		ai.activityIndicatorViewStyle = .whiteLarge
		
		let x = (self.view.frame.size.width - ai.frame.size.width) / 2
		let y = (self.view.frame.size.height - ai.frame.size.height) / 2
		
		var rect = ai.frame
		rect.origin.x = x;
		rect.origin.y = y
		
		ai.frame = rect;
		
		self.view.addSubview(ai)
		
		ai.startAnimating()
		
		
	}
	
	
	func dismissSpinner()
	{
		let ai = self.view.viewWithTag(888)
		
		ai?.removeFromSuperview()
		
	}
	
}
