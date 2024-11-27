
import UIKit
import SceneKit
import GLTFKit2

class ViewController: UIViewController {
    var asset: GLTFAsset? {
        didSet {
            if let asset = asset {
                let source = GLTFSCNSceneSource(asset: asset)
                sceneView.scene = source.defaultScene
                animations = source.animations
                if let defaultAnimation = animations.first {
                    defaultAnimation.animationPlayer.animation.usesSceneTimeBase = true
                    defaultAnimation.animationPlayer.animation.repeatCount = .greatestFiniteMagnitude
                    sceneView.scene?.rootNode.addAnimationPlayer(defaultAnimation.animationPlayer, forKey: nil)
                    defaultAnimation.animationPlayer.play()
                }
                sceneView.scene?.rootNode.addChildNode(cameraNode)
                prepareMainChanracterNodeElemens()
            }
        }
    }
    
    var asset2: GLTFAsset? {
        didSet {
            if let asset = asset2 {
                let source = GLTFSCNSceneSource(asset: asset)
                sceneView2.scene = source.defaultScene
                animations2 = source.animations
                if let defaultAnimation = animations2.first {
                    defaultAnimation.animationPlayer.animation.usesSceneTimeBase = true
                    defaultAnimation.animationPlayer.animation.repeatCount = .greatestFiniteMagnitude
                    sceneView2.scene?.rootNode.addAnimationPlayer(defaultAnimation.animationPlayer, forKey: nil)
                    defaultAnimation.animationPlayer.play()
                }
                sceneView2.scene?.rootNode.addChildNode(cameraNode2)
                prepareNodeElemens()
            }
        }
    }
    
    private var sceneView: SCNView!
    private var sceneView2: SCNView!
    
    private var animations = [GLTFSCNAnimation]()
    private var animations2 = [GLTFSCNAnimation]()
    
    // private let camera = SCNCamera()
    private let cameraNode2 = SCNNode()
    private let cameraNode = SCNNode()
    private let allModels = ["1", "tshirt2", "with_glass_cap", "formal"]
    
    var originalScene: GLTFScene?
    var replacementScene: GLTFScene?
    var nodeElements = [String: SCNNode]()
    var mainCharcterElements = [String: SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a UIBarButtonItem with a title and a target action
        let rightBarButton = UIBarButtonItem(title: "Remove All", style: .plain, target: self, action: #selector(removeButtonTapped))
        
        // Set it as the right bar button item in the navigation bar
        navigationItem.rightBarButtonItem = rightBarButton
        
        addSceneView()
        createSegmentedControl()
        loadAsset(assetName: "1")
        loadElementsNode()
    }
    
    func getAssertUrl(assetName: String) -> URL? {
        return  Bundle.main.url(forResource: assetName,
                                withExtension: "glb",
                                subdirectory: "Models")
    }
    
    private func loadAsset(assetName: String) {
        guard let assetURL = getAssertUrl(assetName: assetName)
        else {
            print("Failed to find asset for URL")
            return
        }
        
        GLTFAsset.load(with: assetURL, options: [:]) { (progress, status, maybeAsset, maybeError, _) in
            DispatchQueue.main.async {
                if status == .complete {
                    self.asset = maybeAsset
                } else if let error = maybeError {
                    print("Failed to load glTF asset: \(error)")
                }
            }
        }
    }
    func prepareMainChanracterNodeElemens() {
        if let arrChilds = sceneView.scene?.rootNode.childNodes.first?.childNodes {
            for child in arrChilds {
                if let name = child.name {
                    print(name)
                    mainCharcterElements[name] = child
                }
            }
        }
    }
    func findMainElementNode(name: String) -> SCNNode? {
        return mainCharcterElements[name]
    }
    private func reArrangeThePosition() {
        if let arrChilds = sceneView.scene?.rootNode.childNodes.first?.childNodes {
            for child in arrChilds {
                if let name = child.name,  let childNode = nodeElements[name]{
                    child.position = childNode.position
                }
            }
        }
    }
    private func addReplaceNode(newNodeName: String) {
        if let oldNode = mainCharcterElements[newNodeName], let newNode = nodeElements[newNodeName] {
            sceneView.scene?.rootNode.childNodes.first?.replaceChildNode(oldNode, with: newNode)
        } else {
            if let newNode = nodeElements[newNodeName] {
                sceneView.scene?.rootNode.childNodes.first?.addChildNode(newNode)
            }
        }
        reArrangeThePosition()
    }
    
    
    func prepareNodeElemens() {
        if let arrChilds = sceneView2.scene?.rootNode.childNodes.first?.childNodes {
            for child in arrChilds {
                if let name = child.name {
                    nodeElements[name] = child
                }
            }
        }
    }
    func findElementNode(name: String) -> SCNNode? {
        return nodeElements[name]
    }
    func loadElementsNode() {
        guard let assetURL = getAssertUrl(assetName: "with_glass_cap")
        else {
            return
        }
        GLTFAsset.load(with: assetURL, options: [:]) { (progress, status, maybeAsset, maybeError, _) in
            DispatchQueue.main.async {
                if status == .complete {
                    self.asset2 = maybeAsset
                } else if let error = maybeError {
                    print("Failed to load glTF asset: \(error)")
                }
            }
        }
    }
    func changeGlass() {
        addReplaceNode(newNodeName: "Wolf3D_Glasses")
    }
    func changeTshirt() {
        addReplaceNode(newNodeName: "Wolf3D_Outfit_Top")
    }
    func changeHeadWear() {
        addReplaceNode(newNodeName: "Wolf3D_Headwear")
    }
    func changeFootWear() {
        addReplaceNode(newNodeName: "Wolf3D_Outfit_Footwear")
    }
}
extension ViewController {
    func addSceneView() {
        // Set up the SCNView for rendering the scene
        sceneView = SCNView(frame: self.view.frame)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(sceneView)
        
        // Add constraints to make the sceneView fill the entire screen
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 120),
            sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -120),
            sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        
        sceneView2 = SCNView(frame: self.view.frame)
        sceneView2.allowsCameraControl = true
        sceneView2.autoenablesDefaultLighting = true
        
