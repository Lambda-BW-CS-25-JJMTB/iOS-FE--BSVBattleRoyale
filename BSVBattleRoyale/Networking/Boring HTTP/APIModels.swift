//
//  APIModels.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/5/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import Foundation
import CoreGraphics

/// just temporary until Josh adds his
struct TokenTemp: Codable {
	let key: String
}


struct PlayerInit: Codable {
	let playerID: String
	let currentRoom: String
	let spawnLocation: CGPoint
}


struct PlayerMove: Codable {
	let currentRoom: String
	let spawnLocation: CGPoint
}


struct PlayerInfo {
	var playerID: String
	var spawnLocation: CGPoint
}
