//
//  SearchCollectionViewController.swift
//  one
//
//  Created by Kai Chen on 1/25/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SearchCollectionViewController: UICollectionViewController {

    var searchController: UISearchController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        let searchTableViewController = self.storyboard?.instantiateViewController(withIdentifier: Identifier.searchTableViewController.rawValue) as? SearchTableViewController
        searchController = UISearchController(searchResultsController: searchTableViewController)
        searchController?.searchResultsUpdater = searchTableViewController

        var frame = searchController?.searchBar.frame
        frame?.origin.y = (self.navigationController?.navigationBar.frame.height)! + 10
        searchController?.searchBar.frame = frame!

        self.view.addSubview((searchController?.searchBar)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
}