        self.view.bringSubviewToFront(sceneView)
    }
    func createSegmentedControl() {
        // Create a UISegmentedControl with an array of titles
        let items = ["T-Shirt", "Glass", "Head wear", "Foot wear"]
        let segmentedControl = UISegmentedControl(items: items)
        
        // Set the frame or constraints (for simplicity, we'll use frame here)
        segmentedControl.frame = CGRect(x: 50, y: 200, width: 300, height: 40)
        
        // Set a default selected segment (optional)
        segmentedControl.selectedSegmentIndex = -1
        
        // Add a target action to handle value changes
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        
        // Customize appearance (optional)
        segmentedControl.tintColor = .blue  // Set the tint color
        segmentedControl.backgroundColor = .lightGray  // Set the background color
        segmentedControl.selectedSegmentTintColor = .darkGray  // Set the selected segment color
        
        // Add to the view hierarchy
        self.view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints to make the sceneView fill the entire screen
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: 40),
            segmentedControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40),
            segmentedControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 44),
            segmentedControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -44)
        ])
    }
    
    @objc func removeButtonTapped() {
        loadAsset(assetName: "1")
    }
    
    @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        // You can perform actions based on the selected segment
        switch selectedIndex {
        case 0:
            self.changeTshirt()
        case 1:
            self.changeGlass()
        case 2:
            self.changeHeadWear()
        case 3:
            self.changeFootWear()
        default:
            break
        }
    }
}


/*
func changeNode(oldNodeName: String, newNodeName: String) {
    guard let assetURL = getAssertUrl(assetName: "with_glass_cap")
    else {
        print("Failed to find asset for URL")
        return
    }
    GLTFAsset.load(with: assetURL, options: [:]) { (progress, status, maybeAsset, maybeError, _) in
        DispatchQueue.main.async {
            if status == .complete {
                self.asset2 = maybeAsset
                let newTshirtNode = self.findNode(name: newNodeName, fromSceneView: self.sceneView2)
                let oldTshirtNode = self.findNode(name: oldNodeName, fromSceneView: self.sceneView)
                self.replaceNode(oldNode: oldTshirtNode, newNode: newTshirtNode)
            } else if let error = maybeError {
                print("Failed to load glTF asset: \(error)")
            }
        }
    }
}
func changeTshirt() {
    let randomNumber = Int.random(in: 0...allModels.count - 1)  // Random number between 1 and 100
    print(randomNumber)
    guard let assetURL = getAssertUrl(assetName: allModels[randomNumber])
    else {
        print("Failed to find asset for URL")
        return
    }
    GLTFAsset.load(with: assetURL, options: [:]) { (progress, status, maybeAsset, maybeError, _) in
        DispatchQueue.main.async {
            if status == .complete {
                self.asset2 = maybeAsset
                let newTshirtNode = self.findNode(name: "Wolf3D_Outfit_Top", fromSceneView: self.sceneView2)
                let oldTshirtNode = self.findNode(name: "Wolf3D_Outfit_Top", fromSceneView: self.sceneView)
                self.replaceNode(oldNode: oldTshirtNode, newNode: newTshirtNode)
            } else if let error = maybeError {
                print("Failed to load glTF asset: \(error)")
            }
        }
    }
 private func addReplaceNode(oldNode: SCNNode?, newNode: SCNNode?) {
     if let oldNode = oldNode, let newNode = newNode {
         sceneView.scene?.rootNode.childNodes.first?.replaceChildNode(oldNode, with: newNode)
     } else {
         if let newNode = newNode {
             sceneView.scene?.rootNode.childNodes.first?.addChildNode(newNode)
         }
         if let oldNode = oldNode {
             oldNode.removeFromParentNode()
         }
     }
     reArrangeThePosition()
 }
}
*/
