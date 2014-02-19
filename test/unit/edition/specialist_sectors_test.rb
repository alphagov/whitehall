require 'test_helper'

class Edition::SpecialistSectorsTest < ActiveSupport::TestCase
  test '#create_draft should copy specialist sectors' do
    expected_tags = ['oil-and-gas/taxation', 'tax/corporation-tax']
    edition = create(:published_policy, specialist_sector_tags: expected_tags)

    draft = edition.create_draft(create(:policy_writer))

    assert_equal expected_tags, draft.specialist_sector_tags
  end
end
