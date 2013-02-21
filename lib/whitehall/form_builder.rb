module Whitehall
  class FormBuilder < ActionView::Helpers::FormBuilder
    def errors
       return unless object.errors.any?
       error_list = @template.content_tag(:ul, "class" => "errors disc") do
         object.errors.full_messages.each do |msg|
           @template.concat @template.content_tag(:li, msg)
         end
       end
       @template.content_tag(:div, "class" => "alert alert-error form-errors") do
         @template.concat @template.content_tag(:p, "To save the #{object.class.name.demodulize.underscore.humanize.downcase} please fix the following issues:")
         @template.concat error_list
       end
     end

    def save_or_cancel(options={})
      @template.content_tag(:div, "class" => "form-actions") {
        @template.concat submit("Save", class: "btn btn-primary btn-large")
        @template.concat @template.content_tag(:span, "class" => "or_cancel") {
          @template.concat %{ or }
          @template.concat @template.link_to('cancel', cancel_path(options[:cancel]))
        }
      }
    end

    def text_field(method, options={})
      label_text = options.delete(:label_text)
      horizontal = options.delete(:horizontal)
      if horizontal
        horizontal_group(label(method, label_text, class: "control-label"), super(method, options), options)
      else
        label(method, label_text) + super(method, options)
      end
    end

    def text_area(method, *args)
      options = (args.last || {})
      label_text = options.delete(:label_text)
      horizontal = options.delete(:horizontal)
      if horizontal
        horizontal_group(label(method, label_text, class: "control-label"), super, options)
      else
        label(method, label_text) + super
      end
    end

    def translated_text_field(method, options = {})
      translated_input method, text_field(method, options)
    end

    def translated_text_area(method, options = {})
      translated_input method, text_area(method, options)
    end

    def untranslated_text(method, options = {})
      english_translation = object.__send__ method, :en
      @template.content_tag(:p, "English: #{english_translation}", class: "original-translation", id: "english_#{method}")
    end

    def check_box(method, options = {}, *args)
      label_text = options.delete(:label_text)
      label(method, label_text, class: "checkbox") do
        super + label_text
      end
    end

    private

    def translated_input(method, input, options = {})
      options = Locale.new(object.fixed_locale).rtl? ? {class: 'right-to-left'} : {}
      @template.content_tag :fieldset, options do
        input + untranslated_text(method)
      end
    end

    def horizontal_group(label_tag, content_tag, options = {})
      @template.content_tag(:div, class: "control-group") do
        label_tag +
        @template.content_tag(:div, class: "controls") do
          content_tag +
            (options[:help_block] ? @template.content_tag(:span, options[:help_block], class: "help-block") : "") +
            (options[:help_inline] ? @template.content_tag(:span, options[:help_inline], class: "help-inline") : "")
        end
      end
    end

    def cancel_path(path)
      return path if path
      if object.is_a?(Edition)
        object.new_record? ? @template.admin_editions_path :
                             @template.admin_edition_path(object)
      else
        object.new_record? ? @template.polymorphic_path([:admin, object.class]) :
                             @template.polymorphic_path([:admin, object])
      end
    end
  end
end
