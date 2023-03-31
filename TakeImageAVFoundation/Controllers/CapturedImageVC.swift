//
//  CapturedImageVC.swift
//  TakeImageAVFoundation
//
//  Created by Davit Natenadze on 31.03.23.
//

import UIKit

class CapturedImageVC: UIViewController {

    @IBOutlet weak var capturedImageView: UIImageView!
    
    var capturedImage: UIImage?

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            capturedImageView.image = capturedImage
    }

    // MARK: - IBAction
    
    @IBAction func dismissButtonDidTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
