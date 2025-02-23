declare const nextID: () => number;
interface EventChannel {
    postMessage: (msg: String) => void;
}
declare const __webview_event_bridge__: EventChannel;
interface WebViewCallbackEvent {
    id: Number;
    method: String;
    args: any;
}
type ID = Number;
type WebViewHandler = (v: any) => [ID, Promise<unknown>];
declare class Completer {
    future: number;
    constructor();
    complete(v: any): void;
}
declare class WebViewEventChannel {
    private static __webview_event_bridge_data__;
    static get(id: Number): any;
    static put(id: Number, v: any): void;
    static clear(id: Number): void;
    static post(evt: WebViewCallbackEvent): void;
    static handler(name: String): WebViewHandler;
}
type WebHTMLChannelCallback = (v: any) => void;
declare class WebHTMLChannel {
    private static _events;
    static listen(name: String, callback: WebHTMLChannelCallback): void;
    static free(name: String): void;
    static notify(evt: WebHTMLEvent): void;
    static post(evt: WebHTMLEvent): void;
}
interface WebHTMLEvent {
    type: String;
    detail: any;
}
interface Window {
    __web_builder__: (window: Window) => void;
}
type DartFunction = (...args: Array<any>) => {
    id: number;
    handle: Promise<unknown>;
};
type WebChannelCallback = WebHTMLChannelCallback;
type WebEvent = WebHTMLEvent;
declare class WebBridge {
    static F: Record<string, DartFunction>;
    static register(method: string, handler: DartFunction): void;
    static notify(type: string, detail: any, origin?: string): void;
    static listen(type: string, callback: WebChannelCallback): void;
}
type BrowserKind = "webkit" | "playbook" | "silk" | "chrome" | "firefox" | "ie" | "safari" | "webview" | "wx";
type OSKind = "android" | "iphone" | "ipad" | "ipod" | "wp" | "webos" | "touchpad" | "blackberry" | "bb10" | "rimtabletos" | "kindle" | "firefoxos" | "tablet" | "phone" | "ios";
type OSPlatform = Record<OSKind, boolean> & Record<"version", string | null>;
type BrowserPlatform = Record<BrowserKind, boolean> & Record<"version", string | null>;
declare var osPlatform: OSPlatform, browserPlatform: BrowserPlatform;
declare var __webview_event_listener_entry: any, kIsPhone: boolean;
