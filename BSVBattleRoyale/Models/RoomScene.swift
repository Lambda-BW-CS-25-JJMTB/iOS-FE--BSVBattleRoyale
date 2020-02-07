//
//  RoomScene.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import SpriteKit


protocol RoomSceneDelegate: AnyObject {
	func player(_ currentPlayer: Player, enteredDoor: DoorSprite)
}

class RoomScene: SKScene {

	var otherPlayers = [String: Player]()

	let background = RoomSprite()
	var currentPlayer: Player?
	var liveController: LiveConnectionController?
	var apiController: APIController?
	weak var roomDelegate: RoomSceneDelegate?

	private static var _playerInfoFetchTasks = [String: URLSessionDataTask]()
	private static var _playerInfo = [String: PlayerInfo]()


	private lazy var fadeSprite: SKSpriteNode = {
		let sp = SKSpriteNode(color: .black, size: self.size)
		self.camera?.addChild(sp)
		sp.alpha = 0
		return sp
	}()

	override func didMove(to view: SKView) {
		super.didMove(to: view)
		setupScene()
	}

	func setupScene() {
		addChild(background)

		physicsWorld.gravity = CGVector.zero
		physicsWorld.contactDelegate = self
	}

	func loadRoom(room: Room?, playerPosition: CGPoint, playerID: String) {
		background.room = room

		let newPlayer = Player(avatar: .greenMonster, id: playerID, username: "", position: playerPosition)
		addChild(newPlayer)
		currentPlayer = newPlayer
		newPlayer.zPosition = 1

		loadInfoForPlayer(newPlayer)

		let playerCamera = SKCameraNode()
		newPlayer.addChild(playerCamera)
		camera = playerCamera
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		for touch in touches {
			let location = touch.location(in: self)
			changePlayerDestination(to: location)
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		for touch in touches {
			let location = touch.location(in: self)
			changePlayerDestination(to: location)
		}
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		for touch in touches {
			let location = touch.location(in: self)
			changePlayerDestination(to: location)
		}
	}

	private func changePlayerDestination(to location: CGPoint) {
		currentPlayer?.destination = location
	}

	override func update(_ currentTime: TimeInterval) {
		super.update(currentTime)

		// send player position
		guard let player = currentPlayer else { return }
		liveController?.updatePlayerPosition(player.position, destination: player.destination)
	}

	func updateOtherPlayers(updatePlayers: [String: PositionPulseUpdate]) {
		guard let currentPlayer = currentPlayer else { return }
		var newPlayers = updatePlayers
		var expiredPlayers = [Player]()
		// dont track current player
		newPlayers[currentPlayer.id] = nil

		for (id, updatedPlayer) in otherPlayers {
			guard let update = updatePlayers[id] else {
				// if this player isn't in this update, mark them as expired
				expiredPlayers.append(updatedPlayer)
				continue
			}
			// update any other consistent player's position
			if updatedPlayer.position.distance(to: update.position, isWithin: 150) {
				updatedPlayer.destination = update.destination
			} else {
				updatedPlayer.setPosition(to: update.position)
			}
			// unmark this player as a new player
			newPlayers[id] = nil
		}

		// add all new players to the scene and track them
		for (id, newPlayer) in newPlayers {
			let addtlPlayer = Player(avatar: .yellowMonster, id: id, username: "", position: newPlayer.position)
			addChild(addtlPlayer)
			otherPlayers[id] = addtlPlayer
			addtlPlayer.setPosition(to: newPlayer.position)
			loadInfoForPlayer(addtlPlayer)
		}

		// remove expired players
		for delete in expiredPlayers {
			otherPlayers[delete.id] = nil
			delete.removeFromParent()
		}
	}

	func chatReceived(from playerID: String, message: String) {
		if let player = otherPlayers[playerID] {
			player.say(message: message)
		} else if currentPlayer?.id == playerID {
			currentPlayer?.say(message: message)
		}
	}

	func loadInfoForPlayer(_ player: Player) {
		if let playerInfo = RoomScene._playerInfo[player.id] {
			DispatchQueue.main.async {
				player.avatar = Avatar(rawValue: playerInfo.player_avatar) ?? .yellowMonster
				player.username = playerInfo.username
			}
		} else {
			guard RoomScene._playerInfoFetchTasks[player.id] == nil else { return }
			RoomScene._playerInfoFetchTasks[player.id] = apiController?.fetchPlayerInfo(for: player.id, completion: { [weak self] result in
				switch result {
				case .success(let info):
					RoomScene._playerInfo[player.id] = info
					self?.loadInfoForPlayer(player)
				case .failure(let error):
					print("Error fetching player info for \(player.id): \(error)")
				}
				RoomScene._playerInfoFetchTasks[player.id] = nil
			})
		}
	}
}

extension RoomScene: SKPhysicsContactDelegate {

	func didBegin(_ contact: SKPhysicsContact) {
		let bodies = Set([contact.bodyB, contact.bodyA])
		var physicNodes = Set(bodies.compactMap { $0.node })

		if let currentPlayer = currentPlayer {
			if physicNodes.contains(currentPlayer) && physicNodes.contains(background) {
//				currentPlayer.stopMove()
			}

			// one of the nodes is player
			if physicNodes.remove(currentPlayer) != nil {
				if let door = physicNodes.removeFirst() as? DoorSprite {
					currentPlayer.physicsBody = nil
					let action = SKAction.fadeIn(withDuration: 0.1)
					fadeSprite.run(action)
					roomDelegate?.player(currentPlayer, enteredDoor: door)
				}
			}
		}
	}
}
