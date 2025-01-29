// The Swift Programming Language
//
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

    public func processTextAsync(_ text: String) async -> String {
        // 1차 비속어 탐지
        let detectedWords = await searchForProfanity(in: text)
        var resultText = text
        
        for word in detectedWords {
            if let range = resultText.range(of: word) {
                delegate?.didDetectProfanity(word, range: range)
                let replacement = String(repeating: "*", count: word.count)
                resultText.replaceSubrange(range, with: replacement)
            }
        }

        // 2차 정규 표현식으로 비속어 탐지 및 비식별화
        return await filterUsingRegex(text: resultText)
    }
    
    // 비속어탐지
    private func searchForProfanity(in text: String) async -> [String] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let detectedWords = self.ahoCorasick.search(in: text)
                continuation.resume(returning: detectedWords)
            }
        }
    }

    // 정규 표현식 비속어 필터링 비동기 처리
    private func filterUsingRegex(text: String) async -> String {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var filteredText = text

                for pattern in self.profanityRegexPatterns {
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

                continuation.resume(returning: filteredText)
            }
        }
    }
}
