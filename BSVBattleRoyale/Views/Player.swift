//
//  Player.swift
//  BSVBattleRoyale
//
//  Created by Michael Redig on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import SpriteKit

enum PlayerDirection: String {
	case left
	case right
}

enum Avatar: Int, CaseIterable {
	case blueMonster
	case greenMonster
	case pinkMonster
	case purpleMonster
	case yellowMonster
}

enum AnimationTitle: String, CaseIterable {
	// ordered by priority, lowest to highest
	case idle = "Idle"
	case walk = "Walk"
	case run = "Run"
	case attack = "Attack"
	case jump = "Jump"
	case die = "Die"
}

protocol PlayerInteractionDelegate: AnyObject {
	func player(_ player: Player, attackedFacing facing: PlayerDirection)
}

class Player: SKNode {
	var direction: PlayerDirection = .right {
		didSet {
			updateFacing()
		}
	}

	private let playerSprite: SKSpriteNode
	private let nameSprite: SKLabelNode
	private let chatBubbleSprite: ChatBubble
	var avatar: Avatar {
		didSet {
			updateAvatar()
		}
	}
	let id: String
	var username: String {
		get { nameSprite.text ?? "" }
		set { nameSprite.text = newValue }
	}

	var currentAnimations = Set([AnimationTitle.idle])
	var animationPriority: AnimationTitle {
		for animation in AnimationTitle.allCases.reversed() {
			if currentAnimations.contains(animation) {
				return animation
			}
		}
		return .idle
	}
	var animationMaintainer: Timer?
	var moverMaintainer: Timer?
	private var lastTimerFire: TimeInterval = 0
	var movementSpeed: CGFloat = 250
	var movementSpeedMultiplier: CGFloat = 1

	weak var interactionDelegate: PlayerInteractionDelegate?

	var destination: CGPoint

