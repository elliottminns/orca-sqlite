import PackageDescription

let package = Package(
    name: "OrcaSQLite",
    dependencies: [
		.Package(url: "https://github.com/elliottminns/sqlite-module.git",
            majorVersion: 0),
        .Package(url: "https://github.com/elliottminns/orca.git",
            majorVersion: 0),
        .Package(url: "https://github.com/elliottminns/orca-sql.git",
            majorVersion: 0)
    ]
)
