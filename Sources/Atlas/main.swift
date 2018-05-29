import SwiftCLI
import AtlasCore
import AtlasCommands

let cli = CLI(name: "Atlas", version: "0.1.0", description: "Powderhouse Studios Atlas")

let atlasCore: AtlasCore = AtlasCore()
_ = atlasCore.initSearch()

cli.commands = [
    CommitCommand(atlasCore),
    CommitMessageCommand(atlasCore),
    ImportCommand(atlasCore),
    InfoCommand(atlasCore),
    LogCommand(atlasCore),
    LoginCommand(atlasCore),
    LogoutCommand(atlasCore),
    ProjectsCommand(atlasCore),
    PurgeCommand(atlasCore),
    SearchCommand(atlasCore),
    StageCommand(atlasCore),
    StagedCommand(atlasCore),
    StartProjectCommand(atlasCore),
    StatusCommand(atlasCore),
    UnstageCommand(atlasCore),
    UnstagedCommand(atlasCore),
    VersionCommand(atlasCore, version: cli.version ?? "N/A")
]

_ = cli.go()


