//
//  ViewController.swift
//  Project5
//
//  Created by Charles Martin Reed on 9/5/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK:- Properties
    @IBOutlet weak var imageView: UIImageView!
    var inputImage: UIImage?
    
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
    
    //MARK: - image picker delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //pull out the image that was selected
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        //save it to our image view and property
        imageView.image = image
        inputImage = image
        
        //hide the image picker
        dismiss(animated: true) {
            
            //face detection should occur here
        }
    }


}

