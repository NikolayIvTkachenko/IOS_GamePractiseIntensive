//
//  GameViewController.swift
//  GamePractise
//
//  Created by Nikolay Tkachenko on 14.09.2020.
//  Copyright © 2020 Nikolay Tkachenko. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    @IBOutlet weak var lblScore: UILabel!
    
    @IBOutlet weak var scnView: SCNView!
    //The ship
    var ship: SCNNode!
    
    var tapGesture: UITapGestureRecognizer!
    
    // create a new scene
    var scene = SCNScene(named: "art.scnassets/ship.scn")!
    
    //Set animation duration
    var duration : TimeInterval = 5
    //var duration = TimeInterval(5)
    
    var scoreCount = 0 {
        didSet{
            //Observer
            DispatchQueue.main.async {
                self.lblScore.text = String("Score: \(self.scoreCount)")
            }
        }
    }
    
    //Computed property
    var getShip : SCNNode? {
        scene.rootNode.childNode(withName: "ship", recursively: true)
    }
    
    func removeShip(){
        //ship.removeFromParentNode()//delete from scene
        getShip?.removeFromParentNode()
    }
    
    func spanShip() {
        //ship = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.childNode(withName: "ship", recursively: true)!
        //ship = scene.rootNode.clone()
        ship = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.clone()
        scene.rootNode.addChildNode(ship!)
        
        //position the ship
        //let x = 0
        //let y = 0
        let x = Int.random(in: -25 ... 25)
        let y = Int.random(in: -50 ... 50)
        let z = -105
        let position = SCNVector3(x, y ,z)
        ship?.position = position
        
        //Look at positon
        //let lookAtPosition = SCNVector3(0, 10 ,50)
        let lookAtPosition = SCNVector3(2 * x, 2 * y , 2 * z)
        ship.look(at: lookAtPosition)
        
        
        //ship.runAction(.move(to: SCNVector3(0, 10 ,50), duration: duration)){
        ship.runAction(.move(to: SCNVector3(), duration: duration)){
            print(#line, #function, "Animaion ended")
            self.removeShip()
            //self.spanShip()
            self.scoreCount = 0
            DispatchQueue.main.async {
                self.scnView.removeGestureRecognizer(self.tapGesture)
                self.lblScore.text = "Game Over"
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        removeShip()
        
        scoreCount = 0
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        

        //let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        // animate the 3d object
        //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        //Get programmaticaly , but now we will get from connected refer
        // retrieve the SCNView
        //let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        spanShip()
        
    }
    
    //Animation contact
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        //let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.25
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
//                SCNTransaction.begin()
//                SCNTransaction.animationDuration = 0.5
//                material.emission.contents = UIColor.black
//                SCNTransaction.commit()
                self.ship.removeAllActions()
                self.removeShip()
                
                self.scoreCount += 1
                
                
                //Increase the tempo
                self.duration *= 0.9
                
                //Span new ship
                self.spanShip()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
