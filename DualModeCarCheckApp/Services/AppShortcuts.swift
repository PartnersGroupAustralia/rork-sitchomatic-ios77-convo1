import AppIntents
import SwiftUI

struct CheckStatsIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Stats"
    static var description: IntentDescription = "View current card and credential statistics"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let stats = await MainActor.run {
            StatsTrackingService.shared
        }
        let tested = await MainActor.run { stats.lifetimeTested }
        let working = await MainActor.run { stats.lifetimeWorking }
        let dead = await MainActor.run { stats.lifetimeDead }
        let rate = await MainActor.run { stats.lifetimeSuccessRate }

        let message = "Lifetime: \(tested) tested, \(working) working, \(dead) dead. Success rate: \(String(format: "%.0f%%", rate * 100))."
        return .result(dialog: "\(message)")
    }
}

struct OpenPPSRModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Open PPSR Mode"
    static var description: IntentDescription = "Open the PPSR card testing mode"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            UserDefaults.standard.set("ppsr", forKey: "activeAppMode")
        }
        return .result()
    }
}

struct OpenJoeModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Joe Mode"
    static var description: IntentDescription = "Open the Joe Fortune login testing mode"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            UserDefaults.standard.set("joe", forKey: "activeAppMode")
        }
        return .result()
    }
}

struct OpenIgnitionModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Ignition Mode"
    static var description: IntentDescription = "Open the Ignition Casino login testing mode"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            UserDefaults.standard.set("ignition", forKey: "activeAppMode")
        }
        return .result()
    }
}

struct OpenNordConfigIntent: AppIntent {
    static var title: LocalizedStringResource = "Open NordLynx Config"
    static var description: IntentDescription = "Open the NordLynx VPN config generator"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            UserDefaults.standard.set("nordConfig", forKey: "activeAppMode")
        }
        return .result()
    }
}

struct DualModeAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CheckStatsIntent(),
            phrases: [
                "Check stats in \(.applicationName)",
                "Show \(.applicationName) statistics"
            ],
            shortTitle: "Check Stats",
            systemImageName: "chart.bar.fill"
        )
        AppShortcut(
            intent: OpenPPSRModeIntent(),
            phrases: [
                "Open PPSR in \(.applicationName)",
                "Start PPSR mode in \(.applicationName)"
            ],
            shortTitle: "Open PPSR",
            systemImageName: "bolt.shield.fill"
        )
        AppShortcut(
            intent: OpenJoeModeIntent(),
            phrases: [
                "Open Joe mode in \(.applicationName)"
            ],
            shortTitle: "Open Joe",
            systemImageName: "flame.fill"
        )
        AppShortcut(
            intent: OpenNordConfigIntent(),
            phrases: [
                "Open NordLynx in \(.applicationName)"
            ],
            shortTitle: "NordLynx Config",
            systemImageName: "network"
        )
    }
}
