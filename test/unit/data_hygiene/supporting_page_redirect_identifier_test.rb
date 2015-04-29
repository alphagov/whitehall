require 'test_helper'

module DataHygiene
  class SupportingPageRedirectIdentifierTest < ActiveSupport::TestCase
    test "generates redirect to the heading corresponding with the supporting page in the generated publication" do
      policy = create(:published_policy, id: 228679)
      replacement_publication = create(:published_publication, id: 489746)
      html_attchment = replacement_publication.attachments.first
      first_supporting_page = create(:published_supporting_page, title: 'Some supporting page', related_policies: [policy])
      second_supporting_page = create(:published_supporting_page, title: 'Another supporting page', related_policies: [policy])

      first_expected_url = Whitehall.url_maker.publication_html_attachment_url(
                      replacement_publication.document,
                      html_attchment,
                      anchor: 'appendix-1-some-supporting-page')

      second_expected_url = Whitehall.url_maker.publication_html_attachment_url(
                      replacement_publication.document,
                      html_attchment,
                      anchor: 'appendix-2-another-supporting-page')

      assert_equal first_expected_url,
        SupportingPageRedirectIdentifier.new(first_supporting_page, policy).redirect_url

      assert_equal second_expected_url,
        SupportingPageRedirectIdentifier.new(second_supporting_page, policy).redirect_url
    end
  end
end
