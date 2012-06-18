module SpecialistGuideViewAssertions
  def assert_select_specialist_guide_section_link(guide, text, anchor)
    assert_select "ol#specialist_guide_sections" do
      assert_select "li a[href='#{specialist_guide_path(guide.document, anchor: anchor)}']", text: text
    end
  end

  def refute_select_specialist_guide_section_link(policy, text, anchor)
    assert_select "ol#specialist_guide_sections" do
      assert_select "li a[href='#{specialist_guide_path(guide.document, anchor: anchor)}']", text: text, count: 0
    end
  end

  def refute_select_specialist_guide_section_list
    assert_select "ol#specialist_guide_sections", count: 0
  end
end
