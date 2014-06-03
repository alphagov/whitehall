require 'test_helper'

module Whitehall
  module DocumentFilter
    class StructuredOptionsTest < ActiveSupport::TestCase
      test "::create_from_ungrouped groups options where possible" do
        options = StructuredOptions.create_from_ungrouped('All', [
          %w(label1 slug1 group1),
          %w(label2 slug2 group1),
          %w(label3 slug3 group2),
          ['label4', 'slug4', nil]
        ])

        expected_grouped_options = {
          'group1' => [%w(label1 slug1), %w(label2 slug2)],
          'group2' => [%w(label3 slug3)]
        }
        assert_equal expected_grouped_options, options.grouped

        assert_equal [%w(label4 slug4)], options.ungrouped
      end
    end
  end
end
