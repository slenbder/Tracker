//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 18.09.2024.
//

import Foundation

final class CategoryViewModel {
    
    // MARK: - Properties
    
    private let trackerCategoryStore: TrackerCategoryStore
    private var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesChanged?(categories)
        }
    }
    
    var onCategoriesChanged: (([TrackerCategory]) -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    
    // MARK: - Initializer
    
    init(store: TrackerCategoryStore) {
        self.trackerCategoryStore = store
        self.trackerCategoryStore.delegate = self
        loadCategories()
    }
    
    // MARK: - Public Methods
    
    func loadCategories() {
        categories = trackerCategoryStore.fetchAllCategories().compactMap {
            trackerCategoryStore.decodingCategory(from: $0)
        }
    }
    
    func addCategory(title: String) {
        let newCategory = TrackerCategory(title: title, trackers: [])
        trackerCategoryStore.createCategory(newCategory)
        categories.append(newCategory)
    }
    
    func numberOfCategories() -> Int {
        return categories.count
    }
    
    func category(at index: Int) -> TrackerCategory {
        return categories[index]
    }
    
    func selectCategory(at index: Int) {
        let selectedCategory = categories[index]
        onCategorySelected?(selectedCategory)
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdateData(in store: TrackerCategoryStore) {
        loadCategories()
    }
}
