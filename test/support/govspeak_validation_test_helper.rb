module GovspeakValidationTestHelper
  def should_protect_against_xss_and_content_attacks_on(*attributes, supplied_factory_name)
    attributes.each do |attribute|
      test "should protect against XSS and content attacks via #{attribute}" do
        old_skip_value = Whitehall.skip_safe_html_validation
        Whitehall.skip_safe_html_validation = false
        valid = nil
        begin
          bad_attribute = "<script>badThings();</script>"
          object = if supplied_factory_name
                     build(supplied_factory_name, attribute => bad_attribute)
                   else
                     build(factory_name_from_test, attribute => bad_attribute)
                   end
          valid = object.valid?
        ensure
          Whitehall.skip_safe_html_validation = old_skip_value
        end
        assert_not valid, "should be invalid with unsafe content"
        assert object.errors[attribute].include?("cannot include invalid formatting or JavaScript"), "didn't add validation errors to #{attribute} attribute"
      end
    end
  end
end
