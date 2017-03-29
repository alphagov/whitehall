require 'test_helper'

module DataHygiene
  class CopyrightImageCaptionsTest < ActiveSupport::TestCase
    def test_already_copyrighted
      assert_caption "© Some paparazzi", caption: "© Some paparazzi"
      assert_caption "Copyright Some paparazzi", caption: "Copyright Some paparazzi"
      assert_caption "All rights reserved Some paparazzi", caption: "All rights reserved Some paparazzi"
      assert_caption "All Rights Reserved.", caption: "All Rights Reserved."
    end

    def test_logo
      assert_caption "", alt_text: "MOD Announcement", caption: ""
      assert_caption "", alt_text: "MOD crest", caption: ""
      assert_caption "", alt_text: "Ministry of Defence", caption: ""
      assert_caption "", alt_text: "army", caption: ""
    end

    def test_add_copyright
      assert_caption "Major Smith [Picture: MOD]\n© All rights reserved",
                     caption: "Major Smith [Picture: MOD]"
      assert_caption "Major Smith\n[Picture: MOD]\n© All rights reserved",
                     caption: "Major Smith\n[Picture: MOD]"
      assert_caption "Major Smith\n\n[Picture: MOD]\n© All rights reserved",
                     caption: "Major Smith\n\n[Picture: MOD]"
      assert_caption "Major Smith [Picture: MOD]\n© All rights reserved",
                     caption: "Major Smith [Picture: MOD]\n"
      assert_caption "Major Smith [Picture: via family]\n© All rights reserved",
                     caption: "Major Smith [Picture: via family]\n"
    end

    private

    def assert_caption(expected_caption, caption: nil, alt_text: nil)
      result = CopyrightImageCaptions.new.sanitize_caption(
        Image.new(caption: caption, alt_text: alt_text))
      assert_equal expected_caption, result.caption
    end
  end
end
