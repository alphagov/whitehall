require 'test_helper'

class FactCheckRequestTest < ActiveSupport::TestCase

  test 'should be valid when built from the factory' do
    fact_check_request = build(:fact_check_request)
    assert fact_check_request.valid?
  end

  test 'should be invalid without a document' do
    fact_check_request = build(:fact_check_request, document: nil)
    refute fact_check_request.valid?
  end
  
  test 'should not allow the token to be changed' do
    fact_check_request = create(:fact_check_request)
    original_token = fact_check_request.token
    fact_check_request.token = 'new-token'
    fact_check_request.save!
    assert_equal original_token, fact_check_request.token
  end
  
  test 'should generate different tokens for different fact check requests' do
    fact_check_request_1 = create(:fact_check_request)
    fact_check_request_2 = create(:fact_check_request)
    refute_equal fact_check_request_1, fact_check_request_2
  end
  
  test 'should generate a token on creation' do
    fact_check_request = build(:fact_check_request, token: nil)
    fact_check_request.save!
    refute_nil fact_check_request.token
  end

end