	init(avatar: Avatar, id: String, username: String = "Player \(Int.random(in: 0...500))", position: CGPoint) {
		self.avatar = avatar
		let idleAnimation = Player.animationTextures(for: avatar, animationTitle: AnimationTitle.idle)
		playerSprite = SKSpriteNode(texture: idleAnimation.first)
		self.id = id

		nameSprite = SKLabelNode(text: username)
		nameSprite.color = UIColor(hue: CGFloat.random(in: 0...1), saturation: CGFloat.random(in: 0.6...1), brightness: CGFloat.random(in: 0.7...1), alpha: 1)
		nameSprite.horizontalAlignmentMode = .center
		nameSprite.verticalAlignmentMode = .center
		nameSprite.position = CGPoint(x: 0, y: playerSprite.size.height / 2)
		nameSprite.fontSize = 20
		nameSprite.fontName = "Verdana"
		chatBubbleSprite = ChatBubble()
		destination = position
		super.init()
		self.position = position
		addChild(playerSprite)
		addChild(nameSprite)
		addChild(chatBubbleSprite)
		chatBubbleSprite.position = CGPoint(x: 0, y: nameSprite.calculateAccumulatedFrame().size.height + nameSprite.position.y + 30)

		physicsBody = SKPhysicsBody(circleOfRadius: playerSprite.size.width / 3)
		physicsBody?.categoryBitMask = playerBitmask
		physicsBody?.contactTestBitMask = wallBitmask | doorBitmask // | playerBitmask
		physicsBody?.collisionBitMask = wallBitmask | doorBitmask

		animationMaintainer = Timer.scheduledTimer(withTimeInterval: 1/15, repeats: true, block: { [weak self] _ in
			self?.updateCurrentAnimation()
		})

		moverMaintainer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true, block: { [weak self] _ in
			guard let self = self else { return }
			let currentTime = CFAbsoluteTimeGetCurrent()
			self.stepTowardsDestination(interval: min(currentTime - self.lastTimerFire, 1))
			self.lastTimerFire = currentTime
		})
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init coder not implemented")
	}

	override func removeFromParent() {
		animationMaintainer?.invalidate()
		animationMaintainer = nil
		moverMaintainer?.invalidate()
		super.removeFromParent()
	}

	private func updateFacing() {
		playerSprite.xScale = direction == .left ? 1.0 : -1.0
	}

	private func updateAvatar() {
		AnimationTitle.allCases.forEach { playerSprite.removeAction(forKey: "animation\($0.rawValue)") }
		updateCurrentAnimation()
	}

	private func updateCurrentAnimation() {
		if playerSprite.action(forKey: "animation\(animationPriority.rawValue)") == nil {
			for animation in AnimationTitle.allCases {
				playerSprite.removeAction(forKey: "animation\(animation.rawValue)")
			}
			playerSprite.run(Player.animationAction(for: avatar, animationTitle: animationPriority), withKey: "animation\(animationPriority.rawValue)")
		}
	}

	func setPosition(to position: CGPoint) {
		destination = position
		self.position = position
	}

	private func stepTowardsDestination(interval: TimeInterval) {
		guard !position.distance(to: destination, isWithin: 3) else {
			currentAnimations.remove(.walk)
			currentAnimations.remove(.run)
			return
		}
		direction = destination.x > position.x ? .right : .left

		position.step(toward: destination, interval: interval, speed: movementSpeed * movementSpeedMultiplier)
		currentAnimations.insert(.walk)
	}

	func say(message: String) {
		chatBubbleSprite.text = message
	}


	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		attack()
	}

	func attack() {
		guard !currentAnimations.contains(.attack) else { return }
		interactionDelegate?.player(self, attackedFacing: direction)
		let textures = Player.animationTextures(for: avatar, animationTitle: .attack)
		let duration = TimeInterval(textures.count) * Player.animationFrameSpeed
		currentAnimations.insert(.attack)
		DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
			self.currentAnimations.remove(.attack)
		}
	}

	func hitAnimation() {
		let flashRed = SKAction.sequence([
			SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 0.05),
			SKAction.colorize(with: .red, colorBlendFactor: 0, duration: 0.05)
		])
		playerSprite.run(flashRed)
	}
}

extension Player {
	private static let animationKey = "animation"
	private static let moveKey = "move"
	static let animationFrameSpeed: TimeInterval = 1/12

	static let yellowAtlas = SKTextureAtlas(named: "YellowMonster")
	static let pinkAtlas = SKTextureAtlas(named: "PinkMonster")
	static let purpleAtlas = SKTextureAtlas(named: "PurpleMonster")
	static let greenAtlas = SKTextureAtlas(named: "GreenMonster")
	static let blueAtlas = SKTextureAtlas(named: "BlueMonster")

	static func animationTextures(for avatar: Avatar, animationTitle: AnimationTitle) -> [SKTexture] {
		let atlas: SKTextureAtlas
		switch avatar {
		case .yellowMonster:
			atlas = yellowAtlas
		case .blueMonster:
			atlas = blueAtlas
		case .greenMonster:
			atlas = greenAtlas
		case .purpleMonster:
			atlas = purpleAtlas
		case .pinkMonster:
			atlas = pinkAtlas
		}
		let names = atlas.textureNames
			.filter { $0.hasPrefix(animationTitle.rawValue) && !$0.contains("@2x") && !$0.contains("@3x") }
		let sorted = names.map{ ($0 as NSString).deletingPathExtension }.sorted()
		let textures = sorted.map { atlas.textureNamed($0) }
		return textures
	}

	static func animationAction(for avatar: Avatar, animationTitle: AnimationTitle) -> SKAction {
		animationAction(with: animationTextures(for: avatar, animationTitle: animationTitle))
	}

	static func animationAction(with textures: [SKTexture]) -> SKAction {
		let animation = SKAction.animate(with: textures, timePerFrame: animationFrameSpeed)
		return SKAction.repeatForever(animation)
	}
}
