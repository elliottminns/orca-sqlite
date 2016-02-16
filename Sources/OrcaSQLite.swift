import Orca
import OrcaSQL
import Foundation

public class OrcaSQLite {

    let database: SQLite

    public init(path: String) {
        self.database = SQLite(path: path)
    }

    func dataTypeToString(data: [String: DataType]) -> [String: String] {

        var strings = [String: String]()

        for (key, value) in data {
            strings[key] = value.typeString + "." + value.toString()
        }

        return strings
    }

    func stringToDataType(data: [String: String]) -> [String: DataType] {

        var dataTypeValues = [String: DataType]()

        for (key, value) in data {

            for type in Orca.supportedTypes {

                let typeString = "\(type)."

                if value.hasPrefix(typeString) {

                    if let range = value.rangeOfString(typeString) {

                        let v = value.stringByReplacingCharactersInRange(range,
                             withString: "")

                        dataTypeValues[key] = type.fromString(v)
                    }
                }
            }
        }

        return dataTypeValues

    }
}

extension OrcaSQLite: Driver {

    public func generateUniqueIdentifier() -> String {
        return NSUUID().UUIDString
    }

    public func findOne(collection collection: String, filters: [Filter],
        schema: [String: DataType.Type]) throws -> [String: DataType] {

            let sql = SQL(operation: .SELECT, table: collection)

            sql.filters = filters
            sql.limit = 1

            let rows = database.execute(sql.query)
            if rows.count > 0 {
                let data = stringToDataType(rows[0].data)
                return data
            }

            throw DriverError.NotFound
    }

    public func find(collection collection: String, filters: [Filter], 
        schema: [String: DataType.Type]) throws -> [[String: DataType]] {

            let sql = SQL(operation: .SELECT, table: collection)

            sql.filters = filters

            var data: [[String: DataType]] = []

            for row in database.execute(sql.query) {
                data.append(stringToDataType(row.data))
            }

            return data
    }

    public func update(collection collection: String, filters: [Filter],
        data: [String: DataType], schema: [String: DataType.Type]) throws {

            let sql = SQL(operation: .UPDATE, table: collection)

            sql.filters = filters

            sql.data = dataTypeToString(data)

            database.execute(sql.query)
    }

    public func insert(collection collection: String,
        data: [String: DataType], model: Model) throws {

            createTableForCollection(collection, model: model)

            let sql = SQL(operation: .INSERT, table: collection)

            sql.data = dataTypeToString(data)

            database.execute(sql.query)
    }

    public func delete(collection collection: String, filters: [Filter], 
        schema: [String: DataType.Type]) throws {

            let sql = SQL(operation: .DELETE, table: collection)

            sql.filters = filters

            database.execute(sql.query)
    }

    func createTableForCollection(collection: String,
        model: Model) {

        let sql = SQL(operation: .CREATE, table: collection)

        var params = [String: String]()

        for (key, _) in model.dynamicType.fullSchema() {
            params[key] = "TEXT"
        }

        sql.data = params

        database.execute(sql.query)

    }

}
