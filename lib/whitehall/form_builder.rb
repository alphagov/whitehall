module Whitehall
  class FormBuilder < ActionView::Helpers::FormBuilder
    def errors
       return unless object.errors.any?
       error_list = @template.content_tag(:ul, "class" => "errors disc") do
         object.errors.full_messages.each do |msg|
           @template.concat @template.content_tag(:li, msg)
         end
       end
       @template.content_tag(:div, "class" => "form-errors") do
         @template.concat @template.content_tag(:p, "To save the #{object.class.name.downcase} please fix the following issues:")
         @template.concat error_list
       end
     end

    def save_or_cancel(options={})
      cancel = @template.content_tag(:span, "class" => "or_cancel") do
        @template.concat %{ or }
        @template.concat @template.link_to 'cancel', cancel_path(options[:cancel])
      end
      @template.content_tag(:fieldset, "class" => "clear") do
        @template.concat submit "Save"
        @template.concat cancel
      end
    end

    def text_field(method, options={})
      label_text = options.delete(:label_text)
      label(method, label_text) + super(method, options)
    end

    def text_area(method, *args)
      options = (args.last || {})
      options.stringify_keys!
      label_text = options.delete("label_text")
      if options.delete("help")
        help_link = @template.link_to("formatting help", "#govspeak_help", "class" => "govspeak_help")
        options["class"] = [options["class"], "govspeak"].compact.join(" ")
      else
        help_link = ""
      end
      label_tag = label(method, label_text)
      label_tag.gsub!("</label>", " #{help_link}</label>")
      label_tag.html_safe + super
    end

    def check_box(method, options = {}, *args)
      label_text = options.delete(:label_text)
      label(method, label_text, class: "for_checkbox") do
        super + label_text
      end
    end

    private

    def cancel_path(path)
      return path if path
      if object.is_a?(Document)
        object.new_record? ? @template.admin_documents_path :
                             @template.admin_document_path(object)
      else
        object.new_record? ? @template.polymorphic_path([:admin, object.class]) :
                             @template.polymorphic_path([:admin, object])
      end
    end
  end
end