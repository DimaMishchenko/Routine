import UIKit

extension UITableView {
  // MARK: - Public
  func register(_ cellClass: AnyClass) {
    register(cellClass.self, forCellReuseIdentifier: identifier(for: cellClass.self))
  }
  
  func dequeue<Cell: UITableViewCell & ModelConfigurable>(
    _ type: Cell.Type,
    with model: Cell.Model,
    for indexPath: IndexPath
  ) -> Cell? {
    guard let cell = dequeueReusableCell(withIdentifier: identifier(for: Cell.self), for: indexPath) as? Cell else {
      // TODO: - use `os_log`
      print("Failed to cast reuse cell to \(Cell.self)")
      return nil
    }
    
    cell.update(with: model)
    
    return cell
  }
  
  // MARK: - Private
  private func identifier(for cellClass: AnyClass) -> String {
    String(describing: cellClass.self)
  }
}
