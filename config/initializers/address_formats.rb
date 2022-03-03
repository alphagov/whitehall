Whitehall::Application.config.to_prepare do
  AddressFormatter::Formatter.address_formats = YAML.load_file(Rails.root.join("config/address_formats.yml"))
end
