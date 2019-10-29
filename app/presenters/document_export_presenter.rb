class DocumentExportPresenter < Whitehall::Decorators::Decorator
  include GovspeakHelper

  def as_json
    {
      document: model,
      editions: editions,
    }
  end

  private

  def editions
    model.editions.map do |edition|
      edition_associations(edition)
    end
  end

  def edition_associations(edition)
    output = {
               edition: edition,
               associations: {},
             }

    associations = edition.class.reflect_on_all_associations.map(&:name)
    associations.each do |association|
      if association == :images
        edition_images = edition.public_send(association)
        output[:associations][association] = complete_images_hash(edition_images)
      elsif association == :attachments
        edition_attachments = edition.public_send(association)
        output[:associations][association] = complete_attachments_hash(edition_attachments)
      else
        output[:associations][association] = edition.public_send(association)
      end
    end

    provide_doctype_information(edition, output)
    output[:government] = edition.government
    output[:whitehall_admin_links] = resolve_whitehall_admin_links(edition.body)
    if edition.withdrawn?
      output[:whitehall_admin_links].concat(resolve_whitehall_admin_links(edition.unpublishing.explanation))
    end

    output[:edition] = present_edition(output[:edition], output[:associations][:translations])
    output
  end

  def complete_images_hash(edition_images)
    edition_images.map do |image|
      image.as_json(methods: :url)
    end
  end

  def complete_attachments_hash(edition_attachments)
    edition_attachments.map do |attachment|
      attachment.as_json(include: :attachment_data, methods: %i[url type]).tap do |json|
        json.merge!("govspeak_content" => attachment.govspeak_content.as_json) if attachment.respond_to?(:govspeak_content)
      end
    end
  end

  def present_edition(edition, translations)
    edition = translate_ids_to_descriptive_values(edition)
    remove_fields_that_exist_in_translations(edition, translations)
  end

  def translate_ids_to_descriptive_values(edition)
    new_field_names = %w[
      news_article_type
      corporate_information_page_type
      speech_type
      publication_type
    ]
    new_field_names.reduce(edition.as_json) do |memo, new_field_name|
      if edition["#{new_field_name}_id"].present?
        memo.delete("#{new_field_name}_id")
        memo[new_field_name] = edition.send(new_field_name)&.key
      end
      memo
    end
  end

  def remove_fields_that_exist_in_translations(edition, translations = [])
    translation = translations.find { |lang| lang["locale"] == edition["primary_locale"] }
    return edition unless translation.present?

    edition.as_json(except: translation.as_json.keys)
  end

  def provide_doctype_information(edition, output)
    %i[news_article_type publication_type corporate_information_page_type speech_type].each do |type|
      output[type] = edition.public_send(type)&.key if edition.respond_to?(type)
    end
  end

  def resolve_whitehall_admin_links(body)
    whitehall_admin_links(body).map do |link|
      { whitehall_admin_url: link, public_url: public_url_for_admin_link(link) }
    end
  end

  def public_url_for_admin_link(url)
    edition = Whitehall::AdminLinkLookup.find_edition(url)
    Whitehall.url_maker.public_document_url(edition) if edition.present?
  end
end
