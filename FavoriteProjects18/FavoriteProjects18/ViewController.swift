//
//  ViewController.swift
//  FavoriteProjects18
//
//  Created by Yavuz Güner on 21.02.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedProduct = ""
    var selectedProductID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        
        //Bir tane ekleme barı ekleyeceğiz. Bunun için alttaki kodu yazıyorz.
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        //Alttaki ile bu metin bir bütündür aslında. Selector'u oluşturmak için objc'den bir durum tanımlarız.
        
        getData()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    
    @objc func getData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context =  appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    self.tableView.reloadData()
                }
            }
            
            
            
        }
        catch {
            print("error")
        }
    }
    
    
    
    @objc func addButtonClicked(){
        //secondViewControllera gitmeden şunu dicez
        selectedProduct = ""
        
        performSegue(withIdentifier: "toSecondViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSecondViewController" {
            let destinationVC = segue.destination as! secondViewController
            destinationVC.choosenProduct = selectedProduct
            destinationVC.choosenProductId = selectedProductID
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProduct = nameArray[indexPath.row]
        selectedProductID = idArray[indexPath.row]
        performSegue(withIdentifier: "toSecondViewController", sender: nil)
    }
    
    //Silme işlemi için
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let appDelegate = UIApplication.shared.delegate as!  AppDelegate
            let context = appDelegate.persistentContainer.viewContext
                
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@" , idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                
            
            let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as!  [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                } catch{
                                    print("error")
                                }
                            }
                        }
                    }
                }
            } catch{
                print("error")
            }
            
        }
    }


}

