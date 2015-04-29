module DataHygiene
  # Used to identify the appropriate redirect URL for a policy supporting page.
  #
  # Supporting pages are to be redirected to the corresponding heading in the
  # HTML publication that was generated to archive the policy.
  #
  # Note: Can be removed after the migration to new policies has been complete.
  class SupportingPageRedirectIdentifier

    def initialize(supporting_page, policy)
      @supporting_page = supporting_page
      @policy = policy
    end

    def redirect_url
      Whitehall.url_maker.publication_html_attachment_url(
        publication.document,
        html_attchment,
        anchor: supporting_page_anchor)
    end

  private
    attr_reader :supporting_page, :policy

    def publication
      @publication ||= PolicyToPaperMapper.new.publication_for(policy)
    end

    def html_attchment
      publication.html_attachments.first
    end

    def supporting_page_anchor
      # Matches the headings as generated here:
      # https://github.com/alphagov/whitehall/blob/master/db/data_migration/20150407095340_convert_policies_to_html_publications.rb#L40
      generate_id "Appendix #{appendix_index}: #{supporting_page.title}"

    end

    def appendix_index
      policy.published_supporting_pages.index(supporting_page) + 1
    end

    def anchor_text
      supporting_page.title.parameterize
    end

    # Trimmed down version of the code that generates ids in the kramdown gem:
    # https://github.com/gettalong/kramdown/blob/REL_1_4_2/lib/kramdown/converter/base.rb#L203
    def generate_id(str)
      gen_id = str.gsub(/^[^a-zA-Z]+/, '')
      gen_id.tr!('^a-zA-Z0-9 -', '')
      gen_id.tr!(' ', '-')
      gen_id.downcase!
    end
  end
end
