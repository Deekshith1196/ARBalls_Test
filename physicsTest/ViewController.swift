//
//  ViewController.swift
//  physicsTest
//
//  Created by Deekshith Maram on 10/9/18.
//  Copyright © 2018 Deekshith Maram. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var fixPlane: UIButton!
    let sphereNodeName = "sphere"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show statistics such as fps and timing information
         sceneView.showsStatistics = true
         sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    
        addTapGestureToSceneView()
    }
    
    func setupSceneView(){
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        sceneView.delegate = self
    }
    
    func setupLighting(){
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
          setupSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
         setupLighting()
    }
    
    func addTapGestureToSceneView() {
     
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addBalls(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func fixPlane(_ sender: Any) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [] //empty array (as opposed to .horizontal .vertical)
        sceneView.session.run(configuration)
        fixPlane.isHidden = true
    }
    
    @objc func addBalls(withGestureRecognizer recognizer: UIGestureRecognizer){
      
        let tapLocation = recognizer.location(in: sceneView)
        
       // let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlane)
        
        guard let hitTestResult = hitTestResults.first else{
            return
        }
        
        let translation = hitTestResult.worldTransform.columns.3
        
        let x = translation.x
        let y = translation.y + 0.5
        let z = translation.z
        
        let sphere = SCNSphere(radius: 0.05)
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.geometry?.firstMaterial?.diffuse.contents = getRandomColor()
        sphereNode.physicsBody?.isAffectedByGravity = true
        sphereNode.position = SCNVector3(x,y,z)
        
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        sphereNode.physicsBody = physicsBody
        sphereNode.name = sphereNodeName
       
        sceneView.scene.rootNode.addChildNode(sphereNode)
        
    }
    func getRandomColor() -> UIColor {
        //Generate between 0 to 1
        let red:CGFloat = CGFloat(drand48())
        let green:CGFloat = CGFloat(drand48())
        let blue:CGFloat = CGFloat(drand48())
        
        return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor.red
        
        var planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        update(&planeNode, withGeometry: plane, type: .static)
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            var planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }

        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height

        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)

        planeNode.position = SCNVector3(x, y, z)

        update(&planeNode, withGeometry: plane, type: .static)

    }
    
    func update(_ node: inout SCNNode, withGeometry geometry: SCNGeometry, type: SCNPhysicsBodyType) {
        let shape = SCNPhysicsShape(geometry: geometry, options: nil)
        let physicsBody = SCNPhysicsBody(type: type, shape: shape)
        node.physicsBody = physicsBody
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
