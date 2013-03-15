require 'whitehall/authority/rules/object_rules'
require 'whitehall/authority/rules/edition_rules'
require 'whitehall/authority/rules/fatality_notice_rules'
require 'whitehall/authority/rules/document_rules'

module Whitehall::Authority
  class Enforcer
    attr_reader :actor, :subject
    def initialize(actor, subject)
      @actor = actor
      @subject = subject
    end

    def can?(action)
      rules.can?(action)
    end

    def rules
      if @ruleset.nil?
        look_at = subject.is_a?(Class) ? subject.ancestors : subject.class.ancestors
        rules_class = look_at.detect { |clazz| RulesMap.has_key?(clazz.name) }
        rules_proc = RulesMap[rules_class.name]
        @rules = rules_proc.call(@actor, @subject)
      end
      @rules
    end
  end

  RulesMap = {
    'Object' => ->(actor, subject) { Rules::ObjectRules },
    'Document' => ->(actor, subject) { Rules::DocumentRules.new(actor, subject) },
    'Edition' => ->(actor, subject) { Rules::EditionRules.new(actor, subject) },
    'FatalityNotice' => ->(actor, subject) { Rules::FatalityNoticeRules.new(actor, subject) }
  }
end
