import Foundation
import Testing
@testable import GitLabPersistence

@Suite("Persistence · SecureStore (Unit)")
struct SecureStoreUnitTests {
    private actor FakeKeychain: SecureStore {
        var storage: [String: Data] = [:]

        func save(_ data: Data, service: String, account: String) async throws {
            storage[service + "|" + account] = data
        }

        func load(service: String, account: String) async throws -> Data? {
            storage[service + "|" + account]
        }

        func clear(service: String, account: String) async throws {
            storage.removeValue(forKey: service + "|" + account)
        }
    }

    @Test("save then load returns data; clear removes it")
    func saveLoadClear() async throws {
        // Given
        let store: any SecureStore = FakeKeychain()
        let data = Data([1, 2, 3])

        // When
        try await store.save(data, service: "svc", account: "acc")
        let loaded = try await store.load(service: "svc", account: "acc")
        try await store.clear(service: "svc", account: "acc")
        let after = try await store.load(service: "svc", account: "acc")

        // Then
        #expect(loaded == data)
        #expect(after == nil)
    }

    @Test("load non-existing key returns nil")
    func loadNonExisting() async throws {
        let store: any SecureStore = FakeKeychain()
        let result = try await store.load(service: "missing", account: "none")
        #expect(result == nil)
    }

    @Test("different service/account pairs are isolated")
    func differentKeys() async throws {
        let store: any SecureStore = FakeKeychain()
        try await store.save(Data([1]), service: "svc1", account: "acc1")
        try await store.save(Data([2]), service: "svc2", account: "acc2")

        #expect(try await store.load(service: "svc1", account: "acc1") == Data([1]))
        #expect(try await store.load(service: "svc2", account: "acc2") == Data([2]))
    }

}
