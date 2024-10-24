module DataHygiene
  # Repoints a landing page document to new_base_path.
  #
  # This has to be slightly different than doing it for a normal edition because
  # landing_page documents have a base_path in the slug field, and that has to have
  # slightly different validations. It also currently doesn't appear in the Whitehall
  # search index, so override search index calls to no-ops.
  #
  # When run, the following happens:
  #
  #  - changes the documents new_base_path
  #  - republishes the document to Publishing API (automatically handles the redirect)
  #
  class LandingPageRepather < DocumentReslugger
  private

    def remove_from_search_index; end

    def add_to_search_index; end

    def add_errors_if_invalid
      document.errors.add(:slug, "is blank") and return if new_slug.blank?

      document.errors.add(:slug, "must be unique") and return if new_slug_is_a_duplicate

      document.errors.add(:slug, "must start with a slash") unless new_slug.starts_with?("/")
    end

    def create_editorial_remark
      published_edition.editorial_remarks.create!(
        body: "Updated document base path to #{document.slug}",
        author: current_user,
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
      )
    end
  end
end
