import Commander
import AtlasCore

let main = command { (filename:String) in
    print("Reading file \(filename)...")
}

let group = Group {

    print("$0: \($0)")
    
//    $0.command(
//        "login",
//        description: "TEST",
//        Option("username")
//    ) { (username:String) in
//        print("Hello \(username)")
//    }

    $0.command("logout") {
        print("Goodbye.")
    }
    
    $0.command("test") { (parser:ArgumentParser) in
        print("HAS V: \(parser.hasOption("v")) - \(parser)")
    }
}
    
group.command("test", "TEST") { (test:String) in
    print("TEST: \(test)")
}
    
group.run()
