import Foundation
import CoreData
import Combine

extension NSManagedObjectContext {
    /// 當前 context 任一 save 完成就發送一次（主執行緒）
    var didSavePublisher: AnyPublisher<Void, Never> {
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave, object: self)
            .map { _ in () }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
