import SwiftUI
import TipKit

struct AnalyzedTextView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.apiKeyValue)]) var apiKeys: FetchedResults<ApiKeys>
    
    @State private var showingCopyAnalyzedText = false
    @State private var apiKey: String?
    
    @ObservedObject var openAIViewModel: OpenAIViewModel
    
    var analyzedTextOptionsTip = AnalyzedTextOptionsTip()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: UIColor.quaternarySystemFill)
                    .ignoresSafeArea()
                
                VStack {
                    // AnalyzedTextHeaderView()
                    
                    Form {
                        analysisSection
                        dismissButtonSection
                    }
                    .scrollContentBackground(.hidden)
                }
                .task {
                    await Utilities.analyzeText(openAIViewModel: openAIViewModel, apiKey: apiKeys.first?.apiKey ?? "")
                }
            }
            .navigationTitle("Text analysis")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(false)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private var analysisSection: some View {
        Section {
            ScrollView {
                if let decodedResponse = openAIViewModel.decodedResponse {
                    Text(decodedResponse.text)
                        .padding([.top, .bottom], 0)
                        .fontWeight(.light)
                        .onTapGesture {
                            showingCopyAnalyzedText = true
                        }
                        .confirmationDialog("Select an option", isPresented: $showingCopyAnalyzedText) {
                            Button("Copy text to clipboard") {
                                Utilities.shared.copyToClipboard(decodedResponse.text)
                            }
                            .keyboardShortcut(.defaultAction)
                            
                            Button("Cancel", role: .cancel) {}
                        }
                } else {
                    Text("Nothing")
                        .padding([.top, .bottom], 0)
                        .fontWeight(.light)
                }
            }
            .padding(.top, 8)
            
            TipView(analyzedTextOptionsTip)
        } header: {
            Text("YOUR ANALYSIS")
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
}

struct AnalyzedTextHeaderView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .leading, endPoint: .trailing)
            .frame(width: 60, height: 60, alignment: .center)
            .mask(
                Image(systemName: "doc.text.below.ecg")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            )
            .padding(.top, 20)
            .padding(.bottom, 0)
    }
}

struct AnalyzedTextView_Previews: PreviewProvider {
    static var openAIViewModel = OpenAIViewModel()

    static var previews: some View {
        AnalyzedTextView(openAIViewModel: openAIViewModel)
    }
}
