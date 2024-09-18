//
//  Ahocorasick.swift
//  SwiftyCorasick
//
//  Created by 권민재 on 9/17/24.
//

class TrieNode {
    var children: [Character: TrieNode] = [:]
    var isEndOfWord: Bool = false
    var failureLink: TrieNode?
    var outputLink: TrieNode?

    init() {}

}

class AhoCorasick {
    
    private let root = TrieNode()
    
    func buildTrie(with keywords: [String]) {
        for keyword in keywords {
            insert(keyword: keyword)
        }
        buildFailureLinks()
    }
    
    
    
    private func insert(keyword: String) {
        var currentNode = root
        for char in keyword {
            if currentNode.children[char] == nil {
                currentNode.children[char] = TrieNode()
            }
            currentNode = currentNode.children[char]!
        }
        currentNode.isEndOfWord = true
    }

    
    
    private func buildFailureLinks() {
        var queue: [TrieNode] = []
        
        for child in root.children.values {
            child.failureLink = root
            queue.append(child)
        }
        
        while !queue.isEmpty {
            let currentNode = queue.removeFirst()
            
            for (char, childNode) in currentNode.children {
                var failure = currentNode.failureLink
                
                while failure != nil && failure?.children[char] == nil {
                    failure = failure?.failureLink
                }
                if let failure = failure {
                    childNode.failureLink = failure.children[char]
                } else {
                    childNode.failureLink = root
                }
                if childNode.failureLink?.isEndOfWord == true {
                    childNode.outputLink = childNode.failureLink
                } else {
                    childNode.outputLink = childNode.failureLink?.outputLink
                }
                queue.append(childNode)
            }
        }
    }
    
    func search(in text: String) -> [String] {
        var result: [String] = []
        var currentNode = root

        for char in text {
            while currentNode.children[char] == nil && currentNode !== root {
                currentNode = currentNode.failureLink!
            }

            if let nextNode = currentNode.children[char] {
                currentNode = nextNode

                var outputNode: TrieNode? = currentNode
                while outputNode != nil {
                    if outputNode!.isEndOfWord {
                        result.append("욕설 감지")
                    }
                    outputNode = outputNode?.outputLink
                }
            
            }
        }
        
        return result
    }
}
