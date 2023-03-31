//
//  CapturedImageVC.swift
//  TakeImageAVFoundation
//
//  Created by Davit Natenadze on 31.03.23.
//

import UIKit

class CapturedImageVC: UIViewController {

    @IBOutlet weak var capturedImageView: UIImageView!
    
    var capturedImage: Data?

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = capturedImage {
            capturedImageView.image = UIImage(data: image)
        }
    }

    // MARK: - IBAction
    
    @IBAction func dismissButtonDidTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
