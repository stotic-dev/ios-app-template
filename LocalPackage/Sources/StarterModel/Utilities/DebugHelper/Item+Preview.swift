//
//  Item+Preview.swift
//  StarterModel
//

/// プレビュー・テスト用のデータ。#Previewから参照するのでpublicにする（.claude/rules/prefire-preview.md）
public extension Item {

    static func makeForPreview(id: String = "preview-item", name: String = "りんご") -> Item {
        .init(name: name, id: id)
    }

    static let previewList: [Item] = [
        .makeForPreview(id: "1", name: "りんご"),
        .makeForPreview(id: "2", name: "みかん"),
        .makeForPreview(id: "3", name: "ぶどう"),
    ]

}
