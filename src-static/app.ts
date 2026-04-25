declare global {
    interface Window {
        __WELCOM_STATIC_SHELL__?: boolean;
    }
}

type WebsiteRequestAttachment = {
    fileName: string;
    contentType: string;
    storageRef: string;
};

type WebsiteRequestRecord = {
    requestId: string;
    createdAt: string;
    source: "welcomtalk-portal";
    fullName: string;
    topic: string;
    summary: string;
    additionalNotes: string;
    status: "submitted";
    attachments: WebsiteRequestAttachment[];
};

const STATIC_SHELL_MESSAGE =
    "WelcomTalk Portal static shell loaded. The SwiftWasm bundle is not built in this checkout yet, so the HTML fallback is being served.";

if (typeof window !== "undefined") {
    window.__WELCOM_STATIC_SHELL__ = true;
    console.info(STATIC_SHELL_MESSAGE);
}

const inferContentType = (file: File): string => {
    if (file.type) {
        return file.type;
    }

    const ext = (file.name.split(".").pop() || "").toLowerCase();
    const map: Record<string, string> = {
        pdf: "application/pdf",
        png: "image/png",
        jpg: "image/jpeg",
        jpeg: "image/jpeg",
        doc: "application/msword",
        docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        txt: "text/plain",
    };

    return map[ext] || "application/octet-stream";
};

const storageComponent = (value: string): string => {
    const safe = value
        .trim()
        .toLowerCase()
        .replace(/[^a-z0-9._-]+/g, "-")
        .replace(/^-+|-+$/g, "");

    return safe || "attachment";
};

const setupRequestBuilder = (): void => {
    if (typeof document === "undefined") {
        return;
    }

    const fullName = document.getElementById("request-full-name");
    const topic = document.getElementById("request-topic");
    const summary = document.getElementById("request-summary");
    const documents = document.getElementById("request-documents");
    const notes = document.getElementById("request-notes");
    const consent = document.getElementById("request-consent");
    const generateButton = document.getElementById("generate-request-json");
    const copyButton = document.getElementById("copy-request-json");
    const downloadButton = document.getElementById("download-request-json");
    const statusLine = document.getElementById("request-json-status");
    const output = document.getElementById("request-json-output");

    if (
        !(fullName instanceof HTMLInputElement) ||
        !(topic instanceof HTMLInputElement) ||
        !(summary instanceof HTMLTextAreaElement) ||
        !(documents instanceof HTMLInputElement) ||
        !(notes instanceof HTMLTextAreaElement) ||
        !(consent instanceof HTMLInputElement) ||
        !(generateButton instanceof HTMLButtonElement) ||
        !(copyButton instanceof HTMLButtonElement) ||
        !(downloadButton instanceof HTMLButtonElement) ||
        !(statusLine instanceof HTMLParagraphElement) ||
        !(output instanceof HTMLPreElement)
    ) {
        return;
    }

    let latestJSON = "";

    const buildRecord = (): WebsiteRequestRecord | null => {
        const trimmedName = fullName.value.trim();
        const trimmedTopic = topic.value.trim();
        const trimmedSummary = summary.value.trim();

        if (
            !trimmedName ||
            !trimmedTopic ||
            !trimmedSummary ||
            !consent.checked
        ) {
            statusLine.textContent =
                "Fill in full name, topic, request summary, and consent before generating JSON.";
            return null;
        }

        const files = Array.from(documents.files || []);
        const requestId =
            globalThis.crypto && typeof globalThis.crypto.randomUUID === "function"
                ? globalThis.crypto.randomUUID()
                : `request-${Date.now()}`;

        return {
            requestId,
            createdAt: new Date().toISOString(),
            source: "welcomtalk-portal",
            fullName: trimmedName,
            topic: trimmedTopic,
            summary: trimmedSummary,
            additionalNotes: notes.value.trim(),
            status: "submitted",
            attachments: files.map((file) => ({
                fileName: file.name,
                contentType: inferContentType(file),
                storageRef: `pending-upload/${storageComponent(file.name)}`,
            })),
        };
    };

    generateButton.addEventListener("click", () => {
        const record = buildRecord();
        if (!record) {
            latestJSON = "";
            output.textContent = "JSON preview appears here after generation.";
            return;
        }

        latestJSON = JSON.stringify(record, null, 2);
        output.textContent = latestJSON;
        statusLine.textContent = "JSON generated locally in WelcomTalk Portal.";
    });

    copyButton.addEventListener("click", async () => {
        if (!latestJSON) {
            statusLine.textContent = "Generate the JSON first, then copy it.";
            return;
        }

        try {
            await navigator.clipboard.writeText(latestJSON);
            statusLine.textContent = "JSON copied to the clipboard.";
        } catch {
            statusLine.textContent =
                "Clipboard access is not available here, but the JSON preview is ready to copy manually.";
        }
    });

    downloadButton.addEventListener("click", () => {
        if (!latestJSON) {
            statusLine.textContent = "Generate the JSON first, then download it.";
            return;
        }

        const blob = new Blob([latestJSON], { type: "application/json" });
        const url = URL.createObjectURL(blob);
        const anchor = document.createElement("a");
        anchor.href = url;
        anchor.download = "welcomtalk-portal-request.json";
        anchor.click();
        URL.revokeObjectURL(url);
        statusLine.textContent = "JSON downloaded from WelcomTalk Portal.";
    });
};

setupRequestBuilder();

export { };
