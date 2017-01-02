//
//  MortgageListVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 1/2/17.
//  Copyright © 2017 Kaelin Hooper. All rights reserved.
//

import UIKit

class MortgageListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var mortgageData = MortgageData()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        layoutViews()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    func layoutViews() {
        layoutNavigationBar()
    }
    
    func layoutNavigationBar() {
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor(rgbColorCodeRed: 238, green: 87, blue: 106, alpha: 1.0)
        self.navigationItem.title = "Mortgages"
        nav?.titleTextAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Light", size: 20.0)!, NSForegroundColorAttributeName: UIColor(rgbColorCodeRed: 155, green: 155, blue: 155, alpha: 1.0)]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "addbutton"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addMortgage))
        self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 15.0, left: 30.0, bottom: 15.0, right: 0.0)
    }
    
    func addMortgage() {
        performSegue(withIdentifier: "toCreateMortgage", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "toCreateMortgage" {
            let dest: CreateMortgageVC = segue.destination as! CreateMortgageVC
            dest.mortgageData = self.mortgageData
        } else if segue.identifier! == "toMortgageDetail" {
            if let cellIndexPath = sender as? IndexPath {
                let cellIndex = cellIndexPath.row
                
                let mortgage = self.mortgageData.mortgages[cellIndex]
                
                let mortgageDetailVC = segue.destination as! MortgageDetailVC
                mortgageDetailVC.mortgage = mortgage
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mortgageData.mortgages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        cell.textLabel?.text = String(indexPath.row)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toMortgageDetail", sender: indexPath)
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


class MortgageData {
    var mortgages: [Mortgage] = []
}
