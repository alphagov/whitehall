GDS_IG_TEAM_USER = User.find_by_name!('GDS Inside Government Team')
ABOUT_TYPE = CorporateInformationPageType.find('about')

class ConvertAboutPagesToEditions < ActiveRecord::Migration
  CorporateInformationPage.class_eval do
    def body_required?
      false
    end
  end
  Whitehall.skip_safe_html_validation = true

  def up
    @logger = Logger.new(STDOUT)
    Organisation.with_translations.find_each { |org| convert_org(org) }
    WorldwideOrganisation.with_translations.find_each { |org| convert_org(org) }
  end

  def convert_org(org)
    @logger.info "Migrating #{org.name}"
    doc = Document.create!(document_type: 'CorporateInformationPage',
                           created_at: org.created_at,
                           updated_at: org.updated_at)
    if org.is_a? Organisation
      summary = org.translation.description
      body = org.translation.about_us
    else
      summary = org.translation.summary
      body = org.translation.description
      if org.translation.services.present?
        body << "\r\n\r\n# Our services\r\n\r\n#{org.translation.services}"
      end
    end

    new_cip = org.build_corporate_information_page(
      updated_at: org.updated_at,
      document_id: doc.id,
      creator: GDS_IG_TEAM_USER,
      summary: summary,
      body: body,
      corporate_information_page_type_id: ABOUT_TYPE.id,
      major_change_published_at: org.updated_at,
      state: 'published')
    new_cip.save!
    org.translations.each do |old_trans|
      unless old_trans.locale == :en
        if org.is_a? Organisation
          summary = old_trans.description
          body = old_trans.about_us
        else
          summary = old_trans.summary
          body = old_trans.description
          if old_trans.services.present?
            heading = I18n.t('worldwide_organisation.headings.our_services', locale: old_trans.locale)
            body << "\r\n\r\n# #{heading}\r\n\r\n#{old_trans.services}"
          end
        end

        new_cip.translations.create!(
          locale: old_trans.locale,
          summary: summary,
          body: body,
          title: 'What we do'
        )
      end
    end
  end

  def down
    Edition.where(corporate_information_page_type_id: ABOUT_TYPE.id).find_each {|edition| edition.document.destroy }
  end
end
