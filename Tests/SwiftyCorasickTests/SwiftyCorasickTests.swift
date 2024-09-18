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
    func testProfanityDetection() async throws {
        // 비속어가 포함된 테스트 문장
        let testText = "이건 정말 씨발 같은 상황이다. 그리고 개새끼가 날 째려본다."
        
        // 기대하는 비속어가 마스킹된 결과
        let expectedText = "이건 정말 ** 같은 상황이다. 그리고 ***가 날 째려본다."
        
        // XCTest 비동기 처리를 위한 expectation 생성
        let expectation = XCTestExpectation(description: "Async Profanity Detection")
        
        var resultText: String?
        
        SwiftyCorasick.shared.processTextAsync(testText) { maskedText in
            DispatchQueue.main.async {
                resultText = maskedText
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        guard let resultText = resultText else {
            XCTFail("비속어 탐지 결과가 없습니다.")
            return
        }
        
        // 결과 비교
        XCTAssertEqual(resultText, expectedText, "비속어가 올바르게 마스킹되지 않았습니다.")
    }
}
