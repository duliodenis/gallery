//
//  ViewController.swift
//  Gallery
//
//  Created by Dulio Denis on 4/5/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var gallery = [Art]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        updateGallery()
        
        if gallery.count == 0 {
            createArt("Mona Lisa", imageName: "mona-lisa.jpg", productIdentifier: "", purchased: true)
            createArt("The Starry Night", imageName: "starry-night.jpg", productIdentifier: "", purchased: true)
            createArt("The Scream", imageName: "the-scream.jpg", productIdentifier: "", purchased: true)
            createArt("The Persistence of Memory", imageName: "the-persistence-of-memory-1931.jpg", productIdentifier: "", purchased: true)
            updateGallery()
            collectionView.reloadData()
        }
    }
    
    
    // MARK: Core Data Function
    
    func createArt(title: String, imageName: String, productIdentifier: String, purchased: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        if let entity = NSEntityDescription.entityForName("Art", inManagedObjectContext: context) {
            let art = NSManagedObject(entity: entity, insertIntoManagedObjectContext: context) as! Art
            art.title = title
            art.imageName = imageName
            art.productIdentifier = productIdentifier
            art.purchased = NSNumber(bool: purchased)
        }
        
        do {
            try context.save()
        } catch{}
    }
    
    
    func updateGallery() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        let fetch = NSFetchRequest(entityName: "Art")
        do {
            let artPieces = try context.executeFetchRequest(fetch)
            self.gallery = artPieces as! [Art]
        } catch {}
    }
    
    
    // MARK: Collection View Delegate Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gallery.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ArtCollectionViewCell", forIndexPath: indexPath) as! ArtCollectionViewCell
        
        let art = gallery[indexPath.row]
        cell.imageView.image = UIImage(named: art.imageName!)
        cell.titleLabel.text = art.title!
        
        return cell
    }
    
    
    // MARK: Collection View Layout Delegate Methods
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width - 80, height: collectionView.bounds.size.height - 40)
    }
}

