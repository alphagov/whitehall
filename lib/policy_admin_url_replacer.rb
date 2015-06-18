# This can be deleted once db/data_migration/20150615092751_replace_policy_admin_links.rb is done with.
class PolicyAdminURLReplacer
  def self.replace_in!(edition_scope)
    self.new.replace_in!(edition_scope)
  end

  def replace_in!(edition_scope)
    edition_scope.find_each do |edition|
      edition.body = replace_short_form(edition.body, edition.id)
      edition.body = replace_long_form(edition.body, edition.id)
      edition.save
    end
  end

private

  def replace_short_form(text, edition_id)
    short_form_regex = %r{\[([^\]]+)\]\([^(]+/admin/(?:editions|policies|supporting-pages)/([^)/ ]+?)( [^)]+)?\)}
    text.gsub(short_form_regex) {|admin_url|
      link_text = $1
      id_or_slug = $2
      possible_title_text = $3

      get_replacement(
        id_or_slug: id_or_slug,
        possible_title_text: possible_title_text,
        link_text: link_text,
        original: admin_url,
        edition_id: edition_id,
      )
    }
  end

  def replace_long_form(text, edition_id)
    long_form_regex = %r{\[([^\]]+)\]\([^(]+/admin/(?:editions|policies)/(?:[^)/ ]+?)/supporting-pages/([^)/ ]+)( [^)]+)?\)}
    text.gsub(long_form_regex) {|admin_url|
      link_text = $1
      sp_id = $2
      possible_title_text = $3
      # Map from old non-editioned supporting pages to new ones.
      if sp_id =~ /^\d+$/ && new_id = EditionedSupportingPageMapping.where(old_supporting_page_id: sp_id).last.try(:new_supporting_page_id)
        id_or_slug = new_id.to_s
      else
        id_or_slug = sp_id
      end

      get_replacement(
        id_or_slug: id_or_slug,
        possible_title_text: possible_title_text,
        link_text: link_text,
        original: admin_url,
        edition_id: edition_id,
      )
    }
  end

  def get_replacement(id_or_slug:, possible_title_text:, link_text:, original:, edition_id:)
    if replacement_url = id_to_url_mapping[id_or_slug]
      replacement = "[#{link_text}](#{replacement_url}#{possible_title_text})"
    else
      replacement = link_text
    end

    puts "Edition #{edition_id}: #{original} -> #{replacement}"
    return replacement
  end

  def id_to_url_mapping
    return @id_to_url_mapping if @id_to_url_mapping

    puts "Building ID/slug to URL mapping"

    policies_and_supporting_pages = Edition.unscoped.where(type: ["Policy", "SupportingPage"])

    @id_to_url_mapping = policies_and_supporting_pages.inject({}) {|hash, edition|
      url = Whitehall.url_maker.public_document_url(edition, {}, include_deleted_documents: true)

      hash.merge(
        edition.id.to_s => url,
        edition.slug => url,
      )
    }
  end
end
