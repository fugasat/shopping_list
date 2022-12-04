import SwiftUI
import AppIntents

struct ItemInputView: View {
    @State private var item = ""

    var body: some View {
        VStack {
            Spacer()
            Text("品物を入力").padding()
            Spacer()
            TextField("品物", text: $item)
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ItemInputView()
    }
}

struct OpenItemInputIntent: AppIntent {
    static let title: LocalizedStringResource = "品物を入力"
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let manager = ItemManager.sharedManager
        manager.notifyItemInputRequest()

//        return .result(view:ItemInputView())
        return .result()
    }
}

