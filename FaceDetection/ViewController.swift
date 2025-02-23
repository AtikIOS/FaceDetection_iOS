//
//  ViewController.swift
//  FaceDetection
//
//  Created by Atik Hasan on 2/23/25.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    let image = UIImage(named: "Group_Photo")
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = image
    }
    
    // MARK: - IBAction
    @IBAction func pickImage(_ sender: UIButton) {
        detect()
    }
    
    // MARK: - Detect Face and add Bounding Box's
    func detect() {
        guard let image = image, let personciImage = CIImage(image: image) else {
            return
        }
        
        /// Set up the face detector with high accuracy
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        guard let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy) else {
            return
        }
        
        /// Detect faces in the image
        let faces = faceDetector.features(in: personciImage)
        print("faces detected: ", faces.count)
        
        ///  store the all bounding boxes of detected faces
        var faceBoundsArray: [CGRect] = []
        
        /// For converting Core Image coordinates to UIView coordinates
        let ciImageSize = personciImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        
        // Adjust bounding box size (increase width and height)
        let boxExpansion: CGFloat = 8  // As u wish (Optional)
        
        for face in faces as! [CIFaceFeature] {
            print("Original Face Bounds: \(face.bounds)")
            
            /// Apply the transform to convert the coordinates
            var faceViewBounds = face.bounds.applying(transform)
            
            /// Expand the bounding box
            faceViewBounds = faceViewBounds.insetBy(dx: -boxExpansion, dy: -boxExpansion)
            
            /// Calculate the actual position and size of the rectangle in the image view
            let viewSize = imageView.bounds.size
            let scale = min(viewSize.width / ciImageSize.width, viewSize.height / ciImageSize.height)
            let offsetX = ((viewSize.width - ciImageSize.width * scale) / 2)
            let offsetY = ((viewSize.height - ciImageSize.height * scale) / 2)
            
            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            faceViewBounds.origin.x += offsetX
            faceViewBounds.origin.y += offsetY
            
            faceBoundsArray.append(faceViewBounds)
            
            /// Create a UIView to show the face bounding box
            let faceBox = UIView(frame: faceViewBounds)
            faceBox.layer.borderWidth = 3
            faceBox.layer.borderColor = UIColor.red.cgColor
            faceBox.backgroundColor = UIColor.clear
            imageView.addSubview(faceBox)
            print("Expanded Bounding Box: \(faceViewBounds)")
            
            if face.hasLeftEyePosition {
                print("Left eye position: \(face.leftEyePosition)")
            }
            
            if face.hasRightEyePosition {
                print("Right eye position: \(face.rightEyePosition)")
            }
        }
        
        /// Print all bounding box CGRect
        print("All bounding boxes: ", faceBoundsArray)
    }
    
}
