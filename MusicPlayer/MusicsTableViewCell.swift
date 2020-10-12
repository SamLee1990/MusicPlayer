//
//  MusicsTableViewCell.swift
//  MusicPlayer
//
//  Created by 李世文 on 2020/9/22.
//

import UIKit

class MusicsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var singerAlbumNameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setInfo(song: Song){
        musicImageView.image = UIImage(named: song.musicImageName)
        songNameLabel.text = song.songName
        singerAlbumNameLabel.text = "\(song.singerName)-\(song.albumName)"
    }

}
