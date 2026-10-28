import AppKit
import CoreText
import CryptoKit
import Foundation

struct Configuration: Decodable {
  struct Device: Decodable {
    let name: String
    let directory: String?
    let suffix: String?
    let overrides: [String: String]?
    let inputs: [String: [String: String]]?
  }
  let devices: [Device]
  let locales: [String]?
}

struct Card: Encodable {
  let device, locale, screen, source, sourceSHA256, output, outputSHA256: String
  let sourcePixelSHA256, outputPixelSHA256: String
  let width, height: Int
  let strings, stringsSHA256, titleKey, subtitleKey, title, subtitle: String
  let titleSize, subtitleSize: CGFloat
}

struct MissingInput: Encodable {
  let device, locale, screen, reason: String
}

struct Manifest: Encodable {
  let generatedAt, renderer, rendererSHA256: String
  let cards: [Card]
  let missing: [MissingInput]
}

struct Failure: Error, CustomStringConvertible {
  let description: String
  init(_ description: String) { self.description = description }
}

let fileManager = FileManager.default
let root = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let arguments = Array(CommandLine.arguments.dropFirst())
let allowedOptions = ["--config", "--output", "--locales", "--devices"]
if arguments.contains("--help") {
  print("Usage: store-screenshots [--config Screenshots/inputs.json] [--output .artifacts/modernization/store-package] [--locales en,ja] [--devices iphone,ipad]")
  exit(0)
}
guard arguments.count.isMultiple(of: 2) else { throw Failure("Options require values; use --help") }
var options: [String: String] = [:]
for index in stride(from: 0, to: arguments.count, by: 2) {
  guard allowedOptions.contains(arguments[index]) else { throw Failure("Unknown option \(arguments[index])") }
  options[arguments[index]] = arguments[index + 1]
}

func url(_ path: String) -> URL {
  URL(fileURLWithPath: path, relativeTo: root).standardizedFileURL
}

func relative(_ value: URL) -> String {
  value.path.hasPrefix(root.path + "/") ? String(value.path.dropFirst(root.path.count + 1)) : value.path
}

func hash(_ data: Data) -> String {
  SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

func pixelHash(_ data: Data) throws -> String {
  guard let image = NSBitmapImageRep(data: data)?.cgImage,
        let pixels = NSMutableData(length: image.width * image.height * 4),
        let context = CGContext(data: pixels.mutableBytes, width: image.width, height: image.height,
                                bitsPerComponent: 8, bytesPerRow: image.width * 4,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
  else { throw Failure("Cannot decode canonical RGBA pixels") }
  context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
  return hash(pixels as Data)
}

func hasQAMarkedContent(_ source: URL) throws -> Bool {
  let stem = source.deletingPathExtension().path
  for path in [stem + ".ax.json", stem + "-ax.json"] where fileManager.fileExists(atPath: path) {
    let object = try JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: path)))
    func containsQA(_ value: Any) -> Bool {
      if let array = value as? [Any] { return array.contains(where: containsQA) }
      guard let dictionary = value as? [String: Any] else { return false }
      for key in ["AXLabel", "AXValue"] {
        if let text = dictionary[key] as? String,
           text.range(of: #"\bQA\b"#, options: [.regularExpression, .caseInsensitive]) != nil { return true }
      }
      return dictionary.values.contains(where: containsQA)
    }
    if containsQA(object) { return true }
  }
  return false
}

func validateGlyphs(_ value: NSAttributedString) throws {
  let line = CTLineCreateWithAttributedString(value)
  for run in CTLineGetGlyphRuns(line) as NSArray {
    let glyphRun = run as! CTRun
    var glyphs = Array(repeating: CGGlyph(), count: CTRunGetGlyphCount(glyphRun))
    CTRunGetGlyphs(glyphRun, CFRange(location: 0, length: 0), &glyphs)
    guard !glyphs.contains(0) else { throw Failure("Missing native font glyph in: \(value.string)") }
  }
}

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1) -> NSColor {
  NSColor(srgbRed: red, green: green, blue: blue, alpha: alpha)
}

func attributes(size: CGFloat, weight: NSFont.Weight, textColor: NSColor) -> [NSAttributedString.Key: Any] {
  let base = NSFont.systemFont(ofSize: size, weight: weight)
  let font = base.fontDescriptor.withDesign(.rounded).flatMap { NSFont(descriptor: $0, size: size) } ?? base
  let paragraph = NSMutableParagraphStyle()
  paragraph.alignment = .center
  paragraph.lineBreakMode = .byWordWrapping
  paragraph.lineSpacing = size * 0.08
  return [.font: font, .foregroundColor: textColor, .paragraphStyle: paragraph]
}

