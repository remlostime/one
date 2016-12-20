//
//  ViewController.swift
//  one
//
//  Created by Kai Chen on 12/19/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var senderLabel: UILabel!
    @IBOutlet var receiverLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        /* Create tables and data in DB */

//        let data = UIImageJPEGRepresentation(imageView.image!, 0.5)
//
//        let file = PFFile(name: "picture.jpg", data: data!)
//
//        let object = PFObject(className: "messages")
//        object["sender"] = "Kai"
//        object["receiver"] = "Lifan"
//        object["picture"] = file
//        object.saveInBackground { (done: Bool, error: Error?) in
//            if done {
//                print("Saved in server")
//            } else {
//                print(error)
//            }
//        }

        // Retreive data from server
        let information = PFQuery(className: "messages")
        information.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                for object in objects! {
                    let sender = object["sender"] as? String
                    let receiver = object["receiver"] as? String

                    self.senderLabel.text = "Sender: \(sender)"
                    self.receiverLabel.text = "Receiver: \(receiver)"

                    (object["picture"] as AnyObject).getDataInBackground(block: { (data: Data?, error: Error?) in
                        if error == nil {
                            if data != nil {
                                self.imageView.image = UIImage(data: data!)
                            }
                        } else {
                            print(error)
                        }
                    })

                }
            } else {
                print(error)
            }
        }
    }
}

