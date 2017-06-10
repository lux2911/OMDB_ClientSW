//
//  ViewController.swift
//  OMDB_ClientSW
//
//  Created by Tomislav Luketic on 10/28/16.
//  Copyright © 2016 Tomislav Luketic. All rights reserved.
//

import UIKit

enum LuxError: Error {
	
	case Movie(String)
	
}

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate {
	
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	@IBOutlet weak var tableView: UITableView!
	
	var movies : [Movie]!
	var urlSession : URLSession!
	var dataTask : URLSessionDataTask!
	var totalResults : Int = 0
	var searchText : String!
	
	let baseURL = "http://www.omdbapi.com/?s=%@&type=movie&page=%d&apikey=ff5020a6"
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.searchBar.delegate=self
		self.navigationItem.titleView = self.searchBar
		self.urlSession = URLSession.init(configuration: URLSessionConfiguration.default)
		self.movies = []
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		self.tableView.rowHeight=70;
		
		self.tableView.tableFooterView=self.tableFooter()
		
		
		
		
	}
	
	func tableFooter()-> UIView
	{
		if (self.movies.count > 0)
		{ return UIView.init() }
		
		
		let aView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 286))
		aView.backgroundColor = UIColor.darkText
		
		let iv = UIImageView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 286))
		iv.autoresizingMask = [.flexibleHeight , .flexibleWidth]
		iv.contentMode = UIViewContentMode.scaleAspectFit
		iv.image = UIImage.init(named: "tour_search")
		
		aView.addSubview(iv)
		
		return aView
		
	}
	
	//#pragma mark - UITableViewDataSource
	
	func numberOfSections(in tableView: UITableView) -> Int {
		
		return 1
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.movies.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cellName = "MovieCell"
		
		var aCell = self.tableView.dequeueReusableCell(withIdentifier: cellName) as! MovieCell?
		
		if (aCell == nil)
		{
			aCell = MovieCell.init(style: .subtitle, reuseIdentifier: cellName)
		}
		
				
		return aCell!
	}
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
     
        let aCell = cell as! MovieCell
        
        let aMovie = self.movies[indexPath.row]
        aCell.lblTitle.text = aMovie.Title
        aCell.lblYear.text = aMovie.Year
        aCell.poster = aMovie.Poster
        
        aCell.movieID = aMovie.imdbID
        
        let cnt = self.tableView .numberOfRows(inSection: 0)
        
        if (indexPath.row == self.movies.count-1 && cnt < self.totalResults && self.dataTask == nil)
        {
            let page = (cnt/10) + 1
            self.loadDataForTextAndPage(text: self.searchText, page: UInt(page))
        }

        
    }
	
	func loadDataForTextAndPage(text: String, page: UInt)
	{
		
		if (self.dataTask != nil)
		{
			self.dataTask.cancel()
		}
		
		self.showSpinnerInWindow()
		
		
		let aURL = URL.init(string: String.init(format: self.baseURL, arguments: [text,page]))
		
		self.dataTask = self.urlSession.dataTask(with: aURL!, completionHandler: { (data, urlResponse, error) in
			
			
          do
          {
            
            self.dataTask = nil
			
			if (error == nil)
			{
                do
                {
                    let dict : Dictionary =  try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String,AnyObject>
				
				
                    if (dict["Error"] != nil)
                    {
                        throw LuxError.Movie(dict["Error"] as! String)
                    }
				
                    self.totalResults = Int.init(dict["totalResults"] as! String)!
				
                    let arr = dict["Search"]
				
				
				
                    for aMovie in arr as! [AnyObject] {
					
                        let newMovie = Movie.init()
					
                        let dMovie = aMovie as! Dictionary<String,AnyObject>
					
                        for (key,value) in dMovie
                        {
						
                            if (newMovie.responds(to: Selector(key)))
                            {
                                newMovie.setValue(value, forKey: key)
                            }
						
						
                        }
					
                        self.movies.append(newMovie)
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.dismissSpinner()
                        
                        self.tableView.tableFooterView=self.tableFooter()
                        self.tableView.reloadData()
                        
                        
                    }

				
                }
				
                catch LuxError.Movie(let msg)
                {
                    DispatchQueue.main.async {
                        self.dismissSpinner()
                        self.showError(msg: msg)
                        self.tableView.tableFooterView=self.tableFooter()
                    }
				
                }
				
								
			}
			else
			{
			  
                DispatchQueue.main.async {
					self.dismissSpinner()
                    self.showError(msg: (error?.localizedDescription)!)
					self.tableView.tableFooterView=self.tableFooter()
				}
              
                
			}
            
            }
            catch
            {
                self.showError(msg: error.localizedDescription)
            }
        
		})
		
		self.dataTask.resume()
		
	}
	
	
	func showError(msg : String)
	{
		let ac = UIAlertController.init(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.alert)
		
        
        let alert = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
		
		ac.addAction(alert)
		
		self.present(ac, animated: true, completion: nil)
		
		
	}
	
	//	#pragma mark - UISearchBarDelegate
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		
		searchBar.resignFirstResponder()
		
		if ((searchBar.text?.characters.count)! > 0)
		{
			self.movies.removeAll()
			self.totalResults = 0
			self.tableView.tableFooterView=self.tableFooter()
			
			self.tableView.reloadData()
			
			self.searchText = searchBar.text
			
			self.loadDataForTextAndPage(text: searchBar.text!, page: 1)
			
		}
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if (segue.identifier == "MovieDetails")
		{
			let md = segue.destination as! MovieDetailsViewControllerSW
			let idx = self.tableView.indexPathForSelectedRow
			
			let aMovie = self.movies[(idx?.row)!]
			md.movie = aMovie
			
			let aCell = self.tableView.cellForRow(at: idx!) as! MovieCell
			
			md.movieImg = aCell.imgMovie.image
			
		}
	}
	
	
	
	
	
	
}