func fit(_ text: String, width: CGFloat, maximumHeight: CGFloat, startingSize: CGFloat,
         weight: NSFont.Weight, textColor: NSColor) throws -> (NSAttributedString, CGFloat, CGFloat) {
  var size = startingSize
  while size >= startingSize * 0.48 {
    let value = NSAttributedString(string: text, attributes: attributes(size: size, weight: weight, textColor: textColor))
    let bounds = value.boundingRect(with: NSSize(width: width, height: .greatestFiniteMagnitude),
                                    options: [.usesLineFragmentOrigin, .usesFontLeading])
    if ceil(bounds.height) <= maximumHeight && ceil(bounds.width) <= width + 1 {
      try validateGlyphs(value)
      return (value, size, ceil(bounds.height))
    }
    size -= 2
  }
  throw Failure("Localized text cannot fit without becoming too small: \(text)")
}

func render(image: NSImage, width: Int, height: Int, title: String, subtitle: String) throws -> (Data, CGFloat, CGFloat) {
  guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
                                     bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                     colorSpaceName: .deviceRGB, bytesPerRow: width * 4, bitsPerPixel: 32),
        let context = NSGraphicsContext(bitmapImageRep: bitmap) else { throw Failure("Cannot create image canvas") }
  NSGraphicsContext.saveGraphicsState()
  defer { NSGraphicsContext.restoreGraphicsState() }
  let graphics = context.cgContext
  graphics.translateBy(x: 0, y: CGFloat(height))
  graphics.scaleBy(x: 1, y: -1)
  NSGraphicsContext.current = NSGraphicsContext(cgContext: graphics, flipped: true)
  graphics.interpolationQuality = .high
  let canvas = NSRect(x: 0, y: 0, width: width, height: height)
  let gradient = NSGradient(starting: .white, ending: color(0.91, 0.95, 1))
  gradient?.draw(in: canvas, angle: 90)

  let margin = CGFloat(width) * 0.045
  let headerHeight = CGFloat(height) * 0.18
  let textWidth = CGFloat(width) - margin * 2
  let titleFit = try fit(title, width: textWidth, maximumHeight: headerHeight * 0.49,
                         startingSize: min(CGFloat(width) * 0.078, headerHeight * 0.41), weight: .bold, textColor: color(0.035, 0.11, 0.22))
  let subtitleFit = try fit(subtitle, width: textWidth, maximumHeight: headerHeight * 0.32,
                            startingSize: min(CGFloat(width) * 0.033, headerHeight * 0.18), weight: .medium, textColor: color(0.27, 0.35, 0.46))
  let gap = CGFloat(width) * 0.014
  let totalTextHeight = titleFit.2 + subtitleFit.2 + gap
  let textTop = max(CGFloat(height) * 0.022, (headerHeight - totalTextHeight) / 2)
  titleFit.0.draw(with: NSRect(x: margin, y: textTop, width: textWidth, height: titleFit.2 + 2),
                  options: [.usesLineFragmentOrigin, .usesFontLeading])
  subtitleFit.0.draw(with: NSRect(x: margin, y: textTop + titleFit.2 + gap, width: textWidth, height: subtitleFit.2 + 2),
                     options: [.usesLineFragmentOrigin, .usesFontLeading])

  let frame = NSRect(x: margin, y: headerHeight + CGFloat(width) * 0.012,
                     width: CGFloat(width) - margin * 2,
                     height: CGFloat(height) - headerHeight - margin - CGFloat(width) * 0.012)
  let radius = CGFloat(width) * 0.045
  graphics.saveGState()
  graphics.setShadow(offset: CGSize(width: 0, height: CGFloat(width) * 0.012), blur: CGFloat(width) * 0.025,
                     color: color(0.05, 0.2, 0.45, alpha: 0.14).cgColor)
  color(0.77, 0.87, 1).setFill()
  NSBezierPath(roundedRect: frame, xRadius: radius, yRadius: radius).fill()
  graphics.restoreGState()
  let available = frame.insetBy(dx: CGFloat(width) * 0.008, dy: CGFloat(width) * 0.008)
  let scale = min(available.width / CGFloat(width), available.height / CGFloat(height))
  let imageRect = NSRect(x: available.midX - CGFloat(width) * scale / 2,
                         y: available.midY - CGFloat(height) * scale / 2,
                         width: CGFloat(width) * scale, height: CGFloat(height) * scale)
  graphics.saveGState()
  NSBezierPath(roundedRect: imageRect, xRadius: radius * 0.75, yRadius: radius * 0.75).addClip()
  image.draw(in: imageRect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true,
             hints: [.interpolation: NSImageInterpolation.high])
  graphics.restoreGState()
  guard let rendered = bitmap.cgImage,
        let opaque = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                               bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
                               bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
    throw Failure("Cannot create opaque export")
  }
  opaque.draw(rendered, in: CGRect(x: 0, y: 0, width: width, height: height))
  guard let flattened = opaque.makeImage(),
        let data = NSBitmapImageRep(cgImage: flattened).representation(using: .png, properties: [:]) else {
    throw Failure("Cannot encode opaque PNG")
  }
  return (data, titleFit.1, subtitleFit.1)
}

