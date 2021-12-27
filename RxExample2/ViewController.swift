//
//  ViewController.swift
//  RxExample
//
//  Created by KJS on 2021/12/23.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var searchBar: UISearchBar!
    var cityTableView: UITableView!
    let disposeBag = DisposeBag()
    
    var shownCities = [String]()
    let allCities = ["New York", "NewMan", "London", "Oslo", "Warsaw", "Berlin", "Praga"] // 고정된 API 데이터

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchBar = UISearchBar(frame: .zero)
        cityTableView = UITableView(frame: .zero)
        
        cityTableView.dataSource = self
        cityTableView.delegate = self
        cityTableView.register(CityPrototypeCell.self, forCellReuseIdentifier: "cell")
        
        /// UI addSubview
        view.addSubview(searchBar)
        view.addSubview(cityTableView)
        
        /// UI setting constraints
        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(40)
        }
        cityTableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        searchBar
            .rx.text // RxCocoa의 Observable 속성
            .orEmpty // 옵셔널이 아니도록 만듭니다.
            .distinctUntilChanged() // 새로운 값이 이전의 값과 같은지 확인합니다.
            .filter { !$0.isEmpty } // 새로운 값이 정말 새롭다면, 비어있지 않은 쿼리를 위해 필터링합니다.
            .subscribe(onNext: { [unowned self] query in // Here we subscribe to every new value, that is not empty (thanks to filter above).
                self.shownCities = self.allCities.filter { $0.hasPrefix(query) } // 도시를 찾기 위한 “API 요청” 작업을 합니다.
                self.cityTableView.reloadData() // 테이블 뷰를 다시 불러옵니다.
            })
            .disposed(by: disposeBag)
        
        searchBar
            .rx.text
            .filter { $0 == "" }
            .subscribe(onNext: { [weak self] _ in
                self?.shownCities = []
                self?.cityTableView.reloadData()
            }).disposed(by: disposeBag)
        
        cityTableView.rx.itemSelected
          .subscribe(onNext: { [weak self] indexPath in
//            let cell = self?.cityTableView.cellForRow(at: indexPath) as? CityPrototypeCell
//            cell.button.isEnabled = false
            let detailVC = DetailViewController()
            detailVC.titleLabel?.text = "test"
            self?.navigationController?.pushViewController(detailVC, animated: true)
          }).disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CityPrototypeCell
        cell.textLabel?.text = shownCities[indexPath.row]

        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let detailVC = DetailViewController()
//        detailVC.titleLabel?.text = "test"
//        detailVC.titleLabel?.text = "\(indexPath)"
//        navigationController?.pushViewController(detailVC, animated: true)
//        present(detailVC, animated: true, completion: nil)
//    }
    
}

