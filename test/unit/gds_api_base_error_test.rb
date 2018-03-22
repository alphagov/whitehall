require 'test_helper'

class GdsApiBaseErrorTest < ActiveSupport::TestCase
  test 'removes raven_context method to avoid grouping unrelated exceptions' do
    refute GdsApi::BaseError.new.respond_to?(:raven_context)
  end
end
