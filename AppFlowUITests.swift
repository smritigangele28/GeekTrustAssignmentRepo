import XCTest

final class AppFlowUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Helpers

    private func launchApp(arguments: [String] = [], environment: [String: String] = [:]) -> XCUIApplication {
        let app = XCUIApplication()
        if !arguments.isEmpty { app.launchArguments = arguments }
        if !environment.isEmpty { app.launchEnvironment = environment }
        app.launch()
        return app
    }

    // MARK: - Tests

    func testHappyPathFlow_Login_CreateItem_SeeInList() {
        // Arrange
        let app = launchApp()

        // NOTE: Replace these accessibility identifiers with those used in your app.
        // Suggested identifiers:
        // - TextField("Email").accessibilityIdentifier("emailField")
        // - SecureField("Password").accessibilityIdentifier("passwordField")
        // - Button("Sign In").accessibilityIdentifier("signInButton")
        // - StaticText("Welcome").accessibilityIdentifier("welcomeTitle")
        // - Button("Create").accessibilityIdentifier("createButton")
        // - TextField("Title").accessibilityIdentifier("titleField")
        // - Button("Save").accessibilityIdentifier("saveButton")

        let emailField = app.textFields["emailField"]
        let passwordField = app.secureTextFields["passwordField"]
        let signInButton = app.buttons["signInButton"]

        // Act: Login
        XCTAssertTrue(emailField.waitForExistence(timeout: 5), "Email field not found. Set accessibilityIdentifier('emailField').")
        emailField.tap()
        emailField.typeText("user@example.com")

        XCTAssertTrue(passwordField.waitForExistence(timeout: 5), "Password field not found. Set accessibilityIdentifier('passwordField').")
        passwordField.tap()
        passwordField.typeText("P@ssw0rd")

        XCTAssertTrue(signInButton.waitForExistence(timeout: 5), "Sign In button not found. Set accessibilityIdentifier('signInButton').")
        signInButton.tap()

        // Assert: Home screen visible
        let welcomeTitle = app.staticTexts["welcomeTitle"]
        XCTAssertTrue(welcomeTitle.waitForExistence(timeout: 10), "Welcome title not visible after sign-in. Set accessibilityIdentifier('welcomeTitle').")

        // Act: Perform primary action
        let createButton = app.buttons["createButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 5), "Create button not found. Set accessibilityIdentifier('createButton').")
        createButton.tap()

        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5), "Title field not found. Set accessibilityIdentifier('titleField').")
        titleField.tap()
        titleField.typeText("My Item")

        let saveButton = app.buttons["saveButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Save button not found. Set accessibilityIdentifier('saveButton').")
        saveButton.tap()

        // Assert: Item appears in list
        let newItemCell = app.staticTexts["My Item"]
        XCTAssertTrue(newItemCell.waitForExistence(timeout: 10), "Newly created item did not appear in the list.")
    }

    func testInvalidLogin_ShowsErrorMessage() {
        // Arrange
        let app = launchApp()

        let emailField = app.textFields["emailField"]
        let passwordField = app.secureTextFields["passwordField"]
        let signInButton = app.buttons["signInButton"]

        // Act: Attempt invalid login
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText("invalid@example.com")

        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        passwordField.tap()
        passwordField.typeText("wrong")

        XCTAssertTrue(signInButton.waitForExistence(timeout: 5))
        signInButton.tap()

        // Assert: Error appears
        // Replace with your error label identifier, e.g., "loginErrorLabel"
        let errorLabel = app.staticTexts["loginErrorLabel"]
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 5), "Expected an error message with accessibilityIdentifier('loginErrorLabel').")
    }
}
