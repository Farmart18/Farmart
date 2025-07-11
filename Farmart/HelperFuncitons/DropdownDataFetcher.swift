import Foundation
import Combine

class FertilizerViewModel: ObservableObject {
    @Published var query = ""
    @Published var suggestions: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                self.fetchSuggestions(for: searchText)
            }
            .store(in: &cancellables)
    }

    func fetchSuggestions(for query: String) {
        guard !query.isEmpty,
              let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://localhost:3000/search/fertilizer/\(encodedQuery)") else {
            self.suggestions = []
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let list = try? JSONDecoder().decode([String].self, from: data) else {
                DispatchQueue.main.async {
                    self.suggestions = []
                }
                return
            }

            DispatchQueue.main.async {
                self.suggestions = list
            }
        }.resume()
    }
}
