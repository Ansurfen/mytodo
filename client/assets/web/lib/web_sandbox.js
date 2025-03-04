const nextID = (() => {
    var id = 0;
    return () => {
        id++;
        return id;
    };
})();
class WebViewEventChannel {
    static get(id) {
        return WebViewEventChannel.__webview_event_bridge_data__.get(id);
    }
    static put(id, v) {
        WebViewEventChannel.__webview_event_bridge_data__.set(id, v);
    }
    static clear(id) {
        WebViewEventChannel.__webview_event_bridge_data__.delete(id);
    }
    static post(evt) {
        __webview_event_bridge__.postMessage(JSON.stringify(evt));
    }
    static handler(name) {
        return (v) => {
            let id = nextID();
            WebViewEventChannel.post({
                id: id,
                method: name,
                args: v
            });
            return [id, new Promise((resolve) => {
                    let timer = setInterval(() => {
                        if (WebViewEventChannel.__webview_event_bridge_data__.get(id) != null) {
                            clearInterval(timer);
                            resolve(WebViewEventChannel.__webview_event_bridge_data__.get(id));
                        }
                    }, 100);
                })];
        };
    }
}
WebViewEventChannel.__webview_event_bridge_data__ = new Map();
class WebHTMLChannel {
    static listen(name, callback) {
        WebHTMLChannel._events.set(name, callback);
    }
    static free(name) {
        WebHTMLChannel._events.delete(name);
    }
    static notify(evt) {
        let cb = WebHTMLChannel._events.get(evt.type);
        if (typeof cb == "function") {
            cb(evt.detail);
        }
    }
    static post(evt) {
        parent.postMessage(JSON.stringify(evt));
    }
}
WebHTMLChannel._events = new Map();
class WebBridge {
    static register(method, handler) {
        WebBridge.F[method] = handler;
    }
    // public static unregister(method: string) {
    //     WebBridge.F[method] = null
    // }
    static notify(type, detail, origin = "*") {
        let evt = JSON.stringify({ type: type, detail: detail });
        if (kIsPhone) {
            eval(`${type}.postMessage(${evt});`);
        }
        window.parent.postMessage(evt, origin);
    }
    static listen(type, callback) {
        WebHTMLChannel.listen(type, callback);
    }
}
WebBridge.F = {};
var osPlatform = {
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
}, browserPlatform = {
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
    let webkit = ua.match(/Web[kK]it[\/]{0,1}([\d.]+)/), android = ua.match(/(Android);?[\s\/]+([\d.]+)?/), osx = !!ua.match(/\(Macintosh\; Intel /), ipad = ua.match(/(iPad).*OS\s([\d_]+)/), ipod = ua.match(/(iPod)(.*OS\s([\d_]+))?/), iphone = !ipad && ua.match(/(iPhone\sOS)\s([\d_]+)/), webos = ua.match(/(webOS|hpwOS)[\s\/]([\d.]+)/), win = /Win\d{2}|Windows/.test(pf), wp = ua.match(/Windows Phone ([\d.]+)/), touchpad = webos && ua.match(/TouchPad/), kindle = ua.match(/Kindle\/([\d.]+)/), silk = ua.match(/Silk\/([\d._]+)/), blackberry = ua.match(/(BlackBerry).*Version\/([\d.]+)/), bb10 = ua.match(/(BB10).*Version\/([\d.]+)/), rimtabletos = ua.match(/(RIM\sTablet\sOS)\s([\d.]+)/), playbook = ua.match(/PlayBook/), chrome = ua.match(/Chrome\/([\d.]+)/) || ua.match(/CriOS\/([\d.]+)/), firefox = ua.match(/Firefox\/([\d.]+)/), firefoxos = ua.match(/\((?:Mobile|Tablet); rv:([\d.]+)\).*Firefox\/[\d.]+/), ie = ua.match(/MSIE\s([\d.]+)/) ||
        ua.match(/Trident\/[\d](?=[^\?]+).*rv:([0-9.].)/), webview = !chrome && ua.match(/(iPhone|iPod|iPad).*AppleWebKit(?!.*Safari)/), safari = webview ||
        ua.match(/Version\/([\d.]+)([^S](Safari)|[^M]*(Mobile)[^S]*(Safari))/), weixin = ua.match(/MicroMessenger/i);
    // if (browserPlatform.webkit = !!webkit) browserPlatform.version = webkit[1]
    if (webkit) {
        browserPlatform.webkit = !!webkit;
        browserPlatform.version = webkit[1];
    }
    if (android)
        (osPlatform.android = true), (osPlatform.version = android[2]);
    if (iphone && !ipod)
        (osPlatform.ios = osPlatform.iphone = true), (osPlatform.version = iphone[2].replace(/_/g, "."));
    if (ipad)
        (osPlatform.ios = osPlatform.ipad = true), (osPlatform.version = ipad[2].replace(/_/g, "."));
    if (ipod)
        (osPlatform.ios = osPlatform.ipod = true),
            (osPlatform.version = ipod[3] ? ipod[3].replace(/_/g, ".") : null);
    if (wp)
        (osPlatform.wp = true), (osPlatform.version = wp[1]);
    if (webos)
        (osPlatform.webos = true), (osPlatform.version = webos[2]);
    if (touchpad)
        osPlatform.touchpad = true;
    if (blackberry)
        (osPlatform.blackberry = true), (osPlatform.version = blackberry[2]);
    if (bb10)
        (osPlatform.bb10 = true), (osPlatform.version = bb10[2]);
    if (rimtabletos)
        (osPlatform.rimtabletos = true), (osPlatform.version = rimtabletos[2]);
    if (playbook)
        browserPlatform.playbook = true;
    if (kindle)
        (osPlatform.kindle = true), (osPlatform.version = kindle[1]);
    if (silk)
        (browserPlatform.silk = true), (browserPlatform.version = silk[1]);
    if (!silk && osPlatform.android && ua.match(/Kindle Fire/))
        browserPlatform.silk = true;
    if (chrome)
        (browserPlatform.chrome = true), (browserPlatform.version = chrome[1]);
    if (firefox)
        (browserPlatform.firefox = true), (browserPlatform.version = firefox[1]);
    if (firefoxos)
        (osPlatform.firefoxos = true), (osPlatform.version = firefoxos[1]);
    if (ie)
        (browserPlatform.ie = true), (browserPlatform.version = ie[1]);
    if (safari && (osx || osPlatform.ios || win)) {
        browserPlatform.safari = true;
        if (!osPlatform.ios)
            browserPlatform.version = safari[1];
    }
    if (webview)
        browserPlatform.webview = true;
    if (weixin)
        browserPlatform.wx = true;
    osPlatform.tablet = !!(ipad ||
        playbook ||
        (android && !ua.match(/Mobile/)) ||
        (firefox && ua.match(/Tablet/)) ||
        (ie && !ua.match(/Phone/) && ua.match(/Touch/)));
    osPlatform.phone = !!(!osPlatform.tablet &&
        !osPlatform.ipod &&
        (android ||
            iphone ||
            webos ||
            blackberry ||
            bb10 ||
            (chrome && ua.match(/Android/)) ||
            (chrome && ua.match(/CriOS\/([\d.]+)/)) ||
            (firefox && ua.match(/Mobile/)) ||
            (ie && ua.match(/Touch/))));
    kIsPhone = osPlatform.phone;
    if (kIsPhone) {
        __webview_event_listener_entry = (evt) => {
            window.parent.postMessage(evt);
        };
    }
    else {
        parent.__web_builder__ && parent.__web_builder__(window);
    }
    window.parent.addEventListener("message", (evt) => {
        let htmlEvt = JSON.parse(evt.data);
        WebHTMLChannel.notify(htmlEvt);
    });
})();