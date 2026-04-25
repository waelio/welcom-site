import Foundation

public struct WebsiteRequestAttachment: Codable, Hashable {
    public let fileName: String
    public let contentType: String
    public let storageRef: String

    public init(fileName: String, contentType: String, storageRef: String) {
        self.fileName = fileName
        self.contentType = contentType
        self.storageRef = storageRef
    }
}

public struct WebsiteRequestRecord: Codable, Hashable {
    public let requestId: String
    public let createdAt: String
    public let source: String
    public let fullName: String
    public let topic: String
    public let summary: String
    public let additionalNotes: String
    public let status: String
    public let attachments: [WebsiteRequestAttachment]

    public init(
        requestId: String,
        createdAt: String,
        source: String,
        fullName: String,
        topic: String,
        summary: String,
        additionalNotes: String,
        status: String,
        attachments: [WebsiteRequestAttachment]
    ) {
        self.requestId = requestId
        self.createdAt = createdAt
        self.source = source
        self.fullName = fullName
        self.topic = topic
        self.summary = summary
        self.additionalNotes = additionalNotes
        self.status = status
        self.attachments = attachments
    }
}

public struct RequestFormDraft: Hashable {
    public var fullName: String
    public var topic: String
    public var summary: String
    public var supportingDocumentNamesLine: String
    public var additionalNotes: String
    public var hasConsent: Bool

    public init(
        fullName: String = "",
        topic: String = "",
        summary: String = "",
        supportingDocumentNamesLine: String = "",
        additionalNotes: String = "",
        hasConsent: Bool = false
    ) {
        self.fullName = fullName
        self.topic = topic
        self.summary = summary
        self.supportingDocumentNamesLine = supportingDocumentNamesLine
        self.additionalNotes = additionalNotes
        self.hasConsent = hasConsent
    }

    public var canGenerate: Bool {
        !trimmed(fullName).isEmpty
            && !trimmed(topic).isEmpty
            && !trimmed(summary).isEmpty
            && hasConsent
    }

    public var supportingDocumentNames: [String] {
        supportingDocumentNamesLine
            .split(whereSeparator: { $0 == "," || $0.isNewline })
            .map { trimmed(String($0)) }
            .filter { !$0.isEmpty }
    }

    public func generatedRecord(
        requestId: String = UUID().uuidString,
        createdAt: Date = Date()
    ) -> WebsiteRequestRecord? {
        guard canGenerate else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let attachments = supportingDocumentNames.map { name in
            WebsiteRequestAttachment(
                fileName: name,
                contentType: Self.inferContentType(for: name),
                storageRef: "pending-upload/\(Self.sanitizedStorageComponent(from: name))"
            )
        }

        return WebsiteRequestRecord(
            requestId: requestId,
            createdAt: formatter.string(from: createdAt),
            source: "welcomtalk-portal",
            fullName: trimmed(fullName),
            topic: trimmed(topic),
            summary: trimmed(summary),
            additionalNotes: trimmed(additionalNotes),
            status: "submitted",
            attachments: attachments
        )
    }

    public func generatedJSONPreview(
        requestId: String = UUID().uuidString,
        createdAt: Date = Date()
    ) -> String? {
        guard let record = generatedRecord(requestId: requestId, createdAt: createdAt) else {
            return nil
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(record) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func inferContentType(for fileName: String) -> String {
        let ext = fileName.split(separator: ".").last?.lowercased() ?? ""

        switch ext {
        case "pdf":
            return "application/pdf"
        case "png":
            return "image/png"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "txt":
            return "text/plain"
        default:
            return "application/octet-stream"
        }
    }

    private static func sanitizedStorageComponent(from fileName: String) -> String {
        let trimmed = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmed.lowercased()
        let pieces = lowered.split { character in
            !(character.isLetter || character.isNumber || character == "." || character == "-" || character == "_")
        }

        let joined = pieces.joined(separator: "-")
        return joined.isEmpty ? "attachment" : joined
    }
}
