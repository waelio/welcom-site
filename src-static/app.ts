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
    status: "submitted" | "imported" | "started";
    attachments: WebsiteRequestAttachment[];
    importedAt?: string;
    startedAt?: string;
    hostDisplayName?: string;
    sessionCode?: string;
};

type AuthenticateJasonPreset = {
    fullName: string;
    topic: string;
    summary: string;
    additionalNotes: string;
};

type PortalStartPayload = {
    requestId?: string;
    fullName?: string;
    topic?: string;
    summary?: string;
    additionalNotes?: string;
};

const STATIC_SHELL_MESSAGE =
    "WelcomTalk Portal static shell loaded. The SwiftWasm bundle is not built in this checkout yet, so the HTML fallback is being served.";

const PORTAL_START_QUERY_FLAG = "portalStart";
const PORTAL_START_SCHEME = "welcomtalk://portal-start";
const DEFAULT_PORTAL_ORIGIN = "https://welcomeport.netlify.app/";
const DEFAULT_PORTAL_API_ORIGIN = "https://waelio-messaging.onrender.com";
const AUTO_OPEN_SESSION_STORAGE_PREFIX = "welcomtalk-portal-start:auto-open:";
const PORTAL_SYNC_POLL_INTERVAL_MS = 2500;

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

const resolvePortalAPIOrigin = (): string => {
    if (typeof window !== "undefined") {
        const host = window.location.hostname.toLowerCase();

        if (host === "localhost" || host === "127.0.0.1") {
            return "http://localhost:8080";
        }
    }

    return DEFAULT_PORTAL_API_ORIGIN;
};

const normalizePortalValue = (value: string): string =>
    value.trim();

const buildStoredPortalStartPayload = (
    record: WebsiteRequestRecord,
): PortalStartPayload => ({
    requestId: record.requestId,
});

const buildInlinePortalStartPayload = (
    record: WebsiteRequestRecord,
): PortalStartPayload => ({
    fullName: normalizePortalValue(record.fullName),
    topic: normalizePortalValue(record.topic),
    summary: normalizePortalValue(record.summary),
    additionalNotes: normalizePortalValue(record.additionalNotes),
});

const hasInlinePortalPayload = (
    payload: PortalStartPayload,
): payload is Required<Pick<PortalStartPayload, "fullName" | "topic" | "summary">> & PortalStartPayload => {
    const fullName = normalizePortalValue(payload.fullName || "");
    const topic = normalizePortalValue(payload.topic || "");
    const summary = normalizePortalValue(payload.summary || "");

    return Boolean(fullName && topic && summary);
};

const qrQueryParamsForPortalPayload = (
    payload: PortalStartPayload,
): URLSearchParams => {
    const params = new URLSearchParams();

    if (payload.requestId) {
        params.set("rid", payload.requestId);
        return params;
    }

    if (!hasInlinePortalPayload(payload)) {
        return params;
    }

    params.set("n", payload.fullName);
    params.set("t", payload.topic);
    params.set("s", payload.summary);

    if (payload.additionalNotes) {
        params.set("a", payload.additionalNotes);
    }

    return params;
};

const portalQueryParams = (
    payload: PortalStartPayload,
    includeLandingFlag: boolean,
): URLSearchParams => {
    const params = new URLSearchParams();

    if (includeLandingFlag) {
        params.set(PORTAL_START_QUERY_FLAG, "1");
    }

    if (payload.requestId) {
        params.set("rid", payload.requestId);
    }

    if (!hasInlinePortalPayload(payload)) {
        return params;
    }

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

const qrCodeURLForPortalPayload = (
    payload: PortalStartPayload,
): string => `${PORTAL_START_SCHEME}?${qrQueryParamsForPortalPayload(payload).toString()}`;

const landingURLForPortalPayload = (
    payload: PortalStartPayload,
): string => {
    const landingURL = new URL("/portal-start", resolvePortalOrigin());
    landingURL.search = portalQueryParams(payload, false).toString();
    return landingURL.toString();
};

const submitPortalRequest = async (
    record: WebsiteRequestRecord,
): Promise<WebsiteRequestRecord> => {
    const endpoint = new URL("/api/portal-requests", resolvePortalAPIOrigin());
    const response = await fetch(endpoint, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
        },
        body: JSON.stringify(record),
    });

    if (!response.ok) {
        let message = `Portal request upload failed with status ${response.status}.`;

        try {
            const payload = (await response.json()) as { error?: string };
            if (typeof payload.error === "string" && payload.error.trim()) {
                message = payload.error;
            }
        } catch {
            // Ignore JSON parsing errors and keep the generic status message.
        }

        throw new Error(message);
    }

    return (await response.json()) as WebsiteRequestRecord;
};

