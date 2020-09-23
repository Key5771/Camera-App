//
//  ViewController.swift
//  FullScreenCamera
//
//  Created by 김기현 on 2020/09/23.
//

import UIKit
import AVFoundation

class CameraController: UIViewController {
    var captureSession: AVCaptureSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        // Creating a capture session
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        
        // Obtaining and configuring the necessary capture devices
        func configureCaptureDevices() throws { }
        
        // Creating inputs using the capture devices
        func configureDeviceInputs() throws { }
        
        // Configuring a photo output object to process captured images
        func configurePhotoOutput() throws { }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }


}

