import UIKit

// MARK: - Constants

private extension CGSize {
    static var cellSize: CGSize { return .init(width: 39, height: 24) }
}

private extension String {
    static var cellIdentifier: String { return "Input.Table.ImageViewCell" }
}

// MARK: -

extension Input.Table {
    class ImagesCollectionViewController: NSObject {
        var dataSource = [UIImage]()

        func registerCells(for collectionView: UICollectionView) {
            collectionView.register(Input.Table.ImageViewCell.self, forCellWithReuseIdentifier: .cellIdentifier)
        }
    }
}

extension Input.Table.ImagesCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .cellIdentifier, for: indexPath) as! Input.Table.ImageViewCell
        cell.imageView.image = dataSource[indexPath.row]
        return cell
    }
}

extension Input.Table.ImagesCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .cellSize
    }
}
