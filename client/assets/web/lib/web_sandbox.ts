const nextID = (() => {
    var id = 0;
    return () => {
        id++;
        return id;
    }
})()

interface EventChannel {
    postMessage: (msg: String) => void
}

declare const __webview_event_bridge__: EventChannel;

interface WebViewCallbackEvent {
    id: Number
    method: String
    args: any
}

type ID = Number;
type WebViewHandler = (v: any) => [ID, Promise<unknown>];

class Completer {
    public future: number;

    constructor() {
        this.future = nextID();
    }

    public complete(v: any): void {
        WebViewEventChannel.put(this.future, v)
    }
}

class WebViewEventChannel {
    private static __webview_event_bridge_data__ = new Map<Number, any>();

    public static get(id: Number): any {
        return WebViewEventChannel.__webview_event_bridge_data__.get(id)
    }

    public static put(id: Number, v: any): void {
        WebViewEventChannel.__webview_event_bridge_data__.set(id, v)
    }

    public static clear(id: Number): void {
        WebViewEventChannel.__webview_event_bridge_data__.delete(id);
    }

    public static post(evt: WebViewCallbackEvent): void {
        __webview_event_bridge__.postMessage(JSON.stringify(evt))
    }

    public static handler(name: String): WebViewHandler {
        return (v: any) => {
            let id = nextID()
            WebViewEventChannel.post({
                id: id,
                method: name,
                args: v
            })
            return [id, new Promise((resolve) => {
                let timer = setInterval(() => {
                    if (WebViewEventChannel.__webview_event_bridge_data__.get(id) != null) {
                        clearInterval(timer)
                        resolve(WebViewEventChannel.__webview_event_bridge_data__.get(id))
                    }
                }, 100)
            })]
        }
    }
}

type WebHTMLChannelCallback = (v: any) => void

class WebHTMLChannel {
    private static _events = new Map<String, WebHTMLChannelCallback>();

    public static listen(name: String, callback: WebHTMLChannelCallback): void {
        WebHTMLChannel._events.set(name, callback)
    }

    public static free(name: String): void {
        WebHTMLChannel._events.delete(name)
    }

    public static notify(evt: WebHTMLEvent): void {
        let cb = WebHTMLChannel._events.get(evt.type);
        if (typeof cb == "function") {
            cb(evt.detail)
        }
    }

    public static post(evt: WebHTMLEvent): void {
        parent.postMessage(JSON.stringify(evt))
    }
}

interface WebHTMLEvent {
    type: String
    detail: any
}

interface Window {
    __web_builder__: (window: Window) => void
}

type DartFunction = (...args: Array<any>) => { id: number, handle: Promise<unknown> };
type WebChannelCallback = WebHTMLChannelCallback

type WebEvent = WebHTMLEvent;

class WebBridge {
    public static F: Record<string, DartFunction> = {}

    public static register(method: string, handler: DartFunction) {
        WebBridge.F[method] = handler
    }

    // public static unregister(method: string) {
    //     WebBridge.F[method] = null
    // }

    public static notify(type: string, detail: any, origin: string = "*") {
        let evt = JSON.stringify({ type: type, detail: detail })
        if (kIsPhone) {
            eval(`${type}.postMessage(${evt})`)
        }
        window.parent.postMessage(evt, origin)
    }

    public static listen(type: string, callback: WebChannelCallback) {
        WebHTMLChannel.listen(type, callback);
    }
}

type BrowserKind = "webkit" | "playbook" | "silk" | "chrome" | "firefox" | "ie" | "safari" | "webview" | "wx";

type OSKind = "android" | "iphone" | "ipad" | "ipod" | "wp"
    | "webos" | "touchpad" | "blackberry" | "bb10" | "rimtabletos"
    | "kindle" | "firefoxos" | "tablet" | "phone" | "ios";

type OSPlatform = Record<OSKind, boolean> & Record<"version", string | null>;
type BrowserPlatform = Record<BrowserKind, boolean> & Record<"version", string | null>;

var osPlatform: OSPlatform = {
    android: false,
    iphone: false,
    ipad: false,
    ipod: false,
    wp: false,
    webos: false,
    touchpad: false,
    blackberry: false,
    bb10: false,
    rimtabletos: false,
    kindle: false,
    firefoxos: false,
    tablet: false,
    phone: false,
    ios: false,
    version: null
}, browserPlatform: BrowserPlatform = {
    webkit: false,
    playbook: false,
    silk: false,
    chrome: false,
    firefox: false,
    ie: false,
    safari: false,
    webview: false,
    wx: false,
    version: null
};
var __webview_event_listener_entry, kIsPhone = false;

