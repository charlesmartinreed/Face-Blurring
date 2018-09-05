//
//  ViewController.swift
//  Project5
//
//  Created by Charles Martin Reed on 9/5/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK:- Properties
    @IBOutlet weak var imageView: UIImageView!
    var inputImage: UIImage?
    
    //using a tuple here, so we can get the observation and whether or not the face is chosen as blurred by the user
    var detectedFaces = [(observation: VNFaceObservation, blur: Bool)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add the button to our navigation bar to import photos from library
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(importPhoto))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Photo importing
    @objc func importPhoto() {
    
        //instantiate a new image picker
        let picker = UIImagePickerController()
        
        //allow editing because we're blurring the photos, of course
        picker.allowsEditing = true
        
        //delegate to self so that the view controller handles our work
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
    
    //MARK:- image picker delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //pull out the image that was selected
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        //save it to our image view and property
        imageView.image = image
        inputImage = image
        
        //hide the image picker
        dismiss(animated: true) {
            
            //face detection should occur here
            self.detectFaces()
        }
    }
    
    //MARK:- Function for detecting faces
    func detectFaces() {
        //vision needs CIImage, NOT UIImage
        //make sure we have something in the image property and, if so, convert to a CIImage
        guard let inputImage = inputImage else { return }
        guard let ciImage = CIImage(image: inputImage) else { return }
        
        //create an instance of VNDetectFacesRectanglesRequest, passing a request to the handler
        let request = VNDetectFaceRectanglesRequest { [unowned self] request, error in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let observations = request.results as? [VNFaceObservation] else { return }
                //the Array zip function is used to joining elements as a tuple
                //will create an observation and a default bool of false for each observation in the array
                self.detectedFaces = Array(zip(observations, [Bool] (repeating: false, count: observations.count)))
                
                //call the blur func
                self.addBlursRect()
                }
            }
        
        //vision request handler
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK:- Add blurs
    func addBlursRect() {
        //this functionality is granted by the extension to UIImageView accompanying this project
        
        //remove any existing face rectangles
        imageView.subviews.forEach { $0.removeFromSuperview() }
        
        //find the size of the image inside the imageView
        let imageRect = imageView.contentClippingRect
        
        //loop over all the faces that were detected
        for (index, face) in detectedFaces.enumerated() {
            
            //pull out the face position
            let boundingBox = face.observation.boundingBox
            
            //calculate its size
            let size = CGSize(width: boundingBox.width * imageRect.width, height: boundingBox.height * imageRect.height)
            
            //calcuate its position
            var origin = CGPoint(x: boundingBox.minX * imageRect.width, y: (1 - face.observation.boundingBox.minY) * imageRect.height - size.height)
            
            //offset the position based on the content clipping rect
            origin.y += imageRect.minY
            
            //place a UIView there
            let vw = UIView(frame: CGRect(origin: origin, size: size))
            
            //store its face number as its tag
            vw.tag = index
            
            //color its border read and add it
            vw.layer.borderColor = UIColor.red.cgColor
            vw.layer.borderWidth = 2
            imageView.addSubview(vw)
            
        }
}
    
    override func viewDidLayoutSubviews() {
        //called when the orientation changes on the device
        
        addBlursRect()
    }

}

