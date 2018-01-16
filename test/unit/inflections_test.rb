require 'test_helper'

class InflectionsTest < ActiveSupport::TestCase
  test 'Freedom of information is capitalised correctly' do
    assert_equal 'An FOI request', 'an foi request'.humanize
  end

  test 'Ministerial roles are correctly pluralised correctly' do
    assert_equal 'Ministers of Junk', 'Minister of Junk'.pluralize
  end

  test 'Chancellors of things are pluralised correctly' do
    assert_equal 'Chancellors of the Exchequer', 'Chancellor of the Exchequer'.pluralize
  end

  test 'Secretaries of things are plurlised correctly' do
    assert_equal 'Foreign Secretaries', 'Foreign Secretary'.pluralize
    assert_equal 'Cabinet Secretaries', 'Cabinet Secretary'.pluralize
  end
end
