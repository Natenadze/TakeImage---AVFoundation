//
//  ViewController.swift
//  TakeImageAVFoundation
//
//  Created by Davit Natenadze on 31.03.23.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var capturedImageThumbnailButton: UIButton!
    
    
    // MARK: - Properties
    
    let captureSession = AVCaptureSession()  // coordinator of input/output flow
    var photoOutput = AVCapturePhotoOutput() // capture an image, capture Data (fileOutput for video)
    var activeInput: AVCaptureDeviceInput!   //
    var previewLayer: AVCaptureVideoPreviewLayer!  // video that we see before taking a photo
    
    var isSessionSetup = false
    var capturedImage: UIImage?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isSessionSetup {
            if setupSession() {
                setupPreview()
                startSession()
            }
        } else {
            if !captureSession.isRunning {
                startSession()
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            stopSession()
        }
        
    }
    
    // MARK: - Layout Subviews ( round the button )
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureButton.layer.cornerRadius = captureButton.frame.width / 2
    }
    
    
    // MARK: - Helpers
    
    func startSession() {
        DispatchQueue.global().async {
            self.captureSession.startRunning() // Open Camera
        }
    }
    
    func stopSession() {
        DispatchQueue.global().async {
            self.captureSession.stopRunning() // Open Camera
        }
    }
    
    
    // MARK: - Add Input & Output
    
    func setupSession() -> Bool {  // if setup is successful
        
        captureSession.beginConfiguration()  // START CONFIG
        captureSession.sessionPreset = .photo  // what quality we want
        
        let camera = AVCaptureDevice.default(for: AVMediaType.video)! // which camera we use
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(input) { // check if session can add input
                captureSession.addInput(input)   // add input
                activeInput = input
            } else {
                return endConfiguration()
            }
        } catch {
            return endConfiguration()
        }
        
        //
        if captureSession.canAddOutput(photoOutput) { // check if is possible to add output
            captureSession.addOutput(photoOutput)   // add output
            //            photoOutput.maxPhotoDimensions
        } else {
            return endConfiguration()
        }
        
        captureSession.commitConfiguration()  // FINISH CONFIG
        isSessionSetup = true
        
        return true
    }
    
    //
    func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill  // fill whole screen
        camPreview.layer.addSublayer(previewLayer)
    }
    
    func endConfiguration() -> Bool {
        print("failed to create photo output")
        captureSession.commitConfiguration()
        return false
    }
    
    
    // MARK: - IBActions
    
    @IBAction func capturedImageThumbnailButtonDidTouch(_ sender: Any) {
        
        guard let capturedImage = capturedImage else { return }
        performSegue(withIdentifier: "capturedImageSegue", sender: capturedImage)
    }
    
    @IBAction func takePhotoPressed(_ sender: Any) {
        
        let photoSettings = AVCapturePhotoSettings()
        //        photoSettings.flashMode = .on  // flashlight control
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    
    // MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "capturedImageSegue" {
            let destinationVC = segue.destination as! CapturedImageVC
            destinationVC.modalPresentationStyle = .fullScreen
            destinationVC.capturedImage = sender as? UIImage
        }
    }
    
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard error == nil else {
            print("Error in capture process: \(String(describing: error))")
            return
        }
        
        // Convert Data to UIImage
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Unable to create image from image data")
            return
        }
        
        capturedImage = image
        
        let thumbnailSize = capturedImageThumbnailButton.frame.size
        let scaledImage = image.scaleToFitSize(thumbnailSize)
        
        capturedImageThumbnailButton.setImage(scaledImage, for: .normal)
        
        
    }
}



