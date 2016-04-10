//
//  ViewController.swift
//  Gallery
//
//  Created by Dulio Denis on 4/5/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import UIKit
import CoreData
import StoreKit


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var gallery = [Art]()
    var products = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        updateGallery()
        
        if gallery.count == 0 {
            createArt("Mona Lisa", imageName: "mona-lisa.jpg", productIdentifier: "", purchased: true)
            createArt("The Starry Night", imageName: "starry-night.jpg", productIdentifier: "StarryNight", purchased: false)
            createArt("The Scream", imageName: "the-scream.jpg", productIdentifier: "Scream", purchased: false)
            createArt("The Persistence of Memory", imageName: "the-persistence-of-memory-1931.jpg", productIdentifier: "PersistenceOfMemory", purchased: false)
            updateGallery()
            collectionView.reloadData()
        }
        
        requestProductsForSale()
    }
    
    
    // MARK: IAP Functions / StoreKit Delegate Methods
    
    func requestProductsForSale() {
        let ids: Set<String> = ["StarryNight", "Scream", "PersistenceOfMemory"]
        let productsRequest = SKProductsRequest(productIdentifiers: ids)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("Received requested products")
        print("Products Ready: \(response.products.count)")
        print("Invalid Products: \(response.invalidProductIdentifiers.count)")
        
        for product in response.products {
            print("Product: \(product.productIdentifier), Price: \(product.price)")
        }
        
        products = response.products
        collectionView.reloadData()
    }
    
    
    // MARK: Payment Transaction Observer Delegate Method
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Purchase Made.")
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
        
        for subview in cell.imageView.subviews {
            subview.removeFromSuperview()
        }
        
        if art.purchased!.boolValue {
            cell.purchaseLabel.hidden = true
        } else {
            cell.purchaseLabel.hidden = false
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            cell.layoutIfNeeded()
            blurView.frame = cell.imageView.bounds
            cell.imageView.addSubview(blurView)
            
            // Tie Store Product to Gallery Item
            for product in products {
                if product.productIdentifier == art.productIdentifier {
                    // Show Local Currency for IAP
                    let formatter = NSNumberFormatter()
                    formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
                    formatter.locale = product.priceLocale
                    if let price = formatter.stringFromNumber(product.price) {
                        cell.purchaseLabel.text = "Buy for \(price)"
                    }
                }
            }
        }
        
        return cell
    }
    
    
    // When the user taps an item in the collection view that hasn't been purchased - add the product to the payment queue
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let art = gallery[indexPath.row]
        if !art.purchased!.boolValue {
            for product in products {
                if product.productIdentifier == art.productIdentifier {
                    SKPaymentQueue.defaultQueue().addTransactionObserver(self)
                    let payment = SKPayment(product: product)
                    SKPaymentQueue.defaultQueue().addPayment(payment)
                }
            }
        }
    }
    
    
    // MARK: Collection View Layout Delegate Methods
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width - 80, height: collectionView.bounds.size.height - 40)
    }
}