(() => {
    let ua = navigator.userAgent;
    let pf = navigator.platform;

    let webkit = ua.match(/Web[kK]it[\/]{0,1}([\d.]+)/),
        android = ua.match(/(Android);?[\s\/]+([\d.]+)?/),
        osx = !!ua.match(/\(Macintosh\; Intel /),
        ipad = ua.match(/(iPad).*OS\s([\d_]+)/),
        ipod = ua.match(/(iPod)(.*OS\s([\d_]+))?/),
        iphone = !ipad && ua.match(/(iPhone\sOS)\s([\d_]+)/),
        webos = ua.match(/(webOS|hpwOS)[\s\/]([\d.]+)/),
        win = /Win\d{2}|Windows/.test(pf),
        wp = ua.match(/Windows Phone ([\d.]+)/),
        touchpad = webos && ua.match(/TouchPad/),
        kindle = ua.match(/Kindle\/([\d.]+)/),
        silk = ua.match(/Silk\/([\d._]+)/),
        blackberry = ua.match(/(BlackBerry).*Version\/([\d.]+)/),
        bb10 = ua.match(/(BB10).*Version\/([\d.]+)/),
        rimtabletos = ua.match(/(RIM\sTablet\sOS)\s([\d.]+)/),
        playbook = ua.match(/PlayBook/),
        chrome = ua.match(/Chrome\/([\d.]+)/) || ua.match(/CriOS\/([\d.]+)/),
        firefox = ua.match(/Firefox\/([\d.]+)/),
        firefoxos = ua.match(/\((?:Mobile|Tablet); rv:([\d.]+)\).*Firefox\/[\d.]+/),
        ie =
            ua.match(/MSIE\s([\d.]+)/) ||
            ua.match(/Trident\/[\d](?=[^\?]+).*rv:([0-9.].)/),
        webview =
            !chrome && ua.match(/(iPhone|iPod|iPad).*AppleWebKit(?!.*Safari)/),
        safari =
            webview ||
            ua.match(/Version\/([\d.]+)([^S](Safari)|[^M]*(Mobile)[^S]*(Safari))/),
        weixin = ua.match(/MicroMessenger/i);
    // if (browserPlatform.webkit = !!webkit) browserPlatform.version = webkit[1]
    if (webkit) {
        browserPlatform.webkit = !!webkit;
        browserPlatform.version = webkit[1];
    }

    if (android) (osPlatform.android = true), (osPlatform.version = android[2]);
    if (iphone && !ipod)
        (osPlatform.ios = osPlatform.iphone = true), (osPlatform.version = iphone[2].replace(/_/g, "."));
    if (ipad)
        (osPlatform.ios = osPlatform.ipad = true), (osPlatform.version = ipad[2].replace(/_/g, "."));
    if (ipod)
        (osPlatform.ios = osPlatform.ipod = true),
            (osPlatform.version = ipod[3] ? ipod[3].replace(/_/g, ".") : null);
    if (wp) (osPlatform.wp = true), (osPlatform.version = wp[1]);
    if (webos) (osPlatform.webos = true), (osPlatform.version = webos[2]);
    if (touchpad) osPlatform.touchpad = true;
    if (blackberry) (osPlatform.blackberry = true), (osPlatform.version = blackberry[2]);
    if (bb10) (osPlatform.bb10 = true), (osPlatform.version = bb10[2]);
    if (rimtabletos) (osPlatform.rimtabletos = true), (osPlatform.version = rimtabletos[2]);
    if (playbook) browserPlatform.playbook = true;
    if (kindle) (osPlatform.kindle = true), (osPlatform.version = kindle[1]);
    if (silk) (browserPlatform.silk = true), (browserPlatform.version = silk[1]);
    if (!silk && osPlatform.android && ua.match(/Kindle Fire/)) browserPlatform.silk = true;
    if (chrome) (browserPlatform.chrome = true), (browserPlatform.version = chrome[1]);
    if (firefox) (browserPlatform.firefox = true), (browserPlatform.version = firefox[1]);
    if (firefoxos) (osPlatform.firefoxos = true), (osPlatform.version = firefoxos[1]);
    if (ie) (browserPlatform.ie = true), (browserPlatform.version = ie[1]);
    if (safari && (osx || osPlatform.ios || win)) {
        browserPlatform.safari = true;
        if (!osPlatform.ios) browserPlatform.version = safari[1];
    }
    if (webview) browserPlatform.webview = true;
    if (weixin) browserPlatform.wx = true;

    osPlatform.tablet = !!(
        ipad ||
        playbook ||
        (android && !ua.match(/Mobile/)) ||
        (firefox && ua.match(/Tablet/)) ||
        (ie && !ua.match(/Phone/) && ua.match(/Touch/))
    );
    osPlatform.phone = !!(
        !osPlatform.tablet &&
        !osPlatform.ipod &&
        (android ||
            iphone ||
            webos ||
            blackberry ||
            bb10 ||
            (chrome && ua.match(/Android/)) ||
            (chrome && ua.match(/CriOS\/([\d.]+)/)) ||
            (firefox && ua.match(/Mobile/)) ||
            (ie && ua.match(/Touch/)))
    );

    kIsPhone = osPlatform.phone;

    if (kIsPhone) {
        __webview_event_listener_entry = (evt: string) => {
            window.parent.postMessage(evt)
        }
    } else {
        parent.__web_builder__ && parent.__web_builder__(window);
    }

    window.parent.addEventListener("message", (evt) => {
        let htmlEvt: WebHTMLEvent = JSON.parse(evt.data);
        WebHTMLChannel.notify(htmlEvt);
    })
})()
