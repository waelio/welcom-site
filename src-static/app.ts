import QRCode from "qrcode";

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

type AuthenticateJasonPreset = {
    fullName: string;
    topic: string;
    summary: string;
    additionalNotes: string;
};

type PortalStartPayload = {
    requestId: string;
    fullName: string;
    topic: string;
    summary: string;
    additionalNotes: string;
};

const STATIC_SHELL_MESSAGE =
    "WelcomTalk Portal static shell loaded. The SwiftWasm bundle is not built in this checkout yet, so the HTML fallback is being served.";

const PORTAL_START_QUERY_FLAG = "portalStart";
const PORTAL_START_SCHEME = "welcomtalk://portal-start";
const DEFAULT_PORTAL_ORIGIN = "https://welcomeport.netlify.app/";
const AUTO_OPEN_SESSION_STORAGE_PREFIX = "welcomtalk-portal-start:auto-open:";

const AUTHENTICATE_JASON_PRESET: AuthenticateJasonPreset = {
    fullName: "Jordan Smith",
    topic: "Repair dispute",
    summary: "Scan with my iPhone to start the session.",
    additionalNotes: "",
};

if (typeof window !== "undefined") {
    window.__WELCOM_STATIC_SHELL__ = true;
    console.info(STATIC_SHELL_MESSAGE);
}

const resolvePortalOrigin = (): string => {
    if (typeof window !== "undefined" && window.location.origin) {
        return `${window.location.origin}/`;
    }

    return DEFAULT_PORTAL_ORIGIN;
};

const normalizePortalValue = (value: string): string =>
    value.trim();

const buildPortalStartPayload = (
    record: WebsiteRequestRecord,
): PortalStartPayload => ({
    requestId: record.requestId,
    fullName: normalizePortalValue(record.fullName),
    topic: normalizePortalValue(record.topic),
    summary: normalizePortalValue(record.summary),
    additionalNotes: normalizePortalValue(record.additionalNotes),
});

const portalQueryParams = (
    payload: PortalStartPayload,
    includeLandingFlag: boolean,
): URLSearchParams => {
    const params = new URLSearchParams();

    if (includeLandingFlag) {
        params.set(PORTAL_START_QUERY_FLAG, "1");
    }

    params.set("rid", payload.requestId);
    params.set("n", payload.fullName);
    params.set("t", payload.topic);
    params.set("s", payload.summary);

    if (payload.additionalNotes) {
        params.set("notes", payload.additionalNotes);
    }

    return params;
};

const customSchemeURLForPortalPayload = (
    payload: PortalStartPayload,
): string => `${PORTAL_START_SCHEME}?${portalQueryParams(payload, false).toString()}`;

const landingURLForPortalPayload = (
    payload: PortalStartPayload,
): string => {
    const landingURL = new URL("/", resolvePortalOrigin());
    landingURL.search = portalQueryParams(payload, true).toString();
    return landingURL.toString();
};

const caseInsensitiveQueryMap = (
    params: URLSearchParams,
): Map<string, string> => {
    const values = new Map<string, string>();

    for (const [key, value] of params.entries()) {
        values.set(key.toLowerCase(), value);
    }

    return values;
};

const queryValue = (
    values: Map<string, string>,
    ...keys: string[]
): string => {
    for (const key of keys) {
        const value = values.get(key.toLowerCase());
        if (value !== undefined) {
            return value;
        }
    }

    return "";
};

const isPortalStartLandingURL = (
    url: URL,
    queryValues: Map<string, string>,
): boolean => {
    const normalizedPath = url.pathname.replace(/^\/+|\/+$/g, "").toLowerCase();

    if (normalizedPath === "portal-start") {
        return true;
    }

    const flag = queryValue(queryValues, "portalstart", "portal-start").toLowerCase();
    return flag === "" || flag === "1" || flag === "true" || flag === "yes" || flag === "y";
};

