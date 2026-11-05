import SwiftUI
import SwiftStorage

final class ReferencePayload: Codable { var n = 1 }
struct ProbeKey: SceneStorageKey { static var defaultValue: ReferencePayload { ReferencePayload() } }
extension SceneStorageKey where Self == ProbeKey { static var probe: Self { .init() } }
extension SceneStorageKeys { var probe: ProbeKey { .init() } }

struct PublicForms: View {
    @SceneStorage.Codable("raw") private var raw = ReferencePayload()
    @SceneStorage.Codable("optional") private var optional: ReferencePayload?
    @SceneStorage.Codable(.probe) private var typed
    @SceneStorage.Codable(\.probe) private var path
    var body: some View {
        let _: Binding<ReferencePayload> = $raw
        Text("\(raw.n) \(optional?.n ?? -1) \(typed.n) \(path.n)")
    }
}

func initializeWithoutMainActor() -> CodableSceneStorage<ReferencePayload> {
    CodableSceneStorage(wrappedValue: ReferencePayload(), "init")
}
