require 'test_helper'

class RoutingLocaleTest < ActionDispatch::IntegrationTest
  [
    {
      name:            'world locations',
      expected_url:    '/government/world/spain',
      routing_options: {controller: 'world_locations', action: 'show', id: 'spain', locale: 'en'}
    },
    {
      name:            'world priorities',
      expected_url:    '/government/priority/a-world-priority',
      routing_options: {controller: 'worldwide_priorities', action: 'show', id: 'a-world-priority', locale: 'en'}
    }
  ].each do |test|
    test "matches #{test[:name]} without locale or format" do
      assert_routing test[:expected_url], test[:routing_options]
    end

    test "matches #{test[:name]} with a format" do
      assert_routing "#{test[:expected_url]}.json", test[:routing_options].merge(format: 'json')
    end

    test "matches #{test[:name]} with a given locale" do
      assert_routing "#{test[:expected_url]}.es", test[:routing_options].merge(locale: 'es')
    end

    test "matches #{test[:name]} with both a locale and format" do
      assert_routing "#{test[:expected_url]}.es.json", test[:routing_options].merge(locale: 'es', format: 'json')
    end
  end
end
