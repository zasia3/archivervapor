import FluentProvider
import PostgreSQLProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
        
        addConfigurable(middleware: AuthenticationMiddleware(Photo.self), name: "authentication")
        addConfigurable(middleware: AuthenticationMiddleware(Shop.self), name: "authentication")
        addConfigurable(middleware: AuthenticationMiddleware(Receipt.self), name: "authentication")
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(PostgreSQLProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(Post.self)
        preparations.append(User.self)
        preparations.append(Shop.self)
        preparations.append(AuthToken.self)
        preparations.append(Photo.self)
        preparations.append(Receipt.self)
        
    }
}
