require 'test_helper'

class ModelWithoutDeprecation
end

class ModelWithDeprecation
  extend DeprecatedColumns
  deprecated_columns :my_column
end

class WarnOnColumnRemovalTest < ActiveSupport::TestCase
  def test_remove_column_without_deprecation
    out = message_for(:model_without_deprecation, :title)

    assert out.starts_with? "WARNING: model_without_deprecation.title has not been deprecated"
  end

  def test_remove_column_from_non_existing_table
    out = message_for(:does_not_exist, :title)

    assert out.starts_with? "WARNING: Couldn't find model for table does_not_exist."
  end

  def test_remove_column_with_deprecation
    out = message_for(:model_with_deprecation, :my_column)

    assert out.starts_with? "OK: model_with_deprecation.my_column has been deprecated."
  end

private

  def message_for(table_name, column_name)
    # ActiveRecord::Migration wraps `say_with_time` around all method calls, but
    # we don't want that output in test-mode.
    silence_stream $stdout do
      ActiveRecord::Migration.new.column_deprecation_status(table_name, column_name)
    end
  end
end
