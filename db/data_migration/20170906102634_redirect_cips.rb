class RedirectCIPs
  def redirect_all
    about_us = ::CorporateInformationPageType::AboutUs

    about_pages = ::CorporateInformationPage
      .where(corporate_information_page_type_id: about_us.id)

    about_pages.find_each do |page|
      page.available_locales.each do |locale|
        redirect_one(page, locale)
      end
    end
  end

  def redirect_one(page, locale)
    source = localised_path(page, locale, subpath: "/about")
    destination = localised_path(page, locale, subpath: "")
    redirect(source, destination, locale)

    if page.worldwide_organisation
      source = localised_path(page, locale, subpath: "/about/about")
      redirect(source, destination, locale)
    end
  end

private

  def localised_path(page, locale, subpath:)
    suffix = locale == :en ? "" : ".#{locale}"
    Whitehall.url_maker.document_path(page) + subpath + suffix
  end

  def redirect(source, destination, locale)
    content_id = lookup_content_id(source)

    if content_id
      puts "updated: #{source} --> #{destination}"
      PublishingApiRedirectWorker.new.perform(content_id, destination, locale)
    else
      puts "    new: #{source} --> #{destination}"
      content_id = SecureRandom.uuid

      new_redirect = Whitehall::PublishingApi::Redirect.new(source, [{
        path: source,
        type: "exact",
        destination: destination,
      }])

      Services.publishing_api.put_content(content_id, new_redirect.as_json)
      Services.publishing_api.publish(content_id)
    end
  end

  def lookup_content_id(base_path)
    Services.publishing_api.lookup_content_id(
      base_path: base_path,
      exclude_unpublishing_types: [],
      exclude_document_types: [],
    )
  end
end

RedirectCIPs.new.redirect_all
