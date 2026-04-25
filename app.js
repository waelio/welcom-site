const STATIC_SHELL_MESSAGE = "WelcomTalk Portal static shell loaded. The SwiftWasm bundle is not built in this checkout yet, so the HTML fallback is being served.";
const AUTHENTICATE_JASON_PRESET = {
    fullName: "Jordan Smith",
    topic: "Repair dispute",
    summary: "Scan with my iPhone to start the session.",
    additionalNotes: "",
};
const AUTHENTICATE_JASON_PORTAL_PAYLOAD = "welcomtalk://portal-start?n=Jordan%20Smith&t=Repair%20dispute&s=Scan%20with%20my%20iPhone%20to%20start%20the%20session.";
const AUTHENTICATE_JASON_QR_ROWS = [
    "00000000000000000000000000000000000000000000000000000000000",
    "01111111001101100111010001110111011001011101010110011111110",
    "01000001000001110011011111101110010001100110111010010000010",
    "01011101011001011001110101101000110001100001111110010111010",
    "01011101010001100110000100100001100010001110110010010111010",
    "01011101001000010101000000111111100110111001110010010111010",
    "01000001000000001111100111010001100001110110000100010000010",
    "01111111010101010101010101010101010101010101010101011111110",
    "00000000000011011001101111110001111111001101000010000000000",
    "00001101101011011100000011011111100101010100001010000011000",
    "00100100011010001001011000101100101100111101110111110111100",
    "01111101111000110101010110101100011000001100110101000001010",
    "00000100110000001010000100011101000100110000111000100001000",
    "01011111110100000001100111011100100100000110010001110100010",
    "01000010011111100011010000101001011000110001111011011011100",
    "00010111010010100001001101001100010000110100101011110101000",
    "01000110111100001011110101110001001101100001101010110011000",
    "00010001100110001000101110101010111101000011010010110010000",
    "01011010100011111000011001000110011110001001011101100101010",
    "00001111100000011100011111011111101101000010110001001001010",
    "00001100010000111010000011100000110001100101101001011101110",
    "00111101001000000010000011110010011101101110000100111100100",
    "00010110100001111100101101110001000111010011110101110001100",
    "01000001111101010011101101000100100111001100010110101011110",
    "00101100011000000000010001010010110111000011110000001001000",
    "00100001011010000101101001010100100010000100110110101100110",
    "01010110111110101011010100011001010011011011011001111011000",
    "01111111110011010110111101111111010001011010000001111110100",
    "00011100011001100100010111010001110011111010110101000111000",
    "01010101010111001111001000010101011010100011110101010100010",
    "00101100010100111100000111110001111011101101001101000100010",
    "01110111110111100100110001011111011111101110111011111100010",
    "00011000111101100101001110001110101011000101100110001011100",
    "00100001100001110110000001100000100110010100000100101010010",
    "00011110001010101100100110101000000100110111010111010110100",
    "01001101111101001011000010101100001011001000111110110000110",
    "00111110010001010011010101111011010100101000011101111101100",
    "00000101111000001000100110011001011001111101010110011000100",
    "01010000110011100010011000110011011101110111110000011010000",
    "00000111110000000001011110110011101101111100000001101011000",
    "00001100011001010000101000010001001000100001000110000111010",
    "01110011101101101011101111100000111000000011111011101101010",
    "00111110110010000110000110110110011100000101111110001101110",
    "01111101011001111001011100010100100110100110110011011011010",
    "00010100010100000010000111011100010011011111001110100011100",
    "00010101111110110101100101111100001011000111100101100000000",
    "00100000111110001110000000001001000111011101001101111100010",
    "01010011000011011000011101110101011011101100010110111111110",
    "01111100001101001111011010000010101100111010110101010111100",
    "00000001111010111001011001011111001110101101110011111110000",
    "00000000010001001110100001110001101100110011011011000111000",
    "01111111011100111100100010110101010000100111000011010111000",
    "01000001000101001100010000010001110110001011000101000101100",
    "01011101011110011101000001111111111001101011111111111100100",
    "01011101011111110110000101011101101011011001110110000001000",
    "01011101000100001001011001111001101110001010110001010111110",
    "01000001000010001000001011100011111000010101100001011111110",
    "01111111000110000001100001111101110000110110101001110100000",
    "00000000000000000000000000000000000000000000000000000000000",
];
if (typeof window !== "undefined") {
    window.__WELCOM_STATIC_SHELL__ = true;
    console.info(STATIC_SHELL_MESSAGE);
}
const inferContentType = (file) => {
    if (file.type) {
        return file.type;
    }
    const ext = (file.name.split(".").pop() || "").toLowerCase();
    const map = {
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
const storageComponent = (value) => {
    const safe = value
        .trim()
        .toLowerCase()
        .replace(/[^a-z0-9._-]+/g, "-")
        .replace(/^-+|-+$/g, "");
    return safe || "attachment";
};
const renderQRCodeMarkup = (rows) => {
    const size = rows.length;
    const rects = [];
    rows.forEach((row, rowIndex) => {
        let x = 0;
        const y = size - rowIndex - 1;
        while (x < row.length) {
            if (row.charCodeAt(x) !== 49) {
                x += 1;
                continue;
            }
            const runStart = x;
            while (x < row.length && row.charCodeAt(x) === 49) {
                x += 1;
            }
            rects.push(`<rect x="${runStart}" y="${y}" width="${x - runStart}" height="1" fill="black"/>`);
        }
    });
    return [
        `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${size} ${size}" shape-rendering="crispEdges" role="img" aria-label="Portal start barcode">`,
        "<rect width=\"100%\" height=\"100%\" fill=\"white\"/>",
        ...rects,
        "</svg>",
    ].join("");
};
const setupRequestBuilder = () => {
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
    const authenticateJasonButton = document.getElementById("authenticate-jason");
    const statusLine = document.getElementById("request-json-status");
    const output = document.getElementById("request-json-output");
    const barcodeCard = document.getElementById("portal-start-card");
    const barcodeFrame = document.getElementById("portal-start-barcode");
    const barcodeCaption = document.getElementById("portal-start-caption");
    if (!(fullName instanceof HTMLInputElement) ||
        !(topic instanceof HTMLInputElement) ||
        !(summary instanceof HTMLTextAreaElement) ||
        !(documents instanceof HTMLInputElement) ||
        !(notes instanceof HTMLTextAreaElement) ||
        !(consent instanceof HTMLInputElement) ||
        !(generateButton instanceof HTMLButtonElement) ||
        !(copyButton instanceof HTMLButtonElement) ||
        !(downloadButton instanceof HTMLButtonElement) ||
        !(authenticateJasonButton instanceof HTMLButtonElement) ||
        !(statusLine instanceof HTMLParagraphElement) ||
        !(output instanceof HTMLPreElement) ||
        !(barcodeCard instanceof HTMLDivElement) ||
        !(barcodeFrame instanceof HTMLDivElement) ||
        !(barcodeCaption instanceof HTMLParagraphElement)) {
        return;
    }
    let latestJSON = "";
    const hideBarcodeCard = () => {
        barcodeCard.hidden = true;
        barcodeFrame.replaceChildren();
        barcodeCaption.textContent = "";
    };
    const showBarcodeCard = () => {
        barcodeCard.hidden = false;
        barcodeFrame.innerHTML = renderQRCodeMarkup(AUTHENTICATE_JASON_QR_ROWS);
        barcodeCaption.textContent =
            "Jordan Smith · Repair dispute · Scan this in WelcomTalk to start the session.";
    };
    const writeRecordPreview = (record, successMessage) => {
        latestJSON = JSON.stringify(record, null, 2);
        output.textContent = latestJSON;
        statusLine.textContent = successMessage;
    };
    const buildRecord = () => {
        const trimmedName = fullName.value.trim();
        const trimmedTopic = topic.value.trim();
        const trimmedSummary = summary.value.trim();
        if (!trimmedName ||
            !trimmedTopic ||
            !trimmedSummary ||
            !consent.checked) {
            statusLine.textContent =
                "Fill in full name, topic, request summary, and consent before generating JSON.";
            return null;
        }
        const files = Array.from(documents.files || []);
        const requestId = globalThis.crypto && typeof globalThis.crypto.randomUUID === "function"
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
            hideBarcodeCard();
            return;
        }
        writeRecordPreview(record, "JSON generated locally in WelcomTalk Portal.");
        hideBarcodeCard();
    });
    authenticateJasonButton.addEventListener("click", () => {
        fullName.value = AUTHENTICATE_JASON_PRESET.fullName;
        topic.value = AUTHENTICATE_JASON_PRESET.topic;
        summary.value = AUTHENTICATE_JASON_PRESET.summary;
        notes.value = AUTHENTICATE_JASON_PRESET.additionalNotes;
        documents.value = "";
        consent.checked = true;
        const record = buildRecord();
        if (!record) {
            latestJSON = "";
            output.textContent = "JSON preview appears here after generation.";
            hideBarcodeCard();
            return;
        }
        writeRecordPreview(record, "Jason is ready. Scan the barcode in WelcomTalk on your iPhone to start the session.");
        showBarcodeCard();
        const clipboardWrite = navigator.clipboard?.writeText(AUTHENTICATE_JASON_PORTAL_PAYLOAD);
        void clipboardWrite?.catch(() => undefined);
    });
    copyButton.addEventListener("click", async () => {
        if (!latestJSON) {
            statusLine.textContent = "Generate the JSON first, then copy it.";
            return;
        }
        try {
            await navigator.clipboard.writeText(latestJSON);
            statusLine.textContent = "JSON copied to the clipboard.";
        }
        catch {
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
export {};
