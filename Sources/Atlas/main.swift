import SwiftCLI
import AtlasCore

let cli = CLI(name: "Atlas", version: "0.0.1", description: "Powderhouse Studios Atlas")

let atlasCore: AtlasCore = AtlasCore()

cli.commands = [
    InfoCommand(atlasCore),
    LoginCommand(atlasCore),
    LogoutCommand()
]

_ = cli.go()


