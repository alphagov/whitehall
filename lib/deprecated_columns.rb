module DeprecatedColumns

  # This is here to enable us to gracefully remove columns
  # in a future commit, *after* the code marking the column
  # as deprecated has been deployed
  def deprecated_columns(*names)
    cattr_accessor :deprecated_column_list do
      # default value
      names.map(&:to_s)
    end

    def columns
      super().reject { |column| deprecated_column_list.include?(column.name) }
    end

    include InstanceMethods
  end

  module InstanceMethods
    def attribute_names
      super().reject {|name| deprecated_column_list.include?(name)}
    end
  end
end