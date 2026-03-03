module ConfigurableContentBlockSharedTests
  def test_it_does_not_render_if_the_edition_is_a_translation_and_the_field_is_not_translatable
    @field["translatable"] = false
    with_locale(:es) do
      html = render @block
      assert_empty html
    end
    @field["translatable"] = true
  end
end
