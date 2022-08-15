module Whitehall
  class FormBuilder < ActionView::Helpers::FormBuilder
    include Admin::AnalyticsHelper

    def label(method, text = nil, options = {})
      if calculate_required(method, options) && !(!options[:required].nil? && options[:required] == false)
        add_class_to_options(options, "required")
        text_override = text || method.to_s.humanize
        text = "#{text_override}<span>*</span>".html_safe
      end
      options.delete(:required)
      super(method, text, options)
    end

    def labelled_radio_button(label_text, *radio_button_args)
      # 2nd arg is either all the args for the radio_button, or an options
      # hash for the label, then all the args for the radio_button.
      label_opts = {}
      label_opts = label_opts.merge(radio_button_args.shift) if radio_button_args.first.is_a?(Hash)

      @template.tag.div(class: "radio") do
        @template.label_tag(nil, label_opts) do
          radio_button(*radio_button_args) + label_text
        end
      end
    end

    def errors
      return unless object.errors.any?

      @template.tag.div(class: "alert alert-danger form-errors") do
        @template.concat @template.tag.p("To save the #{object.class.name.demodulize.underscore.humanize.downcase} please fix the following issues:")
        @template.concat error_list
      end
    end

    def error_list
      @template.tag.ul(class: "errors disc") do
        analytics_action = "#{object.class.name.demodulize.underscore.dasherize}-error"
        object.errors.full_messages.each do |msg|
          @template.concat @template.tag.li(msg, data: track_analytics_data("form-error", analytics_action, msg))
        end
      end
    end

    def form_actions(options = {})
      @template.tag.div(class: "form-actions", data: { module: "track-button-click", "track-category" => "form-button", "track-action" => "#{object.class.name.demodulize.underscore.dasherize}-button" }) do
        options[:buttons].each do |name, value|
          @template.concat submit(value, name: name, class: "btn btn-primary btn-lg")
        end
        @template.concat @template.tag.span(class: "or_cancel") {
          @template.concat %( or )
          @template.concat @template.link_to("cancel", cancel_path(options[:cancel]))
        }
      end
    end

    def save_or_cancel(options = {})
      form_actions(options.reverse_merge(buttons: { save: "Save" }))
    end

    def save_or_cancel_buttons(options = {})
      @template.tag.div(class: "form-actions") do
        options[:buttons].each do |name, value|
          @template.concat submit(value, name: name, class: "btn btn-lg btn-primary")
        end
        @template.concat @template.link_to("Cancel", cancel_path(options[:cancel]), class: "btn btn-default btn-lg add-left-margin")
      end
    end

    def save_or_continue_or_cancel(options = {})
      buttons = { save: "Save", save_and_continue: "Save and continue" }
      form_actions(options.reverse_merge(buttons: buttons))
    end

    def text_field(method, options = {})
      add_class_to_options(options, "form-control")
      label_options = { required: options.delete(:required) }
      label_text = options.delete(:label_text)

      @template.tag.div(class: "form-group") do
        label(method, label_text, label_options) + super(method, options)
      end
    end

    def text_area(method, *args)
      options = (args.last || {})
      label = options.delete(:label)
      add_class_to_options(options, "form-control")

      if label == false
        @template.tag.div(class: "form-group") do
          super
        end
      else
        label_options = { required: options.delete(:required) }
        label_text = options.delete(:label_text)

        @template.tag.div(class: "form-group") do
          label(method, label_text, label_options) + super
        end
      end
    end

    def translated_text_field(method, options = {})
      translated_input method, text_field(method, translated_input_options(options))
    end

    def translated_text_area(method, options = {})
      translated_input method, text_area(method, translated_input_options(options))
    end

    def untranslated_text(method, _options = {})
      english_translation = object.__send__ method, :en
      @template.tag.p("English: #{english_translation}", class: "original-translation", id: "english_#{method}")
    end

    def check_box(method, options = {}, *args)
      label_options = { required: options.delete(:required) }
      label_text = options.delete(:label_text) || method.to_s.humanize

      @template.tag.div(class: "checkbox") do
        label(method, label_text, label_options) { super + label_text }
      end
    end

    def upload(method, options = {})
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

      @template.tag.div(class: "form-group") do
        label(method, label_text, label_options) + fields
      end
    end

  private

    def add_class_to_options(options, name)
      options[:class] ||= ""
      class_override = options[:class] << " #{name}"
      options.merge!(class: class_override.strip)
    end

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
      attribute_validators(method).any? { |v| v.kind == :presence && valid_validator?(v) }
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
      return true unless validator.options.include?(:on)

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

    def translated_input(method, input, _options = {})
      options = right_to_left? ? { class: "right-to-left" } : {}
      @template.tag.fieldset(**options) do
        input + untranslated_text(method)
      end
    end

    def translated_input_options(options)
      if right_to_left?
        options.merge(dir: "rtl")
      else
        options
      end
    end

    def cancel_path(path)
      return path if path

      if object.new_record?
        case object
        when CorporateInformationPage
          @template.polymorphic_path([:admin, object.owning_organisation, CorporateInformationPage])
        when Edition
          @template.admin_editions_path
        else
          @template.polymorphic_path([:admin, object.class])
        end
      else
        case object
        when CorporateInformationPage, Edition
          @template.admin_edition_path(object)
        else
          @template.polymorphic_path([:admin, object])
        end
      end
    end

    def file_cache_already_uploaded(method)
      @template.tag.span("#{File.basename(object.send("#{method}_cache"))} already uploaded", class: "already_uploaded")
    end
  end
end
