//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Ashish Jaiswal on 06/08/23.
//

import UIKit

public struct CellController {
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefecting: UITableViewDataSourcePrefetching?
    
    public init(_ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
        self.dataSource = dataSource
        self.delegate = dataSource
        self.dataSourcePrefecting = dataSource
    }
    
    public init(_ dataSource: UITableViewDataSource) {
        self.dataSource = dataSource
        self.delegate = nil
        self.dataSourcePrefecting = nil
    }
}
