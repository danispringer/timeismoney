//
//  MoneyWidget.swift
//  MoneyWidget
//
//  Created by dani on 11/15/22.
//

import WidgetKit
import SwiftUI
// swiftlint:disable:next identifier_name
let UD: UserDefaults = UserDefaults(suiteName: "io.danispringer.github.money")!

struct Provider: TimelineProvider {

    let title = "Daily Makeable:"

    func placeholder(in context: Context) -> SimpleEntry {
        let moneyMakeable = updateMoneyMakeableString(seconds: fetchWorkHours())
        return SimpleEntry(date: Date(), title: title, moneyMakeable: moneyMakeable)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let moneyMakeable = updateMoneyMakeableString(seconds: fetchWorkHours())
        let entry = SimpleEntry(date: Date(), title: title, moneyMakeable: moneyMakeable)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let moneyMakeable = updateMoneyMakeableString(seconds: fetchWorkHours())
            let entry = SimpleEntry(date: entryDate, title: title, moneyMakeable: moneyMakeable)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

func fetchWorkHours() -> Double {
    let startTimeString: String = UD.string(forKey: Const.UDef.startTime)!
    let endTimeString: String = UD.string(forKey: Const.UDef.endTime)!

    let startTimeH = startTimeString.prefix(2)
    let startTimeM = startTimeString.suffix(2)
    let endTimeH = endTimeString.prefix(2)
    let endTimeM = endTimeString.suffix(2)
    let startTimeHourInt: Int = Int(startTimeH)!
    let startTimeMinInt: Int = Int(startTimeM)!
    let endTimeHourInt: Int = Int(endTimeH)!
    let endTimeMinInt: Int = Int(endTimeM)!

    let now = Date()

    let calendar = Calendar.current
    let startTime = calendar.date(bySettingHour: startTimeHourInt, minute: startTimeMinInt, second: 0, of: now)!
    let endTime = calendar.date(bySettingHour: endTimeHourInt, minute: endTimeMinInt, second: 0, of: now)!
    let secsBetweenStartAndEndTime = endTime
        .timeIntervalSince1970 - startTime.timeIntervalSince1970
    return secsBetweenStartAndEndTime
}


func updateMoneyMakeableString(seconds: Double) -> String {
    let numberFormatterCurrency = NumberFormatter()
    numberFormatterCurrency.numberStyle = .currency
    numberFormatterCurrency.roundingMode = .down
    let hourlyRate = UD.double(forKey: Const.UDef.hourlyRate)
    let moneyLeft: Double = hourlyRate * seconds / 3600.0
    let moneyLeftFormatted = numberFormatterCurrency.string(from: moneyLeft as NSNumber)
    return "\(moneyLeftFormatted!)"
}

struct Const {
    struct UDef {
        static let hourlyRate = "hourlyRate"
        static let startTime = "startTime"
        static let endTime = "endTime"
    }
}


struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let moneyMakeable: String
}

struct MoneyWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.title).multilineTextAlignment(.center)
        Text(entry.moneyMakeable).foregroundColor(.green).font(.title).bold()
    }
}

struct MoneyWidget: Widget {
    let kind: String = "MoneyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MoneyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Money Widget")
        .description("How much money can you make in a day?")
    }
}

struct MoneyWidget_Previews: PreviewProvider {
    static var previews: some View {
        let title = "Daily Makeable:"
        let moneyMakeable = "fixme2"
        MoneyWidgetEntryView(entry: SimpleEntry(date: Date(), title: title, moneyMakeable: moneyMakeable))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
