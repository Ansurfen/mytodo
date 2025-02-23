if (kIsPhone) {
    parent["__dart_function_geolocation"] = WebViewEventChannel.handler("__dart_function_geolocation")
    WebBridge.register("geolocation", (v) => {
        let [id, handle] = parent["__dart_function_geolocation"](v)
        return { id: id, handle: handle }
    })
} else {
    WebBridge.register("geolocation", (v) => {
        return {
            id: 0, handle: new Promise((resolve) => {
                resolve(parent.__dart_function_geolocation(v))
            })
        };
    })
}