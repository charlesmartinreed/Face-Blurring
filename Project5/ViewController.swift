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
        
        //add the share button to our navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePhoto))
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
            
            //adding our tap recognizer
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(faceTapped(_:)))
            vw.addGestureRecognizer(recognizer)
            
        }
}
    
    override func viewDidLayoutSubviews() {
        //called when the orientation changes on the device
        
        addBlursRect()
    }
    
    func renderBlurredFaces() {
        
        //we need to prepare the image
        guard let currentUIImage = inputImage else { return }
        
        //requires a CGImage to use Core Image Filter, but we have to convert to a CGImage first for some reason
        guard let currentCGImage = currentUIImage.cgImage else { return }
        
        //finally... a CIImage!
        let currentCIImage = CIImage(cgImage: currentCGImage)
        
        //pixellate the image by first creating the filter
        let filter = CIFilter(name: "CIPixellate")
        
        //use the CIImage as the input image
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        
        //set the intensity of the filtering effect
        filter?.setValue(12, forKey: kCIInputScaleKey)
        
        //get the filtered image, in full. It might be nil, so we handle this with a guard statement
        guard let outputImage = filter?.outputImage else { return }
        
        //convert that filtered CIImage to a UIImage
        let blurredImage = UIImage(ciImage: outputImage)
        
        //we'll use a clipping path for faces that should be blurred, which will mask the drawing to the specified path. This will be or blur.
        
        // prepare to render a new image at the full size we need
        let render = UIGraphicsImageRenderer(size: currentUIImage.size)
        
        //commence rendering
        let result = render.image { (ctx) in
            
            //draw the original image first
            currentUIImage.draw(at: .zero)
            
            //create an empty clipping path that will hold our faces
            let path = UIBezierPath()
            
            for face in detectedFaces {
                if face.blur {
                    //calculate the position of this face in image coordinations
                    let boundingBox = face.observation.boundingBox
                    let size = CGSize(width: boundingBox.width, height: boundingBox.height)
                    let origin = CGPoint(x: boundingBox.minX * currentUIImage.size.width, y: 1 - (face.observation.boundingBox.minY) *
                        currentUIImage.size.height - size.height)
                    let rect = CGRect(origin: origin, size: size)
                    
                    //convert these coordinates into a path, and add it to the clipping path
                    let miniPath = UIBezierPath(rect: rect)
                    path.append(miniPath)
                }
            }
            
            if !path.isEmpty {
                path.addClip()
                blurredImage.draw(at: .zero)
            }
        }
        
        //show the blurred image
        imageView.image = result
        
        
    }
    
    //MARK:- Detect tapped faces
    @objc func faceTapped(_ sender: UITapGestureRecognizer) {
        
        //check the view for the tag
        guard let vw = sender.view else { return }
        
        //toggle the blurred state on and off, per tap
        detectedFaces[vw.tag].blur = !detectedFaces[vw.tag].blur
        renderBlurredFaces()
        
    }
    
    //MARK:- Media sharing function
    @objc func sharePhoto() {
        //if imageview has image, send to UIActivityViewController
        guard let img = imageView else { return }
        
        let ac = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        
        present(ac, animated: true, completion: nil)
    }

}

