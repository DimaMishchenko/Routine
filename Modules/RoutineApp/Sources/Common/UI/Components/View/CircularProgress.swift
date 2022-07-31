import UIKit

final class CircularProgressView: UIView {
  // MARK: - Constants
  private enum Constans {
    static let lineWidth: CGFloat = 6
  }
  
  // MARK: - Properties
  var animationDuration: TimeInterval = 0.3
  var progressBackgroundColor: UIColor? {
    get { backgroundLayer.strokeColor.flatMap { UIColor(cgColor: $0) } }
    set { backgroundLayer.strokeColor = newValue?.cgColor }
  }
  
//  private(set) var progress: CGFloat = .zero
  
  // MARK: - UI Properties
  private lazy var backgroundLayer = createBackground()
  private lazy var primaryProgress = createProgress(colors: Color.Gradient.primary)
  private lazy var secondaryProgress = createProgress(colors: Color.Gradient.secondary)
  private var gradients: [CAGradientLayer] = []

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  @available(*, unavailable, message: "Not supported")
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  // MARK: - Override
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let path = createCirclePath()
    
    backgroundLayer.path = path.cgPath
    primaryProgress.path = path.cgPath
    secondaryProgress.path = path.cgPath
    
    gradients.forEach { $0.frame = bounds }
  }
  
  // MARK: - Public
  func update(progress: CGFloat, animated: Bool, completion: @escaping () -> Void) {
    CATransaction.begin()
    CATransaction.setDisableActions(!animated)
    CATransaction.setCompletionBlock { completion() }
    
    let current = (primary: primaryProgress.strokeEnd, secondary: secondaryProgress.strokeEnd)
    let values = strokeValues(from: progress)
    
    CATransaction.setDisableActions(true)
    primaryProgress.strokeEnd = values.primary
    secondaryProgress.strokeEnd = values.secondary
    CATransaction.setDisableActions(false)
    
    if animated {
      let primaryAnimation = progressAnimation(with: current.primary)
      let secondaryAnimation = progressAnimation(with: current.secondary)
      
      primaryProgress.add(primaryAnimation, forKey: "primary")
      secondaryProgress.add(secondaryAnimation, forKey: "secondary")
    }
    
    CATransaction.commit()
  }
  
  private func strokeValues(from progress: CGFloat) -> (primary: CGFloat, secondary: CGFloat) {
    switch progress {
    case 0:
      return (.zero, .zero)
    case 0...1:
      return (progress, .zero)
    case 1...2:
      return (1, progress - 1)
    default:
      return (1, 1)
    }
  }
  
  // MARK: - Private
  private func progressAnimation(with current: CGFloat) -> CABasicAnimation {
    with(CABasicAnimation(keyPath: NSExpression(forKeyPath: \CAShapeLayer.strokeEnd).keyPath)) {
      $0.fromValue = current
      $0.fillMode = .forwards
      $0.duration = animationDuration
      $0.isRemovedOnCompletion = false
    }
  }
  
  private func setupUI() {
    _ = backgroundLayer
  }
  
  private func createCirclePath() -> UIBezierPath {
    UIBezierPath(
      arcCenter: CGPoint(
        x: frame.size.width / 2,
        y: frame.size.height / 2
      ),
      radius: (frame.size.width / 2) - (Constans.lineWidth / 2),
      startAngle: -.pi / 2,
      endAngle: 3 * .pi / 2,
      clockwise: true
    )
  }
  
  private func createBackground() -> CAShapeLayer {
    with(CAShapeLayer()) {
      $0.fillColor = Color.clear.cgColor
      $0.lineCap = .round
      $0.lineWidth = Constans.lineWidth
      layer.addSublayer($0)
    }
  }
                       
  private func createProgress(colors: [UIColor?]) -> CAShapeLayer {
    let progress = with(CAShapeLayer()) {
      $0.fillColor = Color.clear.cgColor
      $0.lineCap = .butt
      $0.lineWidth = Constans.lineWidth
      $0.strokeEnd = .zero
      $0.strokeColor = Color.black.cgColor
      
      layer.addSublayer($0)
    }
    
    with(CAGradientLayer()) {
      $0.colors = colors.compactMap { $0?.cgColor }
      $0.locations = [0, 1]
      $0.startPoint = CGPoint(x: 0.5, y: 0)
      $0.endPoint = CGPoint(x: 0.5, y: 1)
      $0.mask = progress
      layer.addSublayer($0)
      
      gradients.append($0)
    }
    
    return progress
  }
}
