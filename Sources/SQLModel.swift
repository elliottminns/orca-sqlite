import Orca

public protocol SQLModel {

    var types: [String: DataType.Type] { get }

}

extension SQLModel {
    func typesWithIdentifier() -> [String: DataType.Type] {

        var types = self.types

        types["identifier"] = String.self

        return types
    }
}
