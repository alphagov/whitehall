module DeprecatedColumns
  # This is here to enable us to gracefully remove columns
  # in a future commit, *after* the code marking the column
  # as deprecated has been deployed
  def deprecated_columns(*deprecated_column_list)
    @deprecated_column_list = deprecated_column_list
    def columns
      super().reject { |column| @deprecated_column_list.include?(column.name.to_sym) }
    end
  end
end