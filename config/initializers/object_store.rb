require "object_store"

config_file_path = Rails.root.join("config/object_store/fields.yml")

ObjectStore.configure do |config|
  config.fields = YAML.safe_load(File.read(config_file_path))
end
