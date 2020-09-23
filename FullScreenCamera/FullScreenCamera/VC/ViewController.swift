//
//  ViewController.swift
//  FullScreenCamera
//
//  Created by 김기현 on 2020/09/23.
//

import UIKit
import Photos

class ViewController: UIViewController {
    let cameraController = CameraController()
    
    @IBOutlet fileprivate var captureButton: UIButton!
    
    @IBOutlet fileprivate var capturePreviewView: UIView!
    
    @IBOutlet fileprivate var photoModeButton: UIButton!
//    @IBOutlet fileprivate var toggleCameraButton: UIButton!
//    @IBOutlet fileprivate var tollgeFlashButton: UIButton!
    
    @IBOutlet fileprivate var videoModeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        func configureCameraController() {
            cameraController.prepare { (error) in
                if let error = error {
                    print(error)
                }

                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }

        func styleCaptureButton() {
            captureButton.layer.borderWidth = 2
            captureButton.layer.borderColor = UIColor.black.cgColor

            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2

            photoModeButton.layer.borderWidth = 0
            photoModeButton.layer.borderColor = UIColor.black.cgColor

            videoModeButton.layer.borderWidth = 0
            videoModeButton.layer.borderColor = UIColor.black.cgColor
        }

        styleCaptureButton()
        configureCameraController()
    }
    
    @IBAction func captureImage(_ sender: Any) {
        cameraController.captureImage { (image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
