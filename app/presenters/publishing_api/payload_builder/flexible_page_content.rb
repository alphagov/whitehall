module PublishingApi
  module PayloadBuilder
    class FlexiblePageContent
      def initialize(schema, content)
        @schema = schema
        @content = content
      end

      def call
        present_content(@schema, @content)
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
