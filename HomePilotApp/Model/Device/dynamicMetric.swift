//
//  dynamicMetric.swift
//  HomePilotApp
//
//  Created by Helin Güler on 21.12.2024.
//

import UIKit

class DynamicMetricView: UIView {
    private let nameLabel = UILabel()
    private let textField = UITextField()

    init(metric: DeviceMetric) {
        super.init(frame: .zero)
        setupView(metric: metric)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(metric: DeviceMetric) {
        nameLabel.text = metric.name
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        textField.placeholder = metric.placeholder
        textField.borderStyle = .roundedRect
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, textField])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