let configURL = url(options["--config"] ?? "Screenshots/inputs.json")
let configuration = try JSONDecoder().decode(Configuration.self, from: Data(contentsOf: configURL))
let localizationRoot = url("Modules/RoutineApp/Resources/Localization")
let discoveredLocales = try fileManager.contentsOfDirectory(at: localizationRoot, includingPropertiesForKeys: nil)
  .filter { $0.pathExtension == "lproj" }.map { $0.deletingPathExtension().lastPathComponent }.sorted()
let locales = options["--locales"]?.split(separator: ",").map(String.init) ?? configuration.locales ?? discoveredLocales
let deviceFilter = options["--devices"]?.split(separator: ",").map(String.init)
let devices = configuration.devices.filter { deviceFilter == nil || deviceFilter?.contains($0.name) == true }
guard !devices.isEmpty, !locales.isEmpty else { throw Failure("No devices or locales selected") }
let destination = url(options["--output"] ?? ".artifacts/modernization/store-package")
try fileManager.createDirectory(at: destination, withIntermediateDirectories: true)
let screenKeys = [
  ("home", "tutorial.features.maintain.title", "tutorial.features.maintain.message"),
  ("settings", "freeAnnouncement.title", "freeAnnouncement.features"),
  ("announcement", "settings.section.authors", "settings.section.authorsFooter")
]
var cards: [Card] = []
var missing: [MissingInput] = []
func markMissing(device: String, locale: String, screen: String, reason: String) throws {
  for item in screen == "all" ? screenKeys.map({ $0.0 }) : [screen] {
    let stale = destination.appendingPathComponent(device + "/" + locale + "/" + item + ".png")
    if fileManager.fileExists(atPath: stale.path) { try fileManager.removeItem(at: stale) }
  }
  missing.append(.init(device: device, locale: locale, screen: screen, reason: reason))
}
for device in devices {
  for locale in locales {
    let stringsURL = localizationRoot.appendingPathComponent(locale + ".lproj/Localizable.strings")
    guard fileManager.fileExists(atPath: stringsURL.path) else {
      try markMissing(device: device.name, locale: locale, screen: "all", reason: "Missing locale resource")
      continue
    }
    let stringsData = try Data(contentsOf: stringsURL)
    guard let strings = try PropertyListSerialization.propertyList(from: stringsData, format: nil) as? [String: String] else {
      throw Failure("Invalid strings file \(relative(stringsURL))")
    }
    for (screen, titleKey, subtitleKey) in screenKeys {
      guard let title = strings[titleKey], !title.isEmpty, let subtitle = strings[subtitleKey], !subtitle.isEmpty else {
        try markMissing(device: device.name, locale: locale, screen: screen, reason: "Missing localized header keys")
        continue
      }
      let directory = device.overrides?[locale] ?? device.directory
      let path = device.inputs?[locale]?[screen] ?? directory.map { $0 + "/" + locale + "-" + screen + (device.suffix ?? "") + ".png" }
      guard let path, !path.contains("blocked"), !path.contains("QA"), fileManager.fileExists(atPath: url(path).path) else {
        try markMissing(device: device.name, locale: locale, screen: screen, reason: "Validated native PNG unavailable")
        continue
      }
      let sourceURL = url(path)
      if try hasQAMarkedContent(sourceURL) {
        try markMissing(device: device.name, locale: locale, screen: screen, reason: "Native AX contains QA-marked user content")
        continue
      }
      let sourceData = try Data(contentsOf: sourceURL)
      guard let representation = NSBitmapImageRep(data: sourceData), let image = NSImage(data: sourceData) else {
        throw Failure("Invalid native image \(path)")
      }
      let width = representation.pixelsWide
      let height = representation.pixelsHigh
      let result = try render(image: image, width: width, height: height, title: title, subtitle: subtitle)
      let outputURL = destination.appendingPathComponent(device.name + "/" + locale + "/" + screen + ".png")
      try fileManager.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
      try result.0.write(to: outputURL, options: .atomic)
      cards.append(Card(device: device.name, locale: locale, screen: screen, source: relative(sourceURL),
                        sourceSHA256: hash(sourceData), output: relative(outputURL), outputSHA256: hash(result.0),
                        sourcePixelSHA256: try pixelHash(sourceData), outputPixelSHA256: try pixelHash(result.0),
                        width: width, height: height, strings: relative(stringsURL), stringsSHA256: hash(stringsData),
                        titleKey: titleKey, subtitleKey: subtitleKey, title: title, subtitle: subtitle,
                        titleSize: result.1, subtitleSize: result.2))
      print("Rendered \(device.name)/\(locale)/\(screen) \(width)×\(height)")
    }
  }
}
let rendererURL = url("Tools/store-screenshots.swift")
let manifest = Manifest(generatedAt: ISO8601DateFormatter().string(from: Date()), renderer: relative(rendererURL),
                        rendererSHA256: hash(try Data(contentsOf: rendererURL)), cards: cards, missing: missing)
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
try encoder.encode(manifest).write(to: destination.appendingPathComponent("manifest.json"), options: .atomic)
print("Rendered \(cards.count) cards; \(missing.count) explicit missing inputs. Manifest: \(relative(destination))/manifest.json")
