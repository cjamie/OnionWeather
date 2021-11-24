//
//  SubtitleTableViewCell.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/23/21.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell {
    static let reuseId = "SubtitleTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.numberOfLines = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
