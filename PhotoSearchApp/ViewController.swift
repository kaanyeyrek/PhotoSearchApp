//
//  ViewController.swift
//  PhotoSearchApp
//
//  Created by Kaan Yeyrek on 8/8/22.
//

import UIKit


//MARK: - API Model

struct APIResponse: Codable {
    let total: Int
    let total_pages: Int
    let results: [Result]
    
    
    
}

struct Result: Codable {
    let id: String
    let urls: URLS
    
    
    
}

struct URLS: Codable {
    let regular: String
}







class ViewController: UIViewController {


    
    private var collectionView: UICollectionView?
    
    let searchbar = UISearchBar()
    
    var results: [Result] = []
   
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
       
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        self.collectionView = collectionView
        
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.Identifier)
       
        collectionView.dataSource = self
        searchbar.delegate = self
        
 
        
        view.addSubview(searchbar)
        view.addSubview(collectionView)
        
    }
//MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchbar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.frame.size.width, height: view.frame.size.height-55)
    }
    
 
    
    
//MARK: - API Request
    
    func fetchPhotos(query: String) {
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=50&query=\(query)&client_id=STtdgEcS87hwK1bA5xJW5GmDMKTdNFg0zp2azG0PY6Y"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
           
                    self?.results = jsonResult.results
                    self?.collectionView?.reloadData()
                }
                
            } catch {
                
                print(error)
                
            }
            
            
        }
        task.resume()
    }
    
    
}
//MARK: - CollectionView Methods

    extension ViewController: UICollectionViewDataSource {
        
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return results.count
        }
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let imageURLString = results[indexPath.row].urls.regular
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.Identifier, for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(with: imageURLString)
            return cell
        }
        
        
        
    }

    


//MARK: - SearchBar Methods

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.resignFirstResponder()
        if let text = searchbar.text {
            results = []
            collectionView?.reloadData()
            
            fetchPhotos(query: text)
        }
    }
    
    
    
}
