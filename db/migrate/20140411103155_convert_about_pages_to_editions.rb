class ConvertAboutPagesToEditions < ActiveRecord::Migration
  # default title text for validation only.
  CorporateInformationPage.class_eval do
    def title
      "title"
    end
    def body_required?
      false
    end
  end
  Whitehall.skip_safe_html_validation = true
  @@gds_ig_team_user = User.find_by_name!('GDS Inside Government Team')
  @@about_type = CorporateInformationPageType.find('about')

  def up
    @logger = Logger.new(STDOUT)
    transaction do
      Organisation.with_translations.find_each { |org| convert_org(org) }
      WorldwideOrganisation.with_translations.find_each { |org| convert_org(org) }
    end
  end

  def convert_org(org)
    puts "Migrating #{org.name}"
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

    new_cip = CorporateInformationPage.create!(
      created_at: org.created_at,
      updated_at: org.updated_at,
      document_id: doc.id,
      creator: @@gds_ig_team_user,
      title: 'What we do',
      summary: summary,
      body: body,
      corporate_information_page_type_id: @@about_type.id,
      major_change_published_at: org.updated_at,
      state: 'published')
    if org.is_a? Organisation
      EditionOrganisation.create!(
        edition: new_cip,
        organisation: org
      )
    else
      EditionWorldwideOrganisation.create!(
        edition: new_cip,
        worldwide_organisation: org
      )
    end
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
    Edition.where(corporate_information_page_type_id: @@about_type.id).find_each {|edition| edition.document.destroy }
  end
end
