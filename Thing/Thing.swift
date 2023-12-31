//
//  Thing.swift
//  Thing
//
//  Created by dani on 3/13/23.
//  Copyright © 2024 Daniel Springer. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entries: [SimpleEntry] = [SimpleEntry(date: Date())]

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct ThingEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text("How Much Can YOU Make Today?")
            .fontWeight(.heavy)
            .multilineTextAlignment(.center)
            .foregroundColor(.green)
            .padding(.all)
    }
}

struct Thing: Widget {
    let kind: String = "Thing"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ThingEntryView(entry: entry)
        }
        .configurationDisplayName("Motivator")
        .description("Motivate yourself with a Home Screen Widget.")
    }
}

struct Thing_Previews: PreviewProvider {
    static var previews: some View {
        ThingEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
