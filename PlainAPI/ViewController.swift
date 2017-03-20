//
//  ViewController.swift
//  PlainAPI
//
//  Created by anton Shepetuha on 13.03.17.
//  Copyright © 2017 anton Shepetuha. All rights reserved.
//

import UIKit
import DropDown


class ViewController: UIViewController {
    

    @IBOutlet weak var sendRequestButton: UIButton!

    @IBOutlet weak var buttonFrom       : UIButton!
    @IBOutlet weak var buttonTo         : UIButton!
    @IBOutlet weak var tableView        : UITableView!
    
    var dropDownFrom          : DropDown!
    var dropDownTo            : DropDown!
    var airportsName          = [String]()
    var shortTitle            = [String]()
    var trips                 = [APIData]()
    var constants             = Constants()
    var from                  : String?
    var to                    : String?
    var startButtonPosition   : CGPoint?
    var startTableViewPostion :CGPoint?
    var plainAway             = [UIImage]()
    var plainReturn           = [UIImage]()
    var plainInProgress       = [UIImage]()
    var pleaseChooseLabel     : UILabel!
    var counter               : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.controllerSettings()
        self.imagesToArrays()
        self.counter = 0
        self.startButtonPosition = self.sendRequestButton.frame.origin
        self.startTableViewPostion = self.tableView.frame.origin
    }
    //MARK: Actions
    @IBAction func buttonFrom(_ sender: UIButton) {
        dropDownFrom.show()
    }
    @IBAction func buttonTo(_ sender: UIButton) {
        dropDownTo.show()
    }
    override func viewDidLayoutSubviews() {
        
        self.pleaseChooseLabel.frame = CGRect.init(origin: CGPoint.init(x:  self.pleaseChooseLabel.frame.origin.x, y:  self.pleaseChooseLabel.frame.origin.y), size: CGSize.init(width: self.tableView.bounds.width, height: self.tableView.bounds.height * 0.5))
    }
    @IBAction func sendRequest(_ sender: UIButton) {
        guard let cityCodeFrom = self.from else { self.alertViewWith(message: self.constants.alertMessage, title: self.constants.alertTitle);self.defaultPsitions();  return }
        guard let cityCodeTo   = self.to   else { self.alertViewWith(message: self.constants.alertMessage, title: self.constants.alertTitle);self.defaultPsitions();
            return }
        if self.from == self.to {
            self.alertViewWith(message: self.constants.ifOriginAndDistinctisEqual, title:"");self.defaultPsitions(); return }
        self.goAway()
        DataManager.requestAPI(from: cityCodeFrom, to: cityCodeTo, responseData: { (response ) in
            guard response.count != 0 else {
                self.alertViewWith(message:self.constants.alertMessageError, title: self.constants.alertTitle);self.defaultPsitions(); return }
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.frame.origin = self.startTableViewPostion!
                self.pleaseChooseLabel.frame.origin.x = self.pleaseChooseLabel.frame.origin.x + self.view.frame.width
            })
            self.defaultPsitions()
            self.trips = response
            self.tableView.reloadData()
        })
    }
}
//MARK: UITableViewDelegate UITableViewDataSource
extension ViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trips.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CardTableViewCell
        let dataForCell     = self.trips[indexPath.row]
        cell.awayText.text  = self.constants.plainWillDeparture
        cell.arrivalText.text  = self.constants.plainWillArrive
        cell.slidesText.text   = self.constants.sliceCount
        cell.arrival.text   = dataForCell.arrival
        cell.departure.text = dataForCell.departure
        cell.price.text     = dataForCell.price
        cell.slice.text     = String(dataForCell.sliceCount)
        cell.mainView.layer.masksToBounds = false
        cell.mainView.layer.shadowColor = UIColor.black.cgColor
        cell.mainView.layer.shadowOpacity = 1
        cell.mainView.layer.shadowOffset = CGSize.zero
        cell.mainView.layer.shadowRadius = 3
        cell.mainView.layer.shadowPath = UIBezierPath.init(rect: cell.mainView.bounds).cgPath
        return cell
    }
}
// MARK: ViewController settings
extension ViewController {
    func controllerSettings(){
        self.airportsName           = self.constants.airportsName
        self.shortTitle             = self.constants.shortTitle
        dropDownFrom = DropDown()
        dropDownFrom.anchorView = buttonFrom
        dropDownFrom.dataSource = self.airportsName
        dropDownFrom.selectionAction = {(index: Int, item: String) in
            let airPortTitle = self.shortTitle[index]
            self.buttonFrom.titleLabel?.text = airPortTitle 
            self.from = airPortTitle
        }
        dropDownTo = DropDown()
        dropDownTo.anchorView = buttonTo
        dropDownTo.dataSource = self.airportsName
        dropDownTo.selectionAction = { (index: Int, item: String) in
             let airPortTitle = self.shortTitle[index]
            self.buttonTo.titleLabel?.text = airPortTitle
            self.to = airPortTitle
        }
        self.pleaseChooseLabel = UILabel.init(frame: CGRect.init(origin: CGPoint.init(x: 0, y: self.tableView.frame.origin.y), size: CGSize.init(width: self.tableView.bounds.width, height: self.tableView.bounds.height * 0.5)))
        self.pleaseChooseLabel.numberOfLines = 3
        self.pleaseChooseLabel.textAlignment = NSTextAlignment.center
        self.pleaseChooseLabel.text = self.constants.chooseCityes
        self.pleaseChooseLabel.font.withSize(25)
        self.view.addSubview(pleaseChooseLabel)
    }
}
//MARK: AlertView
extension ViewController {
    func alertViewWith(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [unowned self] (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        })
        self.present(alert, animated: true, completion: nil)
    }
}
extension ViewController {
    func goAway() {
        self.sendRequestButton.imageView?.animationImages = self.plainAway
        self.sendRequestButton.imageView?.animationRepeatCount = 1
        self.sendRequestButton.imageView?.animationDuration = 0.6
        self.sendRequestButton.setImage(#imageLiteral(resourceName: "21a"), for: .normal)
        self.sendRequestButton.imageView?.startAnimating()
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (tiemer) in
            self.sendRequestButton.imageView?.animationImages = self.plainInProgress
            self.sendRequestButton.imageView?.animationRepeatCount = 0
            self.sendRequestButton.imageView?.animationDuration = 1
            self.sendRequestButton.imageView?.startAnimating()
        }
    }
    func defaultPsitions(){
        
        if (self.sendRequestButton.imageView?.isAnimating)! {
            self.sendRequestButton.imageView?.stopAnimating()
        }
        self.sendRequestButton.imageView?.animationImages = self.plainReturn
        self.sendRequestButton.imageView?.animationRepeatCount = 1
        self.sendRequestButton.imageView?.animationDuration = 0.6
        self.sendRequestButton.setImage(#imageLiteral(resourceName: "1a"), for: .normal)
        self.sendRequestButton.imageView?.startAnimating()
    }
}
extension ViewController {
    func imagesToArrays(){
        for i in 1..<22 {
            let nameAway   = String(i) + "a"
            let nameReturn = String(i) + "r"
            if let imageAway = UIImage.init(named: nameAway) {self.plainAway.append(imageAway)}
            if let imageReturn = UIImage.init(named: nameReturn){ self.plainReturn.append(imageReturn)}
        }
        for i in 1..<39 {
            let imageName = String(i) + "f"
            if let image = UIImage.init(named: imageName) {
                self.plainInProgress.append(image)
            }
        }
    }
}




