require "test_helper"

class InflectionsTest < ActiveSupport::TestCase
  test "Freedom of information is capitalised correctly" do
    assert_equal "An FOI request", "an foi request".humanize
  end

  test "Ministerial roles are correctly pluralised correctly" do
    assert_equal "Ministers of Junk", "Minister of Junk".pluralize
  end

  test "Chancellors of things are pluralised correctly" do
    assert_equal "Chancellors of the Exchequer", "Chancellor of the Exchequer".pluralize
  end

  test "Secretaries of things are plurlised correctly" do
    assert_equal "Foreign Secretaries", "Foreign Secretary".pluralize
    assert_equal "Cabinet Secretaries", "Cabinet Secretary".pluralize
  end

  test "Call for evidence pluralises correctly" do
    assert_equal "Calls for evidence", "Call for evidence".pluralize
    assert_equal "calls_for_evidence", "call_for_evidence".pluralize
  end

  test "Call for evidence singularize correctly" do
    assert_equal "Call for evidence", "Calls for evidence".singularize
    assert_equal "call_for_evidence", "calls_for_evidence".singularize
  end

  test "Should not pluralize any other 'call' terms" do
    assert_equal "Callings", "Calling".pluralize
    assert_equal "callings", "calling".pluralize
  end
end