const portalPayloadFromURL = (value: string): PortalStartPayload | null => {
    try {
        const url = new URL(value, resolvePortalOrigin());
        const queryValues = caseInsensitiveQueryMap(url.searchParams);

        if (!isPortalStartLandingURL(url, queryValues)) {
            return null;
        }

        const payload = {
            requestId:
                queryValue(queryValues, "rid", "requestid", "request_id") ||
                `request-${Date.now()}`,
            fullName: queryValue(queryValues, "n", "fullname", "full_name"),
            topic: queryValue(queryValues, "t", "topic"),
            summary: queryValue(queryValues, "s", "summary"),
            additionalNotes: queryValue(
                queryValues,
                "notes",
                "additionalnotes",
                "additional_notes",
            ),
        } satisfies PortalStartPayload;

        if (!payload.fullName || !payload.topic || !payload.summary) {
            return null;
        }

        return payload;
    } catch {
        return null;
    }
};

const copyText = async (value: string): Promise<boolean> => {
    if (!value) {
        return false;
    }

    try {
        await navigator.clipboard.writeText(value);
        return true;
    } catch {
        return false;
    }
};

const tryAutoOpenPortalLink = (customSchemeURL: string): void => {
    if (typeof window === "undefined") {
        return;
    }

    try {
        const storageKey = `${AUTO_OPEN_SESSION_STORAGE_PREFIX}${customSchemeURL}`;
        const existingValue = window.sessionStorage?.getItem(storageKey);

        if (existingValue === "1") {
            return;
        }

        window.sessionStorage?.setItem(storageKey, "1");
        window.setTimeout(() => {
            window.location.href = customSchemeURL;
        }, 250);
    } catch {
        window.setTimeout(() => {
            window.location.href = customSchemeURL;
        }, 250);
    }
};

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

