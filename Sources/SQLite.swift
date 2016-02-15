#if os(Linux)
	import CSQLiteLinux
#else
	import CSQLiteMac
#endif

class SQLite {
	var database: COpaquePointer = nil

	init(path: String) {

        var path = path

        if !path.hasSuffix(".sqlite") {
            path += ".sqlite"
        }

		let code = sqlite3_open_v2(path, &self.database, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil);
		if code != 0 {
			print("Could not open database")
			sqlite3_close(self.database);
		}
	}

	func close() {
		sqlite3_close(self.database);
	}

	class Result {
		class Row {
			var data: [String: String]

			init() {
				self.data = [:]
			}
		}

		var rows: [Row]

		init() {
			self.rows = []
		}
	}

	func execute(statement: String) -> [Result.Row] {

		let resultPointer = UnsafeMutablePointer<Result>.alloc(1)

		var result = Result()
		resultPointer.initializeFrom(&result, count: 1)

		let code = sqlite3_exec(self.database, statement, { resultVoidPointer, columnCount, values, columns in
			let resultPointer = UnsafeMutablePointer<Result>(resultVoidPointer)
			let result = resultPointer.memory

			let row = Result.Row()
			for i in 0 ..< Int(columnCount) {
				guard let value = String.fromCString(values[i]) else {
					print("No value")
					continue
				}

				guard let column = String.fromCString(columns[i]) else {
					print("No column")
					continue
				}

				row.data[column] = value
			}

			result.rows.append(row)
			return 0
		}, resultPointer, nil);

		if code != SQLITE_OK {
			let error = String.fromCString(sqlite3_errmsg(self.database))
			print("Query error \(code) for statement '\(statement)' error \(error)")
		}

		return result.rows
	}
}
