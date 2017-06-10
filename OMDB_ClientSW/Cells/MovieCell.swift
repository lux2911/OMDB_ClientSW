//
//  MovieCell.swift
//  OMDB_ClientSW
//
//  Created by Tomislav Luketic on 10/28/16.
//  Copyright © 2016 Tomislav Luketic. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
	
	@IBOutlet weak var imgMovie : UIImageView!
	@IBOutlet weak var lblTitle : UILabel!
	@IBOutlet weak var lblYear : UILabel!
	
		
	var poster : String!
	
	private var _movieID : String!
	var movieID : String {
		set {
			
			_movieID = newValue
			
			
			
			if let poster = self.poster , poster != "N/A"
			{
				
										
					let request = URLRequest.init(url: URL.init(string: poster)! )
					
					let cachedResponse = URLCache.shared.cachedResponse(for: request)
					
					var aImage : UIImage? = nil
					
					if ((cachedResponse?.data) != nil)
					{
						aImage = UIImage.init(data: (cachedResponse?.data)!)
											
							
							if let aImage = aImage
                            {
								self.imgMovie.image = aImage
							}
												
						
					}
					else
					{
						do {
							try aImage =  UIImage.init(data: Data.init(contentsOf: URL.init(string: poster)!))
                            
                            
                                if let aImage = aImage
                                {
                                    self.imgMovie.image = aImage
                                }
                                
                           
                            }
									
							
						 catch  {
							
                                }
						
						
						
					}
						
				
			}
			
			
		}
		get {
			
			return  _movieID 
			
		}
	}
	
	
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		
		self.imgMovie.image=UIImage.init(named: "placeholder")
		
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		self.imgMovie.image=UIImage.init(named: "placeholder")
	}
	
	
}
