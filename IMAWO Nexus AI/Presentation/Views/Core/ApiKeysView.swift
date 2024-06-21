import SwiftUI
import TipKit

struct APIKeysView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.apiKeyValue)]) var apiKeys: FetchedResults<ApiKeys>
    
    @State private var key = ""
    
    struct ApiKeyTip: Tip {
        var title: Text {
            Text("Enter your API key")
        }
        
        var message: Text? {
            Text("Just paste or enter your API key and press 'return' to save it.")
        }
        
        var image: Image? {
            Image(systemName: "key.icloud")
        }
    }
    
    var apiKeyTip = ApiKeyTip()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: UIColor.quaternarySystemFill)
                    .ignoresSafeArea()
                
                VStack {
                    // ApiKeysHeaderView()
                    
                    Form {
                        addKeySection
                        apiKeysListSection
                        dismissButtonSection
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("API Keys")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(false)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private var addKeySection: some View {
        Section {
            TipView(apiKeyTip)
            
            TextField("Enter your API Key and press 'return'", text: $key)
                .onSubmit {
                    saveKey()
                }
            
            Text("Important! An API key is required for OpenAI integration:")
            Text("https://platform.openai.com/account/api-keys")
            
        } header: {
            Text("ADD A NEW API KEY")
        }
    }
    
    @ViewBuilder
    private var apiKeysListSection: some View {
        Section {
            List {
                ForEach(apiKeys, id: \.id) { apiKey in
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "key.icloud")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(.bottom, -4)
                            .foregroundColor(.green)
                        
                        Text("\(apiKey.apiKey ?? "NO API KEY")")
                    }
                }
                .onDelete(perform: deleteKey)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden)
            .frame(minHeight: 80)
            .padding(.top, -40)
        } header: {
            Text("YOUR API KEYS")
        }
    }
    
    @ViewBuilder
    private var dismissButtonSection: some View {
        Section {
            Button("Dismiss") {
                dismiss()
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    func saveKey() {
        let apiKey = IMAWO_Nexus_AI.ApiKeys(context: viewContext)
        apiKey.id = UUID()
        apiKey.apiKey = key
        
        do {
            try viewContext.save()
            key = ""
        } catch {
            // Handle error
            print("Failed to save API key: \(error.localizedDescription)")
        }
    }
    
    func deleteKey(at offsets: IndexSet) {
        for offset in offsets {
            let key = apiKeys[offset]
            viewContext.delete(key)
        }
        
        do {
            try viewContext.save()
        } catch {
            // Handle error
            print("Failed to delete API key: \(error.localizedDescription)")
        }
    }
}

struct ApiKeysHeaderView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .leading, endPoint: .trailing)
            .frame(width: 60, height: 60, alignment: .center)
            .mask(
                Image(systemName: "key.horizontal")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            )
            .padding(.top, 0)
            .padding(.bottom, 0)
    }
}

struct APIKeysViewPreviews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        return APIKeysView().environment(\.managedObjectContext, context)
    }
}
