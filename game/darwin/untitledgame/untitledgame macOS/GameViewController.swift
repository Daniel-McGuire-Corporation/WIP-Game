import Cocoa
import SpriteKit

class GameViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a new SKScene instance
        if let view = self.view as? SKView {
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
        }
    }
}
