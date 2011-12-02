module NationApplicabilityAssertions
  private

  def assert_nation_inapplicability_fields_exist
    n = Nation.potentially_inapplicable.count
    assert_select "input[name*='document[nation_inapplicabilities_attributes]'][type='checkbox']", count: n
    assert_select "input[name*='document[nation_inapplicabilities_attributes]'][type='text']", count: n
  end

  def nation_inapplicabilities_attributes_for(nations_vs_urls, *existing_applicabilities)
    result = {}
    [Nation.scotland, Nation.wales, Nation.northern_ireland].each.with_index do |nation, index|
      h = result[index.to_s] = {
        _destroy: (nations_vs_urls.keys.include?(nation) ? "0" : "1"),
        nation_id: nation
      }
      if existing = existing_applicabilities.detect { |ea| ea.nation_id == nation.id }
        h.merge!(id: existing.id, alternative_url: existing.alternative_url)
      end
      if nations_vs_urls[nation]
        h.merge!(alternative_url: nations_vs_urls[nation])
      end
    end
    {nation_inapplicabilities_attributes: result}
  end

  def assert_nation_inapplicability_fields_set_as(attributes)
    name_fragment = "document[nation_inapplicabilities_attributes][#{attributes[:index]}]"
    if attributes[:checked]
      assert_select "input[name='#{name_fragment}[_destroy]'][type='checkbox'][checked='checked']"
    else
      refute_select "input[name='#{name_fragment}[_destroy]'][type='checkbox'][checked='checked']"
      assert_select "input[name='#{name_fragment}[_destroy]'][type='checkbox']"
    end
    if attributes[:alternative_url]
      assert_select "input[name='#{name_fragment}[alternative_url]'][value='#{attributes[:alternative_url]}']"
    end
  end
end