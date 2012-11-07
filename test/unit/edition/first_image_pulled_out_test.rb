require 'test_helper'

class Edition::FirstImagePulledOutTest < ActiveSupport::TestCase
  class EditionWithFirstImagePulledOut < Edition
    include ::Edition::FirstImagePulledOut
  end

  include ActionDispatch::TestProcess

  test "reports that the first image is not available for adding inline" do
    assert EditionWithFirstImagePulledOut.new.image_disallowed_in_body_text?(1)
  end

  test "reports other images are not disallowed" do
    refute EditionWithFirstImagePulledOut.new.image_disallowed_in_body_text?(2)
  end
end
