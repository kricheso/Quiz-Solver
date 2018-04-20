//
//  ViewController.swift
//  OCR Test
//
//  Created by Kousei Richeson on 3/27/18.
//  Copyright © 2018 Kousei Richeson. All rights reserved.
//


import CoreImage
import CropViewController
import Kanna
import MobileCoreServices
import TesseractOCR
import UIKit


class ViewController: UIViewController {
    

    // --------------------------------------------------------------
    // MARK:- Outlets
    // --------------------------------------------------------------
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!

    
    
    // --------------------------------------------------------------
    // MARK:- Variables
    // --------------------------------------------------------------
    var context: CIContext!
    var currentFilter: CIFilter!
    var imagePicker: UIImagePickerController!
    var recText = "Error"
    
    
    
    // --------------------------------------------------------------
    // MARK:- Override Functions
    // --------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imageView.image = imageView.image?.fixOrientation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Recieved a memory warning")
    }
    
    
    
    // --------------------------------------------------------------
    // MARK:- Actions
    // --------------------------------------------------------------
    @IBAction func addFilter(_ sender: Any) {
        imageView.image = applyCINoiseReduction(image: imageView.image!)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        showCamera()
    }
    
    @IBAction func readButtonPressed(_ sender: Any) {
        recText = extractText()
        textView.text = recText
    }
    
    @IBAction func cropButtonPressed(_ sender: Any) {
        presentCropViewController()
    }
    
    
    
    // --------------------------------------------------------------
    // MARK:- Functions
    // --------------------------------------------------------------
    
    func destroyWeirdLetters(text: String) -> String {
        // Change weird space characters normal space character
        var result = text.replacingOccurrences(of: " ", with: " ")
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890–+-=().,!_")
        result = result.filter { okayChars.contains($0) }
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        return result
    }
    
    func answerFormatter(text: String) -> String {
        var result = text
        // result = result.lowercased()
        result = result.replacingOccurrences(of: " the ", with: " ")
        result = result.replacingOccurrences(of: " of ", with: " ")
        result = result.replacingOccurrences(of: " a ", with: " ")
        result = result.replacingOccurrences(of: " an ", with: " ")
        result = result.replacingOccurrences(of: " and ", with: " ")
        result = result.replacingOccurrences(of: " in ", with: " ")
        result = result.replacingOccurrences(of: "'s", with: "s")
        return result
    }

}






// --------------------------------------------------------------
// MARK:- Camera Extension
// --------------------------------------------------------------
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // let fixedImage = img.fixedOrientation
            imageView.image = img //fixedImage()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Camera Error", message: "No Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
}



// --------------------------------------------------------------
// MARK:- Crop VC Extension
// --------------------------------------------------------------
extension ViewController: CropViewControllerDelegate {

    func presentCropViewController() {
        let image: UIImage = imageView.image!
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        imageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
}


// --------------------------------------------------------------
// MARK:- Image Editing Extension
// --------------------------------------------------------------
extension ViewController {
    
    func applyCINoiseReduction(image: UIImage) -> UIImage {
        var img1: CIImage = CIImage(image: image)!
        img1 = img1.applyingFilter("CINoiseReduction", parameters:["inputImage" : img1, "inputNoiseLevel" : 1.80, "inputSharpness" : 1.20])
        let uiImg = convert(cmage: img1)
        return uiImg
    }
    
    func applyCIUnsharpMask(image: UIImage) -> UIImage {
        var img1: CIImage = CIImage(image: image)!
        img1 = img1.applyingFilter("CIUnsharpMask", parameters:["inputImage" : img1, "inputIntensity" : 1.00])
        let uiImg = convert(cmage: img1)
        return uiImg
    }
    
    func convert(cmage: CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage, scale: 1.0, orientation: UIImageOrientation.up)
        return image
    }
    
}
    


// --------------------------------------------------------------
// MARK:- Tesseract Extension
// --------------------------------------------------------------
extension ViewController: G8TesseractDelegate {

    func extractText() -> String {
        var picture = imageView.image
        picture = picture?.g8_blackAndWhite()
        imageView.image = picture
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.delegate = self
            tesseract.image = imageView.image
            tesseract.recognize()
            print(tesseract.recognizedText)
            return tesseract.recognizedText
        }
        return "error"
    }
    
}




