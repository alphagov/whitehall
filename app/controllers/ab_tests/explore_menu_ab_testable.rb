module AbTests::ExploreMenuAbTestable
  CUSTOM_DIMENSION = 47

  ALLOWED_VARIANTS = %w[A B Z].freeze

  def explore_menu_test
    @explore_menu_test ||= GovukAbTesting::AbTest.new(
      "ExploreMenuAbTestable",
      dimension: CUSTOM_DIMENSION,
      allowed_variants: ALLOWED_VARIANTS,
      control_variant: "Z",
    )
  end

  def explore_menu_variant
    explore_menu_test.requested_variant(request.headers)
  end

  def set_explore_menu_response
    explore_menu_variant.configure_response(response) if explore_menu_testable?
  end

  def explore_menu_testable?
    explore_menu_variant.variant?("B")
  end
end
