//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by Sümeyra Demirtaş on 11/11/24.
//

import UIKit
import CoreML
import Vision // CoreML ile Image Recognition icin kullandigimiz yardimci kutuphane


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var chosenImage = CIImage()

    @IBOutlet weak var resultLabel: UILabel!
   
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func changeClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!) {
            chosenImage = ciImage
        }
        
        recognizeImage(image: chosenImage)
    }
    
    func recognizeImage(image: CIImage) {
        
        // 1) Request
        // 2) Handler
        let MobileNetConfig = MLModelConfiguration()
        if let model = try? VNCoreMLModel(for: MobileNetV2(configuration: MobileNetConfig).model) {
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                
                if let results = vnrequest.results as? [VNClassificationObservation] { //gorsel analizinin sonucunda uretilen bir siniflandirma
                    if results.count > 0 {
                        
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            self.resultLabel.text = "\(confidenceLevel)% it's \(topResult?.identifier)"
                            
                            
                            
//                            self.resultLabel.text = "\(topResult!.identifier) (\(topResult!.confidence * 100)%)"
                        }
                    }
                }
                    
            }
        }
    }
    
}

