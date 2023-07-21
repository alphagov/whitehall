Given(/^an? (world location|international delegation) "([^"]*)" exists$/) do |world_location_type, name|
  world_location = create(world_location_type.tr(" ", "_").to_sym, name:)
  # We cannot at the moment set active to be true directly on the international delegation factory, because this will trigger code for searchable
  # that requires a world location news to exist, but this has not been created yet at the point of creating the international delegation
  # Further refactoring of world locations / international delegations should fix this issue
  world_location.update!(active: true)
end
