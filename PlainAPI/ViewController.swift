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
    
    @IBOutlet weak var topView          : UIView!
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
    var pleaseChooseLabel     : UILabel!
    var imageviewPlainFlying  : UIImageView?
    var backView              : UIView?
    var imageviewGoAway       : UIImageView?
    var isDone                = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.controllerSettings()
        self.topView.addShadow(opacity: 1, radius: 3)
        self.configurateButton()
    }
    
    //MARK: Actions
    @IBAction func buttonFrom(_ sender: UIButton) {
        dropDownFrom.show()
    }
    @IBAction func buttonTo(_ sender: UIButton) {
        dropDownTo.show()
    }
    override func viewDidLayoutSubviews() {
        self.pleaseChooseLabel.frame = CGRect(origin: CGPoint(x:  self.pleaseChooseLabel.frame.origin.x, y:  self.pleaseChooseLabel.frame.origin.y), size: CGSize(width: self.tableView.bounds.width, height: self.tableView.bounds.height * 0.5))
    }
    //MARK: ButtonConfiguration
    func configurateButton(){
        self.backView = UIView(frame: CGRect(x: self.view.bounds.width * 0.78, y: self.view.bounds.height * 0.85, width: 60, height: 60))
        backView?.layer.cornerRadius = (backView?.bounds.width)! / 2
        backView?.backgroundColor = .buttonColor
        backView?.layer.masksToBounds = true
        
        let secondView = UIView.init(frame: (backView?.frame)!)
        secondView.layer.cornerRadius = (secondView.bounds.width / 2) + 3
        secondView.backgroundColor = .white
        secondView.addShadow(opacity: 1, radius: 3)
        self.imageviewPlainFlying = UIImageView(image: #imageLiteral(resourceName: "PlainBlack"))
        imageviewPlainFlying?.contentMode = UIViewContentMode.scaleAspectFit
        imageviewPlainFlying?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI * 1.5))
        self.imageviewPlainFlying?.tintColor = UIColor(white: 0.3, alpha: 1.0)
        self.imageviewPlainFlying?.frame = CGRect(x: (backView?.bounds.maxX)! + (imageviewPlainFlying?.bounds.width)!, y:  (backView?.bounds.midY)! - 10, width: 20, height: 20)
        
        self.imageviewGoAway = UIImageView(image: #imageLiteral(resourceName: "PlainBlack"))
        self.imageviewGoAway?.contentMode = UIViewContentMode.scaleAspectFit
        self.imageviewGoAway?.tintColor = UIColor(white: 1, alpha: 1.0)
        self.imageviewGoAway?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        self.imageviewGoAway?.frame = CGRect(x: 15, y: 15, width: 30, height: 30)
        
        backView?.addSubview(imageviewPlainFlying!)
        backView?.addSubview(imageviewGoAway!)
        secondView.addSubview(backView!)
        
        self.view.addSubview(secondView)
        self.view.addSubview(backView!)
        self.backView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendRequest)))
        
    }
    //MARK: ButtonAction
    func fly() {
        UIView.animate(withDuration: 1, animations: {
            self.imageviewGoAway?.frame.origin.x = (self.backView?.frame.width)! +  (self.imageviewGoAway?.frame.width)!
            
        }) { (Bool) in
            self.imageviewPlainFlying?.frame = CGRect(x: (self.backView?.bounds.maxX)! + (self.imageviewPlainFlying?.bounds.width)!, y:  (self.backView?.bounds.midY)! - 10, width: 20, height: 20)
            UIView.animate(withDuration: 2, animations: {
                self.imageviewPlainFlying?.frame = CGRect(x: (self.backView?.bounds.maxX)! , y:  (self.backView?.bounds.midY)! - 10, width: 20, height: 20)
                self.imageviewPlainFlying?.frame.origin.x -= ((self.backView?.bounds.width)! + (self.imageviewPlainFlying?.bounds.width)!)
            }) { (Bool) in
                if self.isDone {
                    self.imageviewGoAway?.frame = CGRect(x: (self.backView?.bounds.minX)! -  (self.imageviewGoAway?.bounds.width)!, y: 15, width: 30, height: 30)
                    UIView.animate(withDuration: 1) {
                        self.imageviewGoAway?.frame = CGRect(x: 15, y: 15, width: 30, height: 30)
                    }
                } else {
                    self.fly()
                }
            }
        }
    }
    func sendRequest(){
        self.isDone = false
        guard let cityCodeFrom = self.from else { self.alertViewWith(message: self.constants.alertMessage, title: self.constants.alertTitle);self.isDone = true;  return }
        guard let cityCodeTo   = self.to   else { self.alertViewWith(message: self.constants.alertMessage, title: self.constants.alertTitle);self.isDone = true;
            return }
        if self.from == self.to {
            self.alertViewWith(message: self.constants.ifOriginAndDistinctisEqual, title:"");self.isDone = true; return }
        DataManager.requestAPI(from: cityCodeFrom, to: cityCodeTo) { (response) in
            guard response.count != 0 else {
                self.alertViewWith(message:self.constants.alertMessageError, title: self.constants.alertTitle);self.isDone = true; return }
            self.trips = response
            self.tableView.reloadData()
            self.pleaseChooseLabel.frame.origin.x = self.pleaseChooseLabel.frame.origin.x + self.view.frame.width
            self.isDone = true
        }
        self.fly()
    }
    
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
        self.pleaseChooseLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: self.tableView.frame.origin.y), size: CGSize(width: self.tableView.bounds.width, height: self.tableView.bounds.height * 0.5)))
        self.pleaseChooseLabel.numberOfLines = 3
        self.pleaseChooseLabel.textAlignment = NSTextAlignment.center
        self.pleaseChooseLabel.text = self.constants.chooseCityes
        self.pleaseChooseLabel.font.withSize(25)
        self.view.addSubview(pleaseChooseLabel)
    }
    func alertViewWith(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [unowned self] (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        })
        self.present(alert, animated: true, completion: nil)
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
        cell.mainView.addShadow(opacity: 0.5, radius: 3)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.width, height: 100))
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
}

extension UIView {
    func addShadow( opacity: Float,radius: CGFloat){
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = radius
    }
}
extension UIColor {
    
    open class var buttonColor: UIColor { get
    {
        return UIColor(red: 22/255, green: 122/255, blue: 255/255, alpha: 1)
        }
    }
    
}




