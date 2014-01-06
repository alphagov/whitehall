module Whitehall
  module DocumentFilter
    class StructuredOptions
      def self.create_from_ungrouped(all_label, options_before_grouping)
        grouped = Hash.new { |hash, key| hash[key] = [] }
        options_before_grouping.each do |(text, value, group)|
          grouped[group] << [text, value]
        end
        ungrouped = grouped.delete(nil) || []

        new(all_label: all_label, grouped: grouped, ungrouped: ungrouped)
      end

      def initialize(all_label: 'All', grouped: {}, ungrouped: [])
        @all_label = all_label
        @grouped = grouped
        @ungrouped = ungrouped
      end

      def all
        [all_label, 'all']
      end
      attr_reader :grouped, :ungrouped

      def label_for(value)
        values.rassoc(value).try(:first)
      end

      def values
        [all] + ungrouped + grouped.values.flatten(1)
      end

    protected
      attr_reader :all_label
    end
  end
end
