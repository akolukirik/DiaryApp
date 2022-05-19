//
//  AddNewDayViewController.swift
//  DiaryApp
//
//  Created by ali on 19.05.2022.
//

import UIKit
import CoreData

class AddNewDayViewController: UIViewController {

    @IBOutlet var titleLabel: UITextField!
    @IBOutlet var symbolLabel: UITextField!
    @IBOutlet var noteLabel: UITextField!
    @IBOutlet var datePicker: UIDatePicker!

    var pickerView = UIPickerView()
    let data = ["💸","🧾","🎯"," 🍔","🏡","👾","👔","🚘"]

    var chosenTitle = ""
    var chosenTitleID: UUID?

    lazy var selectedObject: NSManagedObject? = {
        return prepareSelectedObject()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        symbolLabel.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        noteLabel.text = ""
        titleLabel.text = ""

        if let selectedObject = selectedObject {
            if let symbol = selectedObject.value(forKey: "symbol") as? String {
                symbolLabel.text = symbol
            }
            if let title = selectedObject.value(forKey: "title") as? String {
                titleLabel.text = title
            }
            if let note = selectedObject.value(forKey: "note") as? String {
                noteLabel.text = note
            }
            if let date = selectedObject.value(forKey: "date") as? Date {
                datePicker.date = date
            }
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @IBAction func cancelButtonclicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func prepareSelectedObject() -> NSManagedObject? {
        guard let chosenTitleID = chosenTitleID else {
            return nil
        }
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DiaryDB")
        let idString = chosenTitleID.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        fetchRequest.returnsObjectsAsFaults = false

        guard let results = try? context?.fetch(fetchRequest) else { return nil }

        return results.first as? NSManagedObject
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        if titleLabel.text != "" && symbolLabel.text != "" && noteLabel.text != "" {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            let paymentObject: NSManagedObject

            if let selectedObject = selectedObject {
                paymentObject = selectedObject
                paymentObject.setValue(chosenTitleID, forKey: "id")
            } else {
                paymentObject = NSEntityDescription.insertNewObject(forEntityName: "DiaryDB", into: context)
                paymentObject.setValue(UUID(), forKey: "id")
            }
            paymentObject.setValue(titleLabel.text, forKey: "title")
            paymentObject.setValue(symbolLabel.text, forKey: "symbol")
            paymentObject.setValue(datePicker.date, forKey: "date")
            paymentObject.setValue(noteLabel.text, forKey: "note")
            do {
                try context.save()
            } catch  {
                print("error")
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        else {
            makeAlert(title: "Boş Alan", message: "Lüfen bütün alanları doldurunuz.")
        }
    }

    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}

extension AddNewDayViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        symbolLabel.text = data[row]
        symbolLabel.resignFirstResponder()
    }
}