const renderQRCodeMarkup = (rows: readonly string[]): string => {
    const size = rows.length;
    const rects: string[] = [];

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

            rects.push(
                `<rect x="${runStart}" y="${y}" width="${x - runStart}" height="1" fill="black"/>`,
            );
        }
    });

    return [
        `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${size} ${size}" shape-rendering="crispEdges" role="img" aria-label="Portal start barcode">`,
        "<rect width=\"100%\" height=\"100%\" fill=\"white\"/>",
        ...rects,
        "</svg>",
    ].join("");
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
    const authenticateJasonButton = document.getElementById("authenticate-jason");
    const statusLine = document.getElementById("request-json-status");
    const output = document.getElementById("request-json-output");
    const barcodeCard = document.getElementById("portal-start-card");
    const barcodeFrame = document.getElementById("portal-start-barcode");
    const barcodeCaption = document.getElementById("portal-start-caption");
    const barcodeOpenLink = document.getElementById("portal-start-open-link");
    const barcodeCopyLinkButton = document.getElementById("copy-portal-start-link");
    const barcodeLinkPreview = document.getElementById("portal-start-link-preview");
    const landingCard = document.getElementById("portal-start-landing");
    const landingMessage = document.getElementById("portal-start-landing-message");
    const landingOpenLink = document.getElementById("portal-start-landing-open-link");
    const landingCopyLinkButton = document.getElementById("portal-start-landing-copy-link");

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
        !(authenticateJasonButton instanceof HTMLButtonElement) ||
        !(statusLine instanceof HTMLParagraphElement) ||
        !(output instanceof HTMLPreElement) ||
        !(barcodeCard instanceof HTMLDivElement) ||
        !(barcodeFrame instanceof HTMLDivElement) ||
        !(barcodeCaption instanceof HTMLParagraphElement) ||
        !(barcodeOpenLink instanceof HTMLAnchorElement) ||
        !(barcodeCopyLinkButton instanceof HTMLButtonElement) ||
        !(barcodeLinkPreview instanceof HTMLParagraphElement)
    ) {
        return;
    }

    let latestJSON = "";
    let latestPortalStartLandingURL = "";
    let latestPortalStartAppURL = "";

    authenticateJasonButton.textContent = "Use demo request";

    const hideBarcodeCard = (): void => {
        barcodeCard.hidden = true;
        barcodeFrame.replaceChildren();
        barcodeCaption.textContent = "";
        barcodeOpenLink.href = "#";
        barcodeLinkPreview.textContent = "";
        latestPortalStartLandingURL = "";
        latestPortalStartAppURL = "";
    };

    const showLandingCardForIncomingPortalLink = (
        payload: PortalStartPayload,
    ): void => {
        if (
            !(landingCard instanceof HTMLDivElement) ||
            !(landingMessage instanceof HTMLParagraphElement) ||
            !(landingOpenLink instanceof HTMLAnchorElement) ||
            !(landingCopyLinkButton instanceof HTMLButtonElement)
        ) {
            return;
        }

        const customSchemeURL = customSchemeURLForPortalPayload(payload);
        landingCard.hidden = false;
        landingMessage.textContent =
            `We found a WelcomTalk Portal start link for ${payload.fullName}. If the app does not open automatically, tap below.`;
        landingOpenLink.href = customSchemeURL;

        landingCopyLinkButton.onclick = async () => {
            const didCopy = await copyText(customSchemeURL);
            landingMessage.textContent = didCopy
                ? "WelcomTalk app link copied. You can paste it anywhere or open the app directly."
                : "Clipboard access is unavailable here. Use the Open WelcomTalk button instead.";
        };

        tryAutoOpenPortalLink(customSchemeURL);
    };

    const showBarcodeCard = async (
        payload: PortalStartPayload,
    ): Promise<void> => {
        const landingURL = landingURLForPortalPayload(payload);
        const customSchemeURL = customSchemeURLForPortalPayload(payload);

        barcodeCard.hidden = false;
        barcodeFrame.innerHTML = await QRCode.toString(landingURL, {
            errorCorrectionLevel: "H",
            margin: 1,
            type: "svg",
            width: 320,
        });
        barcodeCaption.textContent =
            `${payload.fullName} · ${payload.topic} · Scan this in WelcomTalk or with your iPhone Camera to open the session.`;
        barcodeOpenLink.href = customSchemeURL;
        barcodeLinkPreview.textContent = landingURL;
        latestPortalStartLandingURL = landingURL;
        latestPortalStartAppURL = customSchemeURL;
    };

    const writeRecordPreview = (
        record: WebsiteRequestRecord,
        successMessage: string,
    ): void => {
        latestJSON = JSON.stringify(record, null, 2);
        output.textContent = latestJSON;
        statusLine.textContent = successMessage;
    };

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

    generateButton.addEventListener("click", async () => {
        const record = buildRecord();
        if (!record) {
            latestJSON = "";
            output.textContent = "JSON preview appears here after generation.";
            hideBarcodeCard();
            return;
        }

        writeRecordPreview(
            record,
            "JSON generated locally in WelcomTalk Portal. Scan the barcode below or open the app link on this device.",
        );
        await showBarcodeCard(buildPortalStartPayload(record));
    });

    authenticateJasonButton.addEventListener("click", async () => {
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

        writeRecordPreview(
            record,
            "Demo request loaded. Scan the barcode in WelcomTalk on your iPhone to start the session.",
        );
        await showBarcodeCard(buildPortalStartPayload(record));
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

    barcodeCopyLinkButton.addEventListener("click", async () => {
        if (!latestPortalStartLandingURL) {
            statusLine.textContent = "Generate the barcode first, then copy the iPhone link.";
            return;
        }

        const didCopy = await copyText(latestPortalStartLandingURL);
        statusLine.textContent = didCopy
            ? "iPhone landing link copied to the clipboard."
            : "Clipboard access is not available here, but the app link is shown below the barcode.";
    });

    const incomingPortalPayload = portalPayloadFromURL(window.location.href);
    if (incomingPortalPayload) {
        showLandingCardForIncomingPortalLink(incomingPortalPayload);
    }
};

setupRequestBuilder();

export { };
