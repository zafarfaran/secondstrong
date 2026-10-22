import Foundation

/// A deliberately light check: the link we send is the real proof the address works.
public enum EmailAddress {
    public static func normalised(_ text: String) -> String? {
        let email = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty, !email.contains(" "),
              let dot = parts[1].lastIndex(of: "."),
              dot != parts[1].startIndex, parts[1].index(after: dot) != parts[1].endIndex
        else { return nil }
        return email
    }
}
