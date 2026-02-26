module ConfigurableContentBlocks
  class LeadImageSelect < BaseBlock
    include Renderable
    include ActionView::Helpers::TranslationHelper

    def default_hint_text
      if !default_lead_image
        t("configurable_content_blocks.lead_image_select.default_image_hint_for_placeholder")
      elsif default_lead_image&.all_asset_variants_uploaded?
        t("configurable_content_blocks.lead_image_select.default_image_hint_for_news_image")
      elsif !default_lead_image&.all_asset_variants_uploaded?
        t("configurable_content_blocks.lead_image_select.default_image_hint_for_news_image_with_missing_variants")
      end
    end

    def custom_hint_text
      "Select a lead image. #{default_lead_image ? t('configurable_content_blocks.lead_image_select.custom_image_hint_for_news_image') : t('configurable_content_blocks.lead_image_select.custom_image_hint_for_placeholder')}"
    end

    def select_options
      [
        {
          text: "No image selected",
          value: "",
        },
      ] + @edition.images.map do |image|
        {
          text: image.filename,
          value: image.image_data.id,
          selected: image.image_data.id == value.to_i,
        }
      end
    end

    def rendered_default_image_url
      default_lead_image_url || @edition.placeholder_image_url
    end

  private

    def template_name
      "lead_image_select"
    end

    def default_lead_image
      @edition.default_lead_image
    end

    def default_lead_image_url
      default_lead_image&.url(:s300) if default_lead_image&.all_asset_variants_uploaded?
    end
  end
end
