import SwiftUI
import GitLabImageLoading

public struct StubImageLoader: ImageLoadingClient {
    public var imageToReturn: Image?
    public var errorToThrow: Error?

    public init(imageToReturn: Image? = nil, errorToThrow: Error? = nil) {
        self.imageToReturn = imageToReturn
        self.errorToThrow = errorToThrow
    }

    public func loadImage(url: URL?, targetSizePoints: CGSize?) async throws -> Image {
        if let errorToThrow { throw errorToThrow }
        return imageToReturn ?? Image(systemName: "photo")
    }

    public func configureDefaults() {}
}
