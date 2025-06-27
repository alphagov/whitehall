module PublishingApi
  module PayloadBuilder
    class FlexiblePageContent
      def initialize(schema, page)
        @schema = schema
        @page = page
      end

      def call
        present_content(@schema, @page.flexible_page_content)
      end

    private

      def present_content(schema, content)
        output = {}
        schema["properties"].each do |key, property|
          case property["type"]
          when "object"
            output.merge!(key.to_sym => present_content(schema["properties"][key], content[key]))
          when "string"
            case property["format"]
            when "govspeak"
              html = Whitehall::GovspeakRenderer.new.govspeak_to_html(content[key])
              output.merge!(key.to_sym => html)
            when "image_select"
              if (matching_image = @page.images.find { |image| image.id == content[key] })
                output.merge!(key.to_sym => {
                  src: matching_image.url,
                  caption: matching_image.caption,
                  alt_text: matching_image.alt_text,
                })
              else
                Rails.logger.warning("Flexible page with ID #{@page.id} does not have an image with ID #{content[key]}, so the image has been excluded from the Publishing API payload.")
              end
            else
              output.merge!(key.to_sym => content[key])
            end
          else
            raise "Unknown property type #{property['type']}"
          end
        end
        output
      end
    end
  end
end
