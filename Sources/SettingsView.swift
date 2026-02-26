import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    @State private var username = ""
    @State private var password = ""
    @State private var intervalMinutes = 5

    private let intervals = [1, 2, 5, 10, 15, 30, 60]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            GroupBox("Credentials") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Username")
                            .frame(width: 110, alignment: .trailing)
                        TextField("your_username", text: $username)
                            .textContentType(.username)
                    }
                    HStack {
                        Text("App Password")
                            .frame(width: 110, alignment: .trailing)
                        SecureField("xxxx xxxx xxxx xxxx xxxx xxxx", text: $password)
                    }
                    Text("Generate at creativeapplications.net › Edit Profile › App Password")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 118)
                }
                .padding(8)
            }

            GroupBox("Polling") {
                HStack {
                    Text("Refresh every")
                        .frame(width: 110, alignment: .trailing)
                    Picker("", selection: $intervalMinutes) {
                        ForEach(intervals, id: \.self) { n in
                            Text(n == 1 ? "1 minute" : "\(n) minutes").tag(n)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 120)
                }
                .padding(8)
            }

            HStack {
                Spacer()
                Button("Save") {
                    appState.applySettings(
                        username: username,
                        password: password,
                        intervalMinutes: intervalMinutes
                    )
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(20)
        .frame(width: 400)
        .onAppear {
            username = appState.username
            password = appState.appPassword
            intervalMinutes = appState.refreshIntervalMinutes
        }
    }
}
