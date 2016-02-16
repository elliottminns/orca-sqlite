# Orca-SQLite

An SQLite driver for the [Orca](https://github.com/elliottminns/orca) ODM

## Getting Started

Add Orca-SQLite to your Package.swift:

```
Package.swift
```

```swift

    dependencies: [
        .Package(url: "https://github.com/elliottminns/orca.git", majorVersion: 0),
        .Package(url: "https://github.com/elliottminns/orca-sqlite.git", majorVersion: 0)
    ]

```

Then add the SQLite driver to Orca, with the path to your database file.

```
main.swift
```

```swift

import Orca
import OrcaSQLite

let database = Orca(driver: OrcaSQLite(path: "Database/test.sqlite"))

```

## Models

Due to the nature of SQLite, we need to provide details to create tables for our models. In this case, as well as extending `Model` from Orca, we need to extend `SQLModel` as well

```
Cat.swift
```

```swift
import Orca
import OrcaSQLite

class Cat: Model, SQLModel {

    var identifier: String?
    var name: String
    var age: Int
    var claws: Double?

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }

}

// Orca Model protocol
extension Cat: Model {
    required init?(serialized: [String: DataType]) {
        self.identifier = serialized["identifier"] as? String
        self.name = serialized["name"] as! String
        self.age = serialized["age"] as! Int
        self.claws = serialized["claws"] as? Double
    }
}

// Orca SQLite Model
extension Cat: SQLModel {
    var types: [String: DataType.Type] {
        return [
            "identifier": String.self,
            "name": String.self,
            "age": Int.self,
            "claws": Double.self]
    }
}

```
