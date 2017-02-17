//
//  HashtagCollectionViewController.swift
//  one
//
//  Created by Kai Chen on 1/18/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse

private let reuseIdentifier = "Cell"

class HashtagCollectionViewController: UICollectionViewController {

    var hashtag: String?

    var pictures = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = hashtag

        let length = min((self.view.frame.size.width - 3) / 3, (self.view.frame.size.height - 3) / 3)
        let size = CGSize(width: length, height: length)

        let layout = self.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = size

        let query = PFQuery(className: Hashtag.modelName.rawValue)
        query.whereKey(Hashtag.hashtag.rawValue, equalTo: hashtag!)

        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            for object in objects! {
                self.pictures.append(object[Hashtag.postid.rawValue] as! String)
            }

            self.collectionView?.reloadData()
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.pictureCell.rawValue, for: indexPath) as? PictureCollectionViewCell

        let pictureid = pictures[indexPath.row]
        let query = PFQuery(className: Post.modelName.rawValue)
        query.whereKey(Post.uuid.rawValue, equalTo: pictureid)

        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            for object in objects! {
                let pictureFile = object[Post.picture.rawValue] as? PFFile
                pictureFile?.getDataInBackground { [weak cell](data: Data?, error: Error?) in
                    guard let strongCell = cell else {
                        return
                    }

                    let image = UIImage(data: data!)
                    DispatchQueue.main.async {
                        strongCell.imageView.image = image
                    }
                }

            }
        }

        return cell!
    }
}
