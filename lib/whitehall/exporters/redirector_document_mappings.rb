class Whitehall::Exporters::RedirectorDocumentMappings < Struct.new(:platform)

  def url_maker
    @url_maker ||= Whitehall::UrlMaker.new(host: public_host, protocol: 'https')
  end

  def row(public_url, admin_url)
    [
      '',
      public_url,
      '',
      '',
      admin_url,
      ''
    ]
  end

  def public_host
    Whitehall.public_host_for("whitehall.#{platform}.alphagov.co.uk")
  end

  def admin_host
    "whitehall-admin.#{platform}.alphagov.co.uk"
  end

  def host_name
    platform == 'production' ? 'www.gov.uk' : "www.#{platform}.alphagov.co.uk"
  end

  def edition_values(edition, document, document_source = nil)
    public_url, slug = document_url_and_slug(edition, document, document_source)
    [(document_source.try(:url) || ''),
      public_url,
      http_status(edition),
      slug,
      url_maker.admin_edition_url(edition, host: admin_host),
      edition.state]
  rescue => e
    Rails.logger.error("Whitehall::Exporters::RedirectorDocumentMappings: when exporting #{edition} - #{e} - #{e.backtrace.join("\n")}")
    nil
  end

  def document_slug(edition, document)
    if edition.pre_publication? && edition.unpublishing.present?
      edition.unpublishing.slug
    elsif edition.is_a?(CorporateInformationPage)
      edition.slug
    else
      document.slug
    end
  end

  def document_url_and_slug(edition, document, document_source)
    doc_url_args = { }
    if edition.translatable?
      locale = document_source.try(:locale)
      doc_url_args[:locale] = locale unless locale.nil? || Locale.new(locale).english?
    end

    slug = document_slug(edition, document)
    [
      url_maker.document_url(edition, doc_url_args.merge(id: slug)),
      slug
    ]
  end

  def http_status(edition)
    if edition.document.published? || any_edition_has_ever_been_published?(edition)
      '301'
    else
      '418'
    end
  end

  def any_edition_has_ever_been_published?(edition)
    edition.document.editions.any? do |edition|
      edition.versions.any? {|v| v.state == "published" }
    end
  end

  def export(target)
    target << ['Old Url', 'New Url', 'Status', 'Slug', 'Admin Url', 'State']
    Document.find_each do |document|
      document.editions.each do |edition|
        if document.document_sources.any?
          document.document_sources.each do |source|
            edition_values(edition, document, source).tap do |row|
              target << row if row
            end
          end
        else
          edition_values(edition, document).tap do |row|
            target << row if row
          end
        end
      end
    end

    ###### ATTACHMENT SOURCES

    AttachmentSource.all.each do |attachment_source|
      attachment_url = attachment_source.attachment ? 'https://' + host_name + attachment_source.attachment.url : ""
      status = (attachment_url.blank? ? '' : '301')
      if attachment_url.present?
        visibility = AttachmentVisibility.new(attachment_source.attachment.attachment_data, nil)
        state = visibility.visible? ? 'published' : 'draft'
        target << [attachment_source.url, attachment_url, status, '', '', state]
      end
    end

    Person.find_each do |person|
      target << row(
        url_maker.person_url(person, host: host_name),
        url_maker.admin_person_url(person, host: admin_host)
      )
      target << row(
        url_maker.person_url(person, host: host_name),
        url_maker.edit_admin_person_url(person, host: admin_host),
      )
    end

    PolicyGroup.find_each do |group|
      target << row(
        url_maker.policy_group_url(group, host: host_name),
        url_maker.admin_policy_group_url(group, host: admin_host)
      )
      target << row(
        url_maker.policy_group_url(group, host: host_name),
        url_maker.edit_admin_policy_group_url(group, host: admin_host)
      )
    end

    Role.find_each do |role|
      target << row(
        url_maker.ministerial_role_url(role, host: host_name),
        url_maker.admin_role_url(role, host: admin_host),
      )
      target << row(
        url_maker.ministerial_role_url(role, host: host_name),
        url_maker.edit_admin_role_url(role, host: admin_host),
      )
    end

    Organisation.find_each do |organisation|
      target << row(
        url_maker.organisation_url(organisation, host: host_name),
        url_maker.admin_organisation_url(organisation, host: admin_host),
      )
      target << row(
        url_maker.organisation_url(organisation, host: host_name),
        url_maker.edit_admin_organisation_url(organisation, host: admin_host),
      )
    end
  end
end
