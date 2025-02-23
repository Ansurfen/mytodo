declare namespace TMap {
    type PositionValue = Number | String;

    class LatLng {
        constructor(lat: PositionValue, lng: PositionValue);
        getLat: () => Number;
        getLng: () => Number;
    }

    class MapEvent {
        latLng: LatLng
        point: Object
        type: String
        target: Object
        poi: POIInfo | null
        originalEvent: MouseEvent | TouchEvent
    }

    class POIInfo {
        latLng: LatLng
        name: String
    }

    class Map {
        constructor(domId: string, options: MapOptions);
        panTo: (pos: LatLng) => void;
        on: (eventName: MapEventName, listener: (evt: MapEvent) => void) => void;
        off: (eventName: MapEventName, listener: (evt: MapEvent) => void) => void;
        destroy: () => void;
        getCenter: () => LatLng;
    }

    type MapEventName = "idle" | "tilesloaded" | "click";

    class MapOptions {
        center: LatLng
        zoom?: Number
        rotation?: Number
        pitch?: Number
        baseMap?: BaseMap | BaseMap[]
        renderOptions?: MapRenderOptions
    }

    class MapRenderOptions {
        preserveDrawingBuffer?: boolean
        enableBloom?: boolean
        fogOptions?: FogOptions
    }

    class FogOptions {
        color: String
    }

    interface BaseMap {
        type: String
        features?: String[]
    }

    class MultiMarker {
        constructor(options: MultiMarkerOptions)
        setMap: (map: Map | null) => void;
        add: (geometries: PointGeometry | PointGeometry[]) => void;
    }

    class MultiMarkerOptions {
        id?: String	//图层id，若没有会自动分配一个。
        map?: Map	//显示Marker图层的底图。
        zIndex?: Number	//图层绘制顺序。
        styles?: MultiMarkerStyleHash	//点标注的相关样式。
        enableCollision?: Boolean	//是否开启图层内部的marker标注碰撞。
        geometries?: PointGeometry[]	//点标注数据数组。
        minZoom?: Number	//最小缩放层级，当地图缩放层级小于该值时该图层不显示，默认为3
        maxZoom?: Number	//最大缩放层级，当地图缩放层级大于该值时该图层不显示，默认为20
    }

    class PointGeometry {
        id?: String	//点图形数据的标志信息，不可重复，若id重复后面的id会被重新分配一个新id，若没有会随机生成一个。
        styleId?: String	//对应MultiMarkerStyleHash中的样式id。
        position?: LatLng	//标注点位置。
        rank?: Number	//标注点的图层内绘制顺序。
        properties?: Object	//标注点的属性数据。
        content?: String	//标注点文本，默认为undefined，即无标注点文本绘制效果
        markerAnimation?: MarkerAnimation	//标注点入场和离场动画设置
    }

    class MarkerStyle {
        constructor(options: MarkerStyleOptions)
    }

    namespace tools {
        class GeometryEditor {
            constructor(options: GeometryEditorOptions)
        }

        namespace constants {
            enum EDITOR_ACTION {
                INTERACT,
                DRAW
            }
        }
    }
}