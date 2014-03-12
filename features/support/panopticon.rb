require 'gds_api/panopticon'

Before do
  GdsApi::Panopticon::Registerer.any_instance.stubs(:register)
end
