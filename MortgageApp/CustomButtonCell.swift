//
//  CustomButtonCell.swift
//  MortgageApp
//
//  Created by Christopher Combes on 2/2/17.
//  Copyright © 2017 Keller Williams Realty, Inc. All rights reserved.
//

import Foundation
import Eureka

struct ButtonData: Equatable {
    var title: String
    var action: ClosureSleeve

    mutating func addClosure (closure: @escaping ()->(), controlEvents: UIControlEvents) {
        action = ClosureSleeve(closure)
    }
}

func ==(lhs: ButtonData, rhs: ButtonData) -> Bool {
    return lhs.title == rhs.title
}

class ClosureSleeve {
    let closure: ()->()
    
    init (_ closure: @escaping ()->()) {
        self.closure = closure
    }
    
    @objc func invoke () {
        closure()
    }
}

extension UIButton {
    func addClosure (closure: @escaping ()->(), controlEvents: UIControlEvents) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}

final class CustomButtonCell: Cell<ButtonData>, CellType {
    
    @IBOutlet weak var customButtonView: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        
        // we do not want our cell to be selected in this case.
        // If you use such a cell in a list then you might want to change this.
        selectionStyle = UITableViewCellSelectionStyle.none
        
        // specify the desired height for our cell
        height = { return 44 }
    }
    
    override func update() {
        super.update()
        
        // we do not want to show the default UITableViewCell's textLabel
        textLabel?.text = nil
        
        // get the value from our row
        guard let button = row.value else { return }
        
        // set button label text
        titleLabel.text = button.title

        customButtonView.addClosure(closure: button.action.closure, controlEvents: UIControlEvents.touchUpInside)
    }
}

final class CustomButtonRow: Row<CustomButtonCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<CustomButtonCell>(nibName: "CustomButtonCell")
    }
}
