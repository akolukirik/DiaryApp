//
//  ViewController.swift
//  DiaryApp
//
//  Created by ali on 19.05.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var idArray = [UUID]()
    var symbolArray = [String]()
    var titleArray = [String]()
    var noteArray = [String]()
    var dateArray = [Date]()
    var imageArray = [Data]()

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DairyTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "DairyTableViewCell")
        getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }

    @IBAction func addPaymentButtonClicked(_ sender: Any) {
        navigateToPaymentDetail()
    }

    func navigateToPaymentDetail(selectedTitle: String = "", selectedTitleID: UUID? = nil ) {
        let addPaymentVc = AddNewDayViewController.init(nibName: "AddNewDayViewController", bundle: nil)
        addPaymentVc.chosenTitle = selectedTitle
        addPaymentVc.chosenTitleID = selectedTitleID
        addPaymentVc.modalPresentationStyle = .fullScreen
        self.present(addPaymentVc, animated: true, completion: nil)
    }

    @objc func getData() {
        idArray.removeAll(keepingCapacity: false)
        symbolArray.removeAll(keepingCapacity: false)
        titleArray.removeAll(keepingCapacity: false)
        noteArray.removeAll(keepingCapacity: false)
        dateArray.removeAll(keepingCapacity: false)
        imageArray.removeAll(keepingCapacity: false)

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DiaryDB")
        fetchRequest.returnsObjectsAsFaults = false
        let sort = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sort]

        if let results = try? context?.fetch(fetchRequest) {
            if results.count > 0 {
                for result in results as! [NSManagedObject] {

                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    if let symbol = result.value(forKey: "symbol") as? String {
                        self.symbolArray.append(symbol)
                    }
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    if let note = result.value(forKey: "note") as? String {
                        self.noteArray.append(note)
                    }
                    if let date = result.value(forKey: "date") as? Date {
                        self.dateArray.append(date)
                    }
                    if let imageData = result.value(forKey: "image") as? Data {
                        self.imageArray.append(imageData)
                    }
                    tableView.reloadData()
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return idArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DairyTableViewCell", for: indexPath) as? DairyTableViewCell
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let images = imageArray[indexPath .section]
        cell?.titleLabel.text = titleArray[indexPath.section]
        cell?.sybolLabel.text = symbolArray[indexPath.section]
        cell?.dateLabel.text = formatter.string(from: dateArray[indexPath.section])
        cell?.diaryImageView.image = UIImage(data: images)
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTitle = titleArray[indexPath.section]
        let selectedTitleID = idArray[indexPath.section]
        navigateToPaymentDetail(selectedTitle: selectedTitle, selectedTitleID: selectedTitleID)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DiaryDB")
            let idString = idArray[indexPath.section].uuidString

            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false

            do {
                let results = try context?.fetch(fetchRequest)
                if results?.count ?? 0 > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.section] {
                                context?.delete(result)
                                titleArray.remove(at: indexPath.section)
                                idArray.remove(at: indexPath.section)
                                dateArray.remove(at: indexPath.section)
                                noteArray.remove(at: indexPath.section)
                                symbolArray.remove(at: indexPath.section)
                                imageArray.remove(at: indexPath.section)
                                self.tableView.reloadData()
                                do {
                                    try context?.save()
                                } catch {
                                    print("error")
                                }
                                break
                            }
                        }
                    }
                }
            } catch {
                print("error")
            }
        }
    }
}
