module GovspeakValidationTestHelper
  def should_protect_against_xss_and_content_attacks_on(factory_name, *attributes)
    attributes.each do |attribute|
      test "should protect against XSS and content attacks via #{attribute}" do
        old_skip_value = Whitehall.skip_safe_html_validation
        Whitehall.skip_safe_html_validation = false
        valid = nil
        begin
          object = build(factory_name, attribute => "<script>badThings();</script>")
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
