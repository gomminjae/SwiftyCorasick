// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
@available(iOS 16, *)
protocol SwiftyCorasickBindable {
    func bindKeywords(_ keywords: [String])
}

protocol SwiftyCorasickDelegate: AnyObject {
    func didDetectProfanity(_ word: String, range: Range<String.Index>)
}

protocol SwiftyCorasickFetchable {
    func fetchKeywords() -> [String]
}
open class SwiftyCorasick: @unchecked Sendable {
    public static let shared = SwiftyCorasick()
    private let ahoCorasick = AhoCorasick()
    private var keywords: [String] = []

    private let profanityRegexPatterns = [
        "씨[0-9ㅣl!]*발", "시[0-9ㅣl!]*발", "개[0-9ㅣl!]*새[0-9ㅣl!]*끼", "병[0-9ㅣl!]*신"
    ]

    weak var delegate: SwiftyCorasickDelegate?

    private init() {}

    public func bindKeywords(_ keywords: [String]) {
        self.keywords = keywords
        ahoCorasick.buildTrie(with: keywords)
    }

    public func processTextAsync(_ text: String, completion: @Sendable @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            // 1차: 기본 비속어 탐지
            let detectedWords = self.ahoCorasick.search(in: text)
            var resultText = text

            DispatchQueue.main.async {
                for word in detectedWords {
                    if let range = resultText.range(of: word) {
                        self.delegate?.didDetectProfanity(word, range: range)
                        let replacement = String(repeating: "*", count: word.count)
                        resultText.replaceSubrange(range, with: replacement)
                    }
                }

                // 2차: 정규 표현식을 사용한 추가 비속어 탐지
                resultText = self.filterUsingRegex(text: resultText)

                
                completion(resultText)
            }
        }
    }
    
    // 정규 표현식을 이용한 비속어 탐지 및 비식별화
    private func filterUsingRegex(text: String) -> String {
        var filteredText = text
        
        for pattern in profanityRegexPatterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                let matches = regex.matches(in: filteredText, options: [], range: NSRange(location: 0, length: filteredText.utf16.count))
                
                for match in matches.reversed() {
                    let matchRange = match.range
                    if let range = Range(matchRange, in: filteredText) {
                        let word = String(filteredText[range])
                        let replacement = String(repeating: "*", count: word.count)
                        filteredText.replaceSubrange(range, with: replacement)
                    }
                }
            } catch {
                print("정규 표현식 오류: \(error)")
            }
        }
        
        return filteredText
    }
}
