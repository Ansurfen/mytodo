// Powered by https://github.com/DefinitelyTyped/DefinitelyTyped/blob/master/types/dom-to-image/index.d.ts

export interface DomToImage {
    toSvg(node: Node, options?: Options): Promise<string>;
    toPng(node: Node, options?: Options): Promise<string>;
    toJpeg(node: Node, options?: Options): Promise<string>;
    toBlob(node: Node, options?: Options): Promise<Blob>;
    toPixelData(node: Node, options?: Options): Promise<Uint8ClampedArray>;
}

export interface Options {
    filter?: ((node: Node) => boolean) | undefined;
    bgcolor?: string | undefined;
    width?: number | undefined;
    height?: number | undefined;
    style?: {} | undefined;
    quality?: number | undefined;
    imagePlaceholder?: string | undefined;
    cacheBust?: boolean | undefined;
}

type DomToImage_ = DomToImage;
type Options_ = Options;

declare global {
    namespace DomToImage {
        type Options = Options_;
        type DomToImage = DomToImage_;
    }

    const domtoimage: DomToImage.DomToImage;
}