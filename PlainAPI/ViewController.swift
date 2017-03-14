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
    
    @IBOutlet weak var backGroundViewBottom: UIView!
    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var backGroundViewTop: UIView!
    @IBOutlet weak var buttonFrom       : UIButton!
    @IBOutlet weak var buttonTo         : UIButton!
    @IBOutlet weak var arrivalCity      : UILabel!
    @IBOutlet weak var departureCity    : UILabel!
    @IBOutlet weak var labelFrom        : UILabel!
    @IBOutlet weak var labelTo          : UILabel!
    @IBOutlet weak var tableView        : UITableView!
    
    var dropDownFrom : DropDown!
    var dropDownTo   : DropDown!
    var airportsName = [String]()
    var shortTitle   = [String]()
    var trips        = [APIData]()
    var constants    = Constants()
    var from                : String?
    var to                  : String?
    var startButtonPosition : CGPoint?
    var startTableViewPostion :CGPoint?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.controllerSettings()

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
    @IBAction func sendRequest(_ sender: UIButton) {
        guard let cityCodeFrom = self.from else { self.alertViewWith(message: self.constants.alertMessage, title: self.constants.alertTitle);self.defaultPsitions(1);  return }
        guard let cityCodeTo   = self.to   else { self.alertViewWith(message: self.constants.alertMessage, title: self.constants.alertTitle);self.defaultPsitions(1);
            return }
         if self.from == self.to {
            self.alertViewWith(message: self.constants.ifOriginAndDistinctisEqual, title:"");self.defaultPsitions(1); return }
        
        self.goAwayWith(1)
        DataManager.requestAPI(from: cityCodeFrom, to: cityCodeTo, responseData: { (response ) in
            guard response.count != 0 else {
                self.alertViewWith(message:self.constants.alertMessageError, title: self.constants.alertTitle); return }
        self.defaultPsitions(1)
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
        cell.arrival.text   = self.constants.plainWillArrive + dataForCell.arrival
        cell.departure.text = self.constants.plainWillDeparture +   dataForCell.departure
        cell.price.text     = self.constants.ticketPrice + dataForCell.price
        cell.slice.text     = self.constants.sliceCount + String(dataForCell.sliceCount)
        return cell
    }
}
// MARK: ViewController settings
extension ViewController {
    func controllerSettings(){
        self.airportsName           = self.constants.airportsName
        self.shortTitle             = self.constants.shortTitle
        self.labelFrom.text         = self.constants.flyFromLabel
        self.labelTo.text           = self.constants.flyTo
        self.departureCity.text     = self.constants.city
        self.arrivalCity.text       = self.constants.city
       
        self.borderFor(buttonFrom)
        self.borderFor(buttonTo)
        dropDownFrom = DropDown()
        dropDownFrom.anchorView = buttonFrom
        dropDownFrom.dataSource = self.airportsName
        dropDownFrom.selectionAction = {(index: Int, item: String) in
            self.departureCity.text = item
            self.from = self.shortTitle[index]
        }
        dropDownTo = DropDown()
        dropDownTo.anchorView = buttonTo
        dropDownTo.dataSource = self.airportsName
        dropDownTo.selectionAction = { (index: Int, item: String) in
            self.arrivalCity.text = item
            self.to = self.self.shortTitle[index]
        }
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
    
    func goAwayWith(_ duration: Double) {
        UIView.animate(withDuration: TimeInterval(duration)) {
            let awayPosition = -self.view.frame.width
            self.tableView.frame.origin.x = awayPosition
            self.sendRequestButton.frame.origin.y = self.tableView.frame.origin.y
        }
    }
    func defaultPsitions(_ duration: Double){
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.tableView.frame.origin = self.startTableViewPostion!
            self.sendRequestButton.frame.origin = self.startButtonPosition!
        }
    }
    
    func borderFor(_ button: UIButton) {
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
    }
}


