require_relative '../../test/support/content_register_helpers'

Before do
  stub_content_register_policies
end

World(ContentRegisterHelpers)
