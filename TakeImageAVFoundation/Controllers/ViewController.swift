//
//  ViewController.swift
//  TakeImageAVFoundation
//
//  Created by Davit Natenadze on 31.03.23.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var capturedImageThumbnailButton: UIButton!
    
    let captureSession = AVCaptureSession()
    var photoOutput = AVCapturePhotoOutput()
    var activeInput: AVCaptureDeviceInput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var isSessionSetup = false
    var capturedImage: Data?

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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureButton.layer.cornerRadius = captureButton.frame.width / 2
    }
    
    func startSession() {
        DispatchQueue.main.async {
            self.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        
        DispatchQueue.main.async {
            self.captureSession.stopRunning()
        }
        
    }
    
    func setupSession() -> Bool {
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let camera = AVCaptureDevice.default(for: AVMediaType.video)!
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            } else {
                print("was not able to add input device")
                captureSession.commitConfiguration()
                return false
            }
        } catch {
            print("was not able to add input device")
            captureSession.commitConfiguration()
            return false
        }
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
//            let maxDimensions = CGSize(width: 3000, height: 3000)
//            let videoDimensions = CMVideoDimensions(width: Int32(maxDimensions.width), height: Int32(maxDimensions.height))
//            photoOutput.maxPhotoDimensions = videoDimensions

        } else {
            print("failed to create photo output")
            captureSession.commitConfiguration()
            return false
        }
        
        captureSession.commitConfiguration()
        isSessionSetup = true
        return true
        
    }
    
    func setupPreview() {
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
    }
    
    @IBAction func capturedImageThumbnailButtonDidTouch(_ sender: Any) {
        
        guard let capturedImage = capturedImage else { return }
        performSegue(withIdentifier: "capturedImageSegue", sender: capturedImage)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "CapturedImageSegue" {
            let destinationVC = segue.destination as! CapturedImageVC
            destinationVC.capturedImage = sender as? Data
        }
    }
    
    @IBAction func captureButtonDidTouch(_ sender: Any) {
        
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

}

extension ViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard error == nil else {
            print("Error in capture process: \(String(describing: error))")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Unable tp create image data")
            return
        }
        
        capturedImage = imageData
        capturedImageThumbnailButton.setBackgroundImage(UIImage(data: imageData), for: .normal)
        
    }
}

