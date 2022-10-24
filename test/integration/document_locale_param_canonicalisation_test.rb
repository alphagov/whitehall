require "test_helper"

class DocumentLocaleParamCanonicalisationTest < ActionDispatch::IntegrationTest
  # we need this because locale param might be stripped by our path
  # helpers and routing, need to test what happens if it is actually
  # there
  def with_locale_param(path, locale)
    u = Addressable::URI.parse(path)
    u.query = "locale=#{locale}"
    u.to_s
  end

  test "visiting the publication index with a spurious locale=en param will redirect to remove it" do
    canonical_path = send("publications_path")
    extra_path = with_locale_param(canonical_path, "en")
    get extra_path

    assert_redirected_to canonical_path
  end
end
