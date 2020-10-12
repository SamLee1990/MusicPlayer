//
//  Song.swift
//  MusicPlayer
//
//  Created by 李世文 on 2020/9/22.
//

import Foundation

struct Song{
    let songName: String
    let albumName: String
    let singerName: String
    var musicImageName: String{
        "\(singerName)-\(albumName)"
    }
}
