import Foundation

class TimeToTextConverter {
    func convertTimeToText(_ date: Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}