const fetchPortalRequest = async (
    requestId: string,
): Promise<WebsiteRequestRecord> => {
    const endpoint = new URL(`/api/portal-requests/${encodeURIComponent(requestId)}`, resolvePortalAPIOrigin());
    const response = await fetch(endpoint, {
        method: "GET",
        headers: {
            Accept: "application/json",
        },
        cache: "no-store",
    });

    if (!response.ok) {
        throw new Error(`Portal request fetch failed with status ${response.status}.`);
    }

    return (await response.json()) as WebsiteRequestRecord;
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
                undefined,
            fullName: queryValue(queryValues, "n", "fullname", "full_name"),
            topic: queryValue(queryValues, "t", "topic"),
            summary: queryValue(queryValues, "s", "summary"),
            additionalNotes: queryValue(
                queryValues,
                "a",
                "notes",
                "additionalnotes",
                "additional_notes",
            ),
        } satisfies PortalStartPayload;

        if (!payload.requestId && (!payload.fullName || !payload.topic || !payload.summary)) {
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
    const appBarcodeFrame = document.getElementById("portal-start-app-barcode");
    const cameraBarcodeFrame = document.getElementById("portal-start-camera-barcode");
    const barcodeCaption = document.getElementById("portal-start-caption");
    const barcodeOpenLink = document.getElementById("portal-start-open-link");
    const barcodeCopyLinkButton = document.getElementById("copy-portal-start-link");
    const barcodeLinkPreview = document.getElementById("portal-start-link-preview");
    const portalSyncStatus = document.getElementById("portal-sync-status");
    const portalSyncDetails = document.getElementById("portal-sync-details");
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
        !(appBarcodeFrame instanceof HTMLDivElement) ||
        !(cameraBarcodeFrame instanceof HTMLDivElement) ||
        !(barcodeCaption instanceof HTMLParagraphElement) ||
        !(barcodeOpenLink instanceof HTMLAnchorElement) ||
        !(barcodeCopyLinkButton instanceof HTMLButtonElement) ||
        !(barcodeLinkPreview instanceof HTMLParagraphElement) ||
        !(portalSyncStatus instanceof HTMLParagraphElement) ||
        !(portalSyncDetails instanceof HTMLParagraphElement)
    ) {
        return;
    }

    let latestJSON = "";
    let latestPortalStartLandingURL = "";
    let latestPortalStartAppURL = "";
    let portalSyncPollHandle: number | null = null;

    authenticateJasonButton.textContent = "Use demo request";

    const stopPortalSyncPolling = (): void => {
        if (portalSyncPollHandle !== null) {
            window.clearInterval(portalSyncPollHandle);
            portalSyncPollHandle = null;
        }
    };

    const setPortalSyncState = (summary: string, details = ""): void => {
        portalSyncStatus.textContent = summary;
        portalSyncDetails.textContent = details;
    };

    const applyPortalSyncRecord = (record: WebsiteRequestRecord): void => {
        switch (record.status) {
            case "started": {
                const startedBits = [
                    record.hostDisplayName ? `Host: ${record.hostDisplayName}` : "",
                    record.sessionCode ? `Session code: ${record.sessionCode}` : "",
                    record.startedAt ? `Started: ${new Date(record.startedAt).toLocaleString()}` : "",
                ].filter(Boolean);

                setPortalSyncState(
                    "WelcomTalk session started in the app.",
                    startedBits.join(" • "),
                );
                stopPortalSyncPolling();
                break;
            }

            case "imported": {
                const importedBits = [
                    record.hostDisplayName ? `Host: ${record.hostDisplayName}` : "",
                    record.importedAt ? `Imported: ${new Date(record.importedAt).toLocaleString()}` : "",
                ].filter(Boolean);

                setPortalSyncState(
                    "WelcomTalk imported this request. Review and start the session in the app.",
                    importedBits.join(" • "),
                );
                break;
            }

            default:
                setPortalSyncState(
                    "Waiting for the WelcomTalk app to import this request.",
                    "Keep this page open if you want to watch the handoff status update.",
                );
                break;
        }
    };

    const startPortalSyncPolling = (requestId: string): void => {
        stopPortalSyncPolling();
        applyPortalSyncRecord({
            requestId,
            createdAt: new Date().toISOString(),
            source: "welcomtalk-portal",
            fullName: "",
            topic: "",
            summary: "",
            additionalNotes: "",
            status: "submitted",
            attachments: [],
        });

        const poll = async (): Promise<void> => {
            try {
                const latestRecord = await fetchPortalRequest(requestId);
                applyPortalSyncRecord(latestRecord);
            } catch {
                setPortalSyncState(
                    "Waiting for the WelcomTalk app to import this request.",
                    "Sync status is temporarily unavailable, but the barcode and link are still ready.",
                );
            }
        };

        void poll();
        portalSyncPollHandle = window.setInterval(() => {
            void poll();
        }, PORTAL_SYNC_POLL_INTERVAL_MS);
    };

    const hideBarcodeCard = (): void => {
        stopPortalSyncPolling();
        barcodeCard.hidden = true;
        appBarcodeFrame.replaceChildren();
        cameraBarcodeFrame.replaceChildren();
        barcodeCaption.textContent = "";
        barcodeOpenLink.href = "#";
        barcodeLinkPreview.textContent = "";
        portalSyncStatus.textContent = "";
        portalSyncDetails.textContent = "";
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
            payload.fullName
                ? `We found a WelcomTalk Portal start link for ${payload.fullName}. If the app does not open automatically, tap below.`
                : "We found a WelcomTalk Portal start link. If the app does not open automatically, tap below.";
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
        const qrCodeURL = qrCodeURLForPortalPayload(payload);
        const label = payload.fullName && payload.topic
            ? `${payload.fullName} · ${payload.topic}`
            : payload.requestId
                ? `Request ${payload.requestId}`
                : "Portal request";

        barcodeCard.hidden = false;
        appBarcodeFrame.innerHTML = await QRCode.toString(qrCodeURL, {
            errorCorrectionLevel: "M",
            margin: 2,
            type: "svg",
            width: 420,
        });

        cameraBarcodeFrame.innerHTML = await QRCode.toString(landingURL, {
            errorCorrectionLevel: "M",
            margin: 2,
            type: "svg",
            width: 520,
        });

        barcodeCaption.textContent =
            `${label} · Use the app QR inside WelcomTalk. Use the camera QR with iPhone Camera or any browser-based scanner.`;
        barcodeOpenLink.href = customSchemeURL;
        barcodeLinkPreview.textContent = `Camera/browser fallback: ${landingURL}`;
        latestPortalStartLandingURL = landingURL;
        latestPortalStartAppURL = customSchemeURL;

        if (payload.requestId) {
            startPortalSyncPolling(payload.requestId);
        } else {
            stopPortalSyncPolling();
            setPortalSyncState(
                "Direct barcode fallback is active.",
                "Remote sync status is unavailable for this inline payload barcode.",
            );
        }
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

        try {
            const storedRecord = await submitPortalRequest(record);

            writeRecordPreview(
                storedRecord,
                "Request saved to the WelcomTalk handoff service. Scan the barcode below or open the app link on this device.",
            );
            await showBarcodeCard(buildStoredPortalStartPayload(storedRecord));
        } catch {
            writeRecordPreview(
                record,
                "Remote handoff is unavailable right now, so a direct barcode fallback was generated instead.",
            );
            await showBarcodeCard(buildInlinePortalStartPayload(record));
        }
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

        try {
            const storedRecord = await submitPortalRequest(record);

            writeRecordPreview(
                storedRecord,
                "Demo request loaded and saved remotely. Scan the barcode in WelcomTalk on your iPhone to start the session.",
            );
            await showBarcodeCard(buildStoredPortalStartPayload(storedRecord));
        } catch {
            writeRecordPreview(
                record,
                "Demo request loaded, but remote handoff is unavailable, so a direct barcode fallback was generated.",
            );
            await showBarcodeCard(buildInlinePortalStartPayload(record));
        }
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
