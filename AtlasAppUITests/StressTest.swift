//
//  StressTest.swift
//  AtlasAppUITests
//
//  Created by Jared Cosulich on 11/4/18.
//

import XCTest

class StressTest: AtlasUITestCase {
    let project1 = "Test"
    let project2 = "AnotherTest"
    let filename1 = "indexfile1.html"
    let filename2 = "indexfile2.html"
    let filename3 = "indexfile3.html"
    let filename4 = "indexfile4.html"
    let filename5 = "indexfile5.html"
    let filename6 = "indexfile6.html"
    let commitMessage1 = "This is a stress test commit"
    let commitMessage2 = "This is another stress test commit"

    override func setUp() {
        super.setUp()
        
        login(app)
    }
    
    func stageNoWait(_ filename: String, in projectName: String) {
        let terminal = app.textFields["TerminalInput"]
        
        terminal.click()
        
        terminal.typeText("ls \(projectName)/staged\n")
        if let output = app.textViews["TerminalView"].value as? String {
            if let message = output.components(separatedBy: "\n").last {
                if message.contains("No such file or directory") {
                    sleep(1)
                    stageNoWait(filename, in: projectName)
                    return
                }
            }
        }

        terminal.typeText("pwd\n")
        if let output = app.textViews["TerminalView"].value as? String {
            if let dir = output.components(separatedBy: "\n").last {
                terminal.typeText("touch ../\(filename)\n")
                terminal.typeText("stage -f \(dir)/../\(filename) -p \(projectName)\n")
            }
        }
    }
    
    func commitNoWait(_ projectName: String, commitMessage: String) {
        let projectStaged = app.groups["\(projectName)-staged"]
        projectStaged.buttons["Commit"].click()
        
        let commitDialog = projectStaged.popovers.firstMatch
        let commitMessageArea = commitDialog.textFields["Why are you submitting these files?"]
        commitMessageArea.click()
        commitMessageArea.typeText(commitMessage)
        commitDialog.buttons["Commit"].click()
        
        waitForTerminalToContain("Files successfully committed.")
    }
    
    func addProjectNoWait(_ projectName: String) {
        app.buttons["+"].click()
        let projectTextField = app.popovers.textFields["Project Name"]
        projectTextField.typeText(projectName)
        app.popovers.buttons["Save"].click()
    }
    
    func testInAStressfulManner() {
        let log = app.collectionViews["LogView"]

        stageNoWait(filename1, in: "General")
        stageNoWait(filename2, in: "General")
        stageNoWait(filename3, in: "General")
        
        app.collectionViews["General-staged-files"].buttons["-"].firstMatch.click()
        clickAlertButton("Remove")

        addProjectNoWait(project1)
        
        stageNoWait(filename4, in: project1)
        commitNoWait(project1, commitMessage: commitMessage1)

        addProjectNoWait(project2)

        stageNoWait(filename5, in: project2)
        commitNoWait(project2, commitMessage: commitMessage2)

        stageNoWait(filename6, in: project2)

        app.groups["\(project2)-staged"].buttons["x"].click()
        clickAlertButton("Delete")
        
        XCTAssert(waitForElementToDisappear(app.collectionViews["\(project2)-staged-files"]))

        let generalStagingArea = app.collectionViews["General-staged-files"]
        XCTAssert(generalStagingArea.staticTexts[filename1].exists, "Unable to find \(filename1)")
        XCTAssert(!generalStagingArea.staticTexts[filename2].exists, "Still found \(filename2)")
        XCTAssert(generalStagingArea.staticTexts[filename3].exists, "Unable to find \(filename3)")

        let testStagingArea = app.collectionViews["Test-staged-files"]
        XCTAssert(!testStagingArea.staticTexts[filename4].exists, "Still found \(filename4)")
        
        XCTAssert(log.staticTexts["\(commitMessage1)\n"].exists, "Unable to find \(commitMessage1)")
        XCTAssert(log.staticTexts[project1].exists, "Unable to find \(project1) Project in log")
        XCTAssert(log.links[filename4].exists, "Unable to find \(filename4) link in log")
        
        XCTAssert(!log.staticTexts["\(commitMessage2)\n"].exists, "Still found \(commitMessage2)")
        XCTAssert(!log.staticTexts[project2].exists, "Still found \(project2) Project in log")
        XCTAssert(!log.links[filename5].exists, "Still found \(filename5) link in log")
    }
}


