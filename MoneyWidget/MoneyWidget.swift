//
//  MoneyWidget.swift
//  MoneyWidget
//
//  Created by dani on 11/15/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

    let title = "Daily Makeable:"
    let moneyMakeable = "$\(24.0 * Double(18-9))" // TODO: use vars. later: use minutes

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: title, moneyMakeable: moneyMakeable)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), title: title, moneyMakeable: moneyMakeable)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, title: title, moneyMakeable: moneyMakeable)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
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
