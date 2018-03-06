import SwiftCLI
import AtlasCore

let cli = CLI(name: "Atlas", version: "0.0.1", description: "Powderhouse Studios Atlas")

let atlasCore: AtlasCore = AtlasCore()

cli.commands = [
    ImportCommand(atlasCore),
    InfoCommand(atlasCore),
    LoginCommand(atlasCore),
    LogoutCommand(atlasCore),
    StageCommand(atlasCore),
    StagedCommand(atlasCore),
    StartProjectCommand(atlasCore),
    StatusCommand(atlasCore),
    UnstageCommand(atlasCore),
    UnstagedCommand(atlasCore),
]

_ = cli.go()


