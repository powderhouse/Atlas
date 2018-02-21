import SwiftCLI
import AtlasCore

let cli = CLI(name: "Atlas", version: "0.0.1", description: "Powderhouse Studios Atlas")

let atlasCore: AtlasCore = AtlasCore()

cli.commands = [
    ImportCommand(atlasCore),
    InfoCommand(atlasCore),
    LoginCommand(atlasCore),
    LogoutCommand(),
    StartProjectCommand(atlasCore),
    StatusCommand(atlasCore),
]

_ = cli.go()


