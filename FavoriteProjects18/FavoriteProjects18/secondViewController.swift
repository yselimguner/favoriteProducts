//
//  secondViewController.swift
//  FavoriteProjects18
//
//  Created by Yavuz Güner on 21.02.2022.
//

import UIKit
import CoreData
//Data'yı eklmeme lazım

class secondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //Yukarıda tanımladığımız 2 delege ile kayıt işlemi tamamlandıktan sonra geri dönme gibi yapacağımız işleri

    
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    //Bu yaptığımız şey aslında update etme gibi birşey.
    var choosenProduct = ""
    var choosenProductId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if choosenProduct != "" {
            // Core Data
            
            //Bu tuşa tıklayamamk
            //saveButton.isEnabled = false
            
            //hiç gözkmemesi için
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
            
            let idString = choosenProductId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            //idString'i ona göre getirdik.
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0    {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let price = result.value(forKey: "price") as? Double{
                            priceText.text = String(price)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch {
                print("error")
            }
            
        }
        else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        
        
        
        //RECOGNIZERS
        //Klavyeyi kapatmak için
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true //Kullanıcı görsele tıklayabiliyor mu
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary //photoyu kütüphaneden seçme
        picker.allowsEditing = true //Fotoğrafları editlesin mi?
        present(picker, animated: true, completion: nil) //tıkladığımızda görseli kütüphaneye götürecek. İşi bittikten sonra ne olacak onu da aşağıya yazıyoruz. Delegateler yukarıda tanımladığımız şeyler.
    
    }
    
    //Medya ile işimiz bitince
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage //Ya foto görsele çevrilmeyebilir ya da resim seçmez o yüzden garanti yapmaya gerek yok.
        
        //Resim seçtikten sonra buton kullanılabilir olacak.
        saveButton.isEnabled = true
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true) //Editlemeyi kapat dedik burada
    }
    

    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newProduct = NSEntityDescription.insertNewObject(forEntityName: "Products", into: context)
        //Entity'de tanımladığımız olan dosyayı kaydetmek için aşağıya not yazarız.
        
        //Attributes
        newProduct.setValue(nameText.text!, forKey: "name")
        newProduct.setValue(artistText.text!, forKey: "artist")
        
        if let price = Double(priceText.text!) {
            newProduct.setValue(price, forKey: "price")
        }
        if let year = Int(yearText.text!){
            newProduct.setValue(year, forKey: "year")
        }
        
        
        newProduct.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newProduct.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("Success")
        }
        catch{
             print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
        
    }
    

}
