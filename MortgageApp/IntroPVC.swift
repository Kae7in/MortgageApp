//
//  IntroPVC.swift
//  MortgageApp
//
//  Created by Kaelin Hooper on 12/12/16.
//  Copyright © 2016 Kaelin Hooper. All rights reserved.
//

import UIKit

class IntroPVC: UIPageViewController {
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newIntroVC(num: 1), self.newIntroVC(num: 2), self.newIntroVC(num: 3)]
    }()
    var horizontalLine: UIView? = nil
    var label: UILabel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
//        setBackgroundColors()
//        drawHorizontalLine()
//        addMessage()
    }
    
    private func newIntroVC(num: Int) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IntroVC\(num)")
    }
    
    func setBackgroundColors() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.init(rgbColorCodeRed: 39, green: 227, blue: 233, alpha: 1).cgColor, UIColor.init(rgbColorCodeRed: 0, green: 148, blue: 180, alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradient, at: 0)
        //use startPoint and endPoint to change direction of gradient (http://stackoverflow.com/a/20387923/2057171)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func drawHorizontalLine() {
        let lineFrame = CGRect(x: 0.0, y: (view.frame.height / 2.0) - 35.0, width: view.frame.width, height: 1.0)
        horizontalLine = UIView(frame: lineFrame)
        horizontalLine?.backgroundColor = UIColor.white
        view.addSubview(horizontalLine!)
    }
    
    func addMessage() {
        let string = "Your loan is made up of principal and interest, which combine to form the remaining balance."
        let defaultFontAttributes = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Ultralight", size: 38.0)!, NSForegroundColorAttributeName: UIColor.white]
        let attributedString = NSMutableAttributedString(string: string, attributes: defaultFontAttributes)
        let boldFontAttribute = [NSFontAttributeName: UIFont(name: ".SFUIDisplay-Medium", size: 38.0)!]

        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "principal"))
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "interest"))
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "balance"))
        
        label = UILabel(frame: CGRect(x: 10.0, y: 0.0, width: view.frame.width - 20.0, height: CGFloat.greatestFiniteMagnitude))  // maximum height used because we will resize dynamically
        label?.textAlignment = .left
        label?.attributedText = attributedString
        label?.numberOfLines = 4
        label?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label!.adjustsFontSizeToFitWidth = true
        label!.minimumScaleFactor = 24.0 / label!.font.pointSize  // Dynamically resize font to fit label
        label?.sizeToFit()  // Must dynamically size resize label to fit the text more exactly
        let y: CGFloat = self.horizontalLine!.frame.minY - label!.frame.height
        label!.frame = CGRect(x: label!.frame.minX, y: y - 5.0, width: label!.frame.width, height: label!.frame.height)
        view.addSubview(label!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


extension IntroPVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    // PAGE DOTS
//    func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        return orderedViewControllers.count
//    }
//    
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        guard let firstViewController = viewControllers?.first, let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
//            return 0
//        }
//        
//        return firstViewControllerIndex
//    }
}
