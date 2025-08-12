import Foundation
import Security
import CommonCrypto

public final class PinnedSessionDelegate: NSObject, URLSessionDelegate {
    // TODO: populate with Base64-encoded SHA-256 of the SPKI public key(s) for gitlab.com and any self-hosted domains
    private let pinnedSPKISHA256Base64: Set<String>

    public init(pins: Set<String> = []) {
        self.pinnedSPKISHA256Base64 = pins
        super.init()
    }

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let trust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        guard let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              let leaf = chain.first,
              let publicKey = SecCertificateCopyKey(leaf) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        var error: Unmanaged<CFError>?
        guard let keyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let hash = sha256(keyData).base64EncodedString()

        if pinnedSPKISHA256Base64.isEmpty || pinnedSPKISHA256Base64.contains(hash) {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private func sha256(_ data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
}

