import Foundation

/// Height and weight, always stored metric. Ranges only reject typing mistakes; they are not clinical limits.
public enum BodyMeasures {
    public static let heightCm: ClosedRange<Double> = 120...220
    public static let weightKg: ClosedRange<Double> = 35...250

    public static func centimetres(feet: Double, inches: Double) -> Double { (feet * 12 + inches) * 2.54 }

    public static func kilograms(pounds: Double) -> Double { pounds * 0.453_592_37 }

    public static func isPlausible(heightCm height: Double, weightKg weight: Double) -> Bool {
        heightCm.contains(height) && weightKg.contains(weight)
    }
}
