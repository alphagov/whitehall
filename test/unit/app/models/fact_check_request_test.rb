require "test_helper"

class FactCheckRequestTest < ActiveSupport::TestCase
  test "should be invalid without a edition" do
    fact_check_request = build(:fact_check_request, edition: nil)
    assert_not fact_check_request.valid?
  end

  test "should be invalid with a mangled email address" do
    fact_check_request = build(:fact_check_request, email_address: "not-a-valid-email")
    assert_not fact_check_request.valid?
  end

  test "should be invalid without a requestor" do
    fact_check_request = build(:fact_check_request, requestor: nil)
    assert_not fact_check_request.valid?
  end

  test "sets a 16 character random key during initialization" do
    keys = 100.times.collect { FactCheckRequest.new.key }
    assert_equal 100, keys.compact.uniq.size
    assert_equal [16], keys.collect(&:length).uniq
    assert_not_equal keys.sort, keys
    assert_not_equal keys.sort.reverse, keys
  end

  test "doesn't allow key to change via setter" do
    request = create(:fact_check_request)
    original_key = request.key
    request.key = "new-key"
    assert_equal original_key, request.key
  end

  test "doesn't allow key to change via updating attributes" do
    request = create(:fact_check_request)
    original_key = request.key
    request.update!(key: "new-key")
    assert_equal original_key, request.key
  end

  test "ensures chosen key is unique" do
    fact_check_request = create(:fact_check_request)
    FactCheckRequest.stubs(:random_key).returns(fact_check_request.key).then.returns("2nd-key")
    assert_equal "2nd-key", FactCheckRequest.new.key
  end
end
