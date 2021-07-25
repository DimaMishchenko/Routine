import PinLayout
import UIKit

final class SettingsView: UIView {
  // MARK: - Private Properties
  private var initialLayout = Once()
  
  // MARK: - UI Properties
  private lazy var tableView = createTableView()
  private lazy var dataSource = createDataSource()
  
  // MARK: - Override
  override func layoutSubviews() {
    super.layoutSubviews()
    initialLayout.once { setupUI() }
    updateLayout()
  }
}

// MARK: - Public
extension SettingsView {
  func update(with snapshot: Snapshot<Settings.Section, Settings.Row>) {
    dataSource.apply(snapshot)
  }
}

// MARK: - UITableViewDelegate
extension SettingsView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    dataSource.row(at: indexPath).action?()
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: - Private
extension SettingsView {
  private func setupUI() {
    backgroundColor = Color.Background.default
  }
  
  private func updateLayout() {
    tableView.pin.all()
  }
  
  private func createDataSource() -> TableDataSource<Settings.Section, Settings.Row> {
    let dataSource = TableDataSource<Settings.Section, Settings.Row>(
      tableView: tableView
    ) { tableView, indexPath, row -> UITableViewCell? in
      switch row.type {
      case .disclousre(let viewModel):
        return tableView.dequeue(ValueCell.self, with: viewModel, for: indexPath)
      }
    }
    
    dataSource.titleForHeader = { $0.title }
    
    return dataSource
  }
  
  private func createTableView() -> UITableView {
    with(UITableView(frame: .zero, style: .insetGrouped)) {
      $0.delegate = self
      $0.register(ValueCell.self)
      addSubview($0)
    }
  }
}
