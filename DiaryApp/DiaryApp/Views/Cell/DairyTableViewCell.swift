//
//  DairyTableViewCell.swift
//  DiaryApp
//
//  Created by ali on 19.05.2022.
//

import UIKit

class DairyTableViewCell: UITableViewCell {

    @IBOutlet var sybolLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var diaryImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
