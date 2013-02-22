require 'test_helper'

class RoutingLocaleTest < ActionDispatch::IntegrationTest
  setup do
    @show_world_location = {controller: 'world_locations', action: 'show', id: 'spain', locale: 'en'}
    @show_world_priority = {controller: 'worldwide_priorities', action: 'show', id: 'a-world-priority', locale: 'en'}
  end

  test 'matches world locations without locale or format' do
    assert_routing '/government/world/spain', @show_world_location
  end

  test 'matches world locations with a format' do
    assert_routing '/government/world/spain.json', @show_world_location.merge(format: 'json')
  end

  test 'matches world locations with a given locale' do
    assert_routing '/government/world/spain.es', @show_world_location.merge(locale: 'es')
  end

  test 'matches world locations with both a locale and format' do
    assert_routing '/government/world/spain.es.json', @show_world_location.merge(locale: 'es', format: 'json')
  end

  test 'matches world priorities without locale or format' do
    assert_routing '/government/priority/a-world-priority', @show_world_priority
  end

  test 'matches world priorities with a format' do
    assert_routing '/government/priority/a-world-priority.json', @show_world_priority.merge(format: 'json')
  end

  test 'matches world priorities with a given locale' do
    assert_routing '/government/priority/a-world-priority.es', @show_world_priority.merge(locale: 'es')
  end

  test 'matches world priorities with both a locale and format' do
    assert_routing '/government/priority/a-world-priority.es.json', @show_world_priority.merge(locale: 'es', format: 'json')
  end
end
