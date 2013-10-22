module Whitehall
  class FormBuilder < ActionView::Helpers::FormBuilder

    def label(method, text=nil, options={}, &block)
      if calculate_required(method, options)
        unless !options[:required].nil? && options[:required] == false
          options[:class] ||= ""
          class_override = options[:class] << " required"
          options.merge!(class: class_override.strip)
          text_override = text ? text : method.to_s.humanize
          text = "#{text_override}<span>*</span>".html_safe
        end
      end
      options.delete(:required)
      label_tag = super(method, text, options)
    end

    def labelled_radio_button(label_text, *radio_button_args)
      # 2nd arg is either all the args for the radio_button, or an options
      # hash for the label, then all the args for the radio_button.
      label_opts = {class: 'radio inline'}
      label_opts = label_opts.merge(radio_button_args.shift) if radio_button_args.first.is_a?(Hash)
      @template.label_tag(nil, label_opts) do
        radio_button(*radio_button_args)+ " #{label_text}"
      end
    end

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

    def form_actions(options={})
      @template.content_tag(:div, "class" => "form-actions") {
        options[:buttons].each do |name, value|
          @template.concat submit(value, name: name, class: "btn btn-primary btn-large")
        end
        @template.concat @template.content_tag(:span, "class" => "or_cancel") {
          @template.concat %{ or }
          @template.concat @template.link_to('cancel', cancel_path(options[:cancel]))
        }
      }
    end

    def save_or_cancel(options = {})
      form_actions(options.merge(buttons: { save: 'Save' }))
    end

    def save_or_continue_or_cancel(options = {})
      buttons = { save: 'Save', save_and_continue: 'Save and continue editing' }
      form_actions(options.merge(buttons: buttons))
    end

    def text_field(method, options={})
      horizontal = options.delete(:horizontal)
      label_options = { required: options.delete(:required) }
      label_text = options.delete(:label_text)
      if horizontal
        label_options[:class] = "control-label"
        horizontal_group(label(method, label_text, label_options), super(method, options), options)
      else
        label(method, label_text, label_options) + super(method, options)
      end
    end

    def text_area(method, *args)
      options = (args.last || {})
      horizontal = options.delete(:horizontal)
      label_options = { required: options.delete(:required) }
      label_text = options.delete(:label_text)
      if horizontal
        label_options[:class] = "control-label"
        horizontal_group(label(method, label_text, label_options), super, options)
      else
        label(method, label_text, label_options) + super
      end
    end

    def translated_text_field(method, options = {})
      translated_input method, text_field(method, translated_input_options(options))
    end

    def translated_text_area(method, options = {})
      translated_input method, text_area(method, translated_input_options(options))
    end

    def untranslated_text(method, options = {})
      english_translation = object.__send__ method, :en
      @template.content_tag(:p, "English: #{english_translation}", class: "original-translation", id: "english_#{method}")
    end

    def check_box(method, options = {}, *args)
      horizontal = options.delete(:horizontal)
      label_options = { required: options.delete(:required) }
      label_text = options.delete(:label_text) || method.to_s.humanize
      if horizontal
        label_options[:class] = "control-label"
        horizontal_group(label(method, label_text, label_options), super, options)
      else
        label(method, label_text, label_options.merge(class: "checkbox")) { super + label_text }
      end
    end

    def upload(method, options={})
      horizontal = options.delete(:horizontal)
      label_options = { required: options.delete(:required) }
      label_text = options.delete(:label_text)
      allow_removal = options.delete(:allow_removal) || false
      allow_removal_label_text = options.delete(:allow_removal_label_text) || "Check to remove #{method.to_s.humanize.downcase}"

      fields = file_field(method, options)
      if object.respond_to?(:"#{method}_cache") && object.send("#{method}_cache").present?
        fields += file_cache_already_uploaded(method)
      end
      fields += hidden_field("#{method}_cache")
      if allow_removal
        fields += check_box(:"remove_#{method}", label_text: allow_removal_label_text)
      end

      if horizontal
        label_options[:class] = "control-label"
        horizontal_group(label(method, label_text, label_options), fields, options)
      else
        label(method, label_text, label_options) + fields
      end
    end

    private

    def has_validators?(method)
      @has_validators ||= method && object.class.respond_to?(:validators_on)
    end

    def calculate_required(method, options)
      if !options[:required].nil?
        options[:required]
      elsif has_validators?(method)
        required_by_validators?(method)
      else
        false
      end
    end

    def required_by_validators?(method)
      (attribute_validators(method)).any? { |v| v.kind == :presence && valid_validator?(v) }
    end

    def attribute_validators(method)
      object.class.validators_on(method)
    end

    def valid_validator?(validator)
      !conditional_validators?(validator) && action_validator_match?(validator)
    end

    def conditional_validators?(validator)
      validator.options.include?(:if) || validator.options.include?(:unless)
    end

    def action_validator_match?(validator)
      return true if !validator.options.include?(:on)

      case validator.options[:on]
      when :save
        true
      when :create
        !object.persisted?
      when :update
        object.persisted?
      end
    end

    def find_validator(kind)
      attribute_validators.find { |v| v.kind == kind } if has_validators?
    end

    def right_to_left?
      Locale.new(object.fixed_locale).rtl?
    end

    def translated_input(method, input, options = {})
      options = right_to_left? ? {class: 'right-to-left'} : {}
      @template.content_tag :fieldset, options do
        input + untranslated_text(method)
      end
    end

    def translated_input_options(options)
      if right_to_left?
        options.merge(dir: 'rtl')
      else
        options
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

    def file_cache_already_uploaded(method)
      @template.content_tag(:span, "#{File.basename(object.send("#{method}_cache"))} already uploaded", class: 'already_uploaded')
    end
  end
end
