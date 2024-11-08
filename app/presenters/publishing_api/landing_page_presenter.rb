module PublishingApi
  class LandingPagePresenter
    include Presenters::PublishingApi::UpdateTypeHelper

    attr_reader :update_type

    IMAGE_PATTERN = /^\[Image:\s*(.*?)\s*\]/

    def initialize(item, update_type: nil)
      @item = item
      @update_type = update_type || default_update_type(item)
    end

    delegate :content_id, to: :item

    def content
      {}.tap do |content|
        content.merge!(BaseItemPresenter.new(item, update_type:).base_attributes)
        content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
        content.merge!(
          description: item.summary,
          document_type:,
          public_updated_at: item.public_timestamp || item.updated_at,
          rendering_app: item.rendering_app,
          schema_name: "landing_page",
          details:,
          links: edition_links,
          auth_bypass_ids: [item.auth_bypass_id],
        )
        content.merge!(PayloadBuilder::AccessLimitation.for(item))
        content.merge!(PayloadBuilder::FirstPublishedAt.for(item))
      end
    end

    def links
      {}
    end

    def edition_links
      PayloadBuilder::Links.for(item).extract(%i[organisations])
    end

    def document_type
      "landing_page"
    end

  private

    attr_reader :item

    def details
      body = YAML.load(item.body, permitted_classes: [Date])
              .merge(PayloadBuilder::Attachments.for(item))
      extends_slug = body.delete("extends")
      if extends_slug
        extends = Document.find_by(slug: extends_slug).latest_edition
        extends_body = YAML.safe_load(extends.body, permitted_classes: [Date])
        body.reverse_merge!(extends_body)
      end

      recursively_expand_images(body.deep_symbolize_keys)
    end

    def recursively_expand_images(input)
      case input
      in { type: "hero", image: { sources: { desktop:, tablet:, mobile: } }, **rest }
        {
          type: "hero",
          image: present_hero_image(desktop, tablet, mobile),
          **recursively_expand_images(rest),
        }
      in Hash => h
        h.transform_values { recursively_expand_images(_1) }
      in Array => a
        a.map { recursively_expand_images(_1) }
      else
        input
      end
    end

    def present_hero_image(desktop, tablet, mobile)
      images = find_images(desktop, tablet, mobile)
      return { errors: ["Some image expressions weren't correctly formatted, or images could not be found"] } if images.any?(&:nil?)

      image_data = images.map(&:image_data)
      desktop_image_kind, tablet_image_kind, mobile_image_kind = image_data.map(&:image_kind)
      errors = [
        ("Some image variants hadn't finished uploading" unless image_data.all?(&:all_asset_variants_uploaded?)),
        ("Desktop image is of the wrong image kind: #{desktop_image_kind}" unless desktop_image_kind == "hero_desktop"),
        ("Tablet image is of the wrong image kind: #{tablet_image_kind}" unless tablet_image_kind == "hero_tablet"),
        ("Mobile image is of the wrong image kind: #{mobile_image_kind}" unless mobile_image_kind == "hero_mobile"),
      ].compact
      return { errors: } unless errors.empty?

      desktop_image, tablet_image, mobile_image = images

      {
        alt: present_alt_text(images),
        sources: {
          desktop: desktop_image.url(:hero_desktop_1x),
          desktop_2x: desktop_image.url(:hero_desktop_2x),
          tablet: tablet_image.url(:hero_tablet_1x),
          tablet_2x: tablet_image.url(:hero_tablet_2x),
          mobile: mobile_image.url(:hero_mobile_1x),
          mobile_2x: mobile_image.url(:hero_mobile_2x),
        },
      }
    end

    def find_images(*image_expressions)
      image_expressions.map do |image_expression|
        match = IMAGE_PATTERN.match(image_expression)
        if match.nil?
          nil
        else
          image_id = match.captures.first
          item.images.find { _1.filename == image_id }
        end
      end
    end

    def present_alt_text(images)
      unique_alt_text = images.map(&:alt_text).compact.uniq
      case unique_alt_text
      in []
        nil
      in [alt_text]
        alt_text
      in Array
        warn("Different images had different alt text, using the first option")
        unique_alt_text.first
      end
    end
  end
end
