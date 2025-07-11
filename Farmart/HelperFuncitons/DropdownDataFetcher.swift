import Foundation
import Combine

class SuggestionViewModel: ObservableObject {
    @Published var query = ""
    @Published var suggestions: [String] = []

    private var cancellables = Set<AnyCancellable>()
    private let category: String

    init(category: String) {
        self.category = category

        $query
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.fetchSuggestions(for: searchText)
            }
            .store(in: &cancellables)
    }

    private func fetchSuggestions(for query: String) {
        guard !query.isEmpty,
              let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://localhost:3000/search/\(category)/\(encodedQuery)") else {
            DispatchQueue.main.async {
                self.suggestions = []
            }
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
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
