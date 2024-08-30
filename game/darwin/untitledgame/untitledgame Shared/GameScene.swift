import SpriteKit
import AppKit

class GameScene: SKScene {
    private var player: SKSpriteNode!
    private var cameraNode: SKCameraNode!
    private let playerSpeed: CGFloat = 5.0
    private var pressedKeys = Set<UInt16>()
    private var isJumping = false

    override func didMove(to view: SKView) {
        setupBackground()
        setupPlayer()
        setupCamera()
        setupKeyEventHandlers()
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
    }
    
    private func setupBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        let background = SKSpriteNode(texture: backgroundTexture)
        background.size = CGSize(width: size.width, height: size.height)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }

    private func setupPlayer() {
        let playerTexture = SKTexture(imageNamed: "player")
        player = SKSpriteNode(texture: playerTexture)
        player.size = CGSize(width: 40, height: 40)
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false
        addChild(player)
    }
    
    private func setupCamera() {
        cameraNode = SKCameraNode()
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
    }

    private func setupKeyEventHandlers() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.keyDown(with: event)
            return event
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyUp) { [weak self] event in
            self?.keyUp(with: event)
            return event
        }
    }

    override func update(_ currentTime: TimeInterval) {
        handlePlayerMovement()
        updateCamera()
    }
    
    private func handlePlayerMovement() {
        let moveAmount: CGFloat = playerSpeed
        if let player = player {
            if pressedKeys.contains(123) { // Left arrow key code
                player.position.x -= moveAmount
            }
            if pressedKeys.contains(124) { // Right arrow key code
                player.position.x += moveAmount
            }
            if pressedKeys.contains(126) && !isJumping { // Up arrow key code
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 150))
                isJumping = true
            }
        }
    }
    
    private func updateCamera() {
        guard let cameraNode = cameraNode else { return }
        let playerPosition = player.position
        let cameraPosition = CGPoint(x: playerPosition.x, y: size.height / 2)
        cameraNode.position = cameraPosition
    }

    override func didSimulatePhysics() {
        if let player = player, player.physicsBody?.velocity.dy == 0 {
            isJumping = false
        }
    }

    override func keyDown(with event: NSEvent) {
        pressedKeys.insert(event.keyCode)
    }

    override func keyUp(with event: NSEvent) {
        pressedKeys.remove(event.keyCode)
    }
}
