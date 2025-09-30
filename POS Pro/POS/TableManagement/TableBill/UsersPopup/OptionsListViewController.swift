//
//  Untitled.swift
//  pos
//
//  Created by DGTERA on 28/10/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

class OptionsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var options: [[String: Any]] = []
    var onSelectOption: (([String: Any]) -> Void)?

    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }

    // MARK: - UITableViewDataSource and Delegate Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
        let option = options[indexPath.row]
        cell.textLabel?.text = option["name"] as? String ?? "Unknown Option"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = options[indexPath.row]
        onSelectOption?(selectedOption)
        dismiss(animated: true, completion: nil)
    }
}
