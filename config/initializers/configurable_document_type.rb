# Logic to auto-reload ConfigurableDocumentType schemas in development.
# This avoids restarting the server when editing json files.

if Rails.env.development?
  schema_directory = Rails.root.join("app/models/configurable_document_types")

  # Use the configured file watcher to monitor the directory.
  watcher = Rails.application.config.file_watcher.new([], { schema_directory.to_s => [:json] }) do
    Rails.logger.debug "ConfigurableDocumentType schemas changed. Clearing cache..."

    # Clear the @types cache. We use instance_variable_set because @types
    # is private to the class implementation and has no public setter.
    ConfigurableDocumentType.instance_variable_set(:@types, nil)
  end

  # Register the watcher with Rails so it checks for updates on every request/reload.
  Rails.application.reloaders << watcher
end
