import XCTest
@testable import SwiftyCorasick

final class SwiftyCorasickTests: XCTestCase {
    
    override func setUpWithError() throws {
        // 각 테스트 시작 전에 설정 작업을 할 수 있습니다.
        SwiftyCorasick.shared.bindKeywords(["씨발", "개새끼", "병신"]) // 비속어 키워드 추가
    }
    
    override func tearDownWithError() throws {
        // 각 테스트가 종료된 후 정리 작업을 할 수 있습니다.
    }
    
    @available(iOS 16.0, *)
    func testProfanityDetectionPerformance() async throws {
        let baseSentence = "이건 정말 씨발 같은 상황이다. 그리고 개새끼가 날 째려본다. "
        let testText = String(repeating: baseSentence, count: 200)
        
        measure {
            // 비속어 처리 성능을 측정하기 위해 Swift Concurrency의 async/await 사용
            Task {
                let maskedText = await SwiftyCorasick.shared.processTextAsync(testText)
                
                // 텍스트 필터링이 끝난 후 결과를 확인하는 예시
                XCTAssertFalse(maskedText.contains("씨발"))
                XCTAssertFalse(maskedText.contains("개새끼"))
                XCTAssertFalse(maskedText.contains("병신"))
            }
        }
    }
}
