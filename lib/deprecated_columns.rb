module DeprecatedColumns

  # This is here to enable us to gracefully remove columns
  # in a future commit, *after* the code marking the column
  # as deprecated has been deployed
  def deprecated_columns(*names)
    unless self.respond_to?(:deprecated_column_list)
      class_attribute :deprecated_column_list
      self.deprecated_column_list = []
    end

    self.deprecated_column_list += names.map(&:to_s)

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
