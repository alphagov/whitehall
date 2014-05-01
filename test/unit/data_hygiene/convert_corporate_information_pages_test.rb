require 'test_helper'

module DataHygiene
  class ConvertCorporateInformationPagesTest < ActiveSupport::TestCase

    class FakeOldCIP < Struct.new(:created_at, :updated_at, :lock_version, :id,
                                  :slug, :title, :summary, :body, :type_id,
                                  :organisation, :translations, :attachments)
    end

    class FakeTranslation < Struct.new(:locale, :summary, :body, :title)
    end

    def test_convert
      now = Time.zone.now
      user = create(:user, name: 'GDS Inside Government Team')
      recruitment_type = CorporateInformationPageType.find('recruitment')
      organisation = create(:organisation)
      translations = [FakeTranslation.new(
          :fr, 'Le sommaire pour le page de recruitement',
          'Le corps pour le page de recruitement', 'Le titre')]
      attachments = [create(:file_attachment, ordering: 0),
                     create(:html_attachment, ordering: 1)]
      old_cip = FakeOldCIP.new(
          now, now, 0, 1, 'recruitment', 'Title', 'Summary for recruitment page',
          'Body for recruitment page', recruitment_type.id, organisation,
          translations, attachments)

      converter = DataHygiene::ConvertCorporateInformationPages.new
      converter.convert(old_cip)

      new_cip = CorporateInformationPage.first
      assert_kind_of Edition, new_cip
      assert_equal user, new_cip.creator
      assert_equal new_cip.document.id.to_s, new_cip.document.slug
      new_attachments = new_cip.attachments
      assert_equal 2, new_attachments.length
      assert_instance_of FileAttachment, new_attachments[0]
      assert_instance_of HtmlAttachment, new_attachments[1]
      assert_equal 'Summary for recruitment page', new_cip.summary
      original_locale = I18n.locale
      I18n.locale = :fr
      assert_equal 'Le sommaire pour le page de recruitement', new_cip.summary
      I18n.locale = original_locale
    end
  end
end
