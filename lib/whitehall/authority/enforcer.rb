require 'whitehall/authority/rules/object_rules'
require 'whitehall/authority/rules/edition_rules'
require 'whitehall/authority/rules/fatality_notice_rules'
require 'whitehall/authority/rules/world_edition_rules'
require 'whitehall/authority/rules/document_rules'
require 'whitehall/authority/rules/ministerial_role_rules'
require 'whitehall/authority/rules/policy_group_rules'
require 'whitehall/authority/rules/miscellaneous_rules'

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
      if @rules.nil?
        rules_class = find_ruleset_for_instance_or_closest_ancestor(subject)
        @rules = rules_class.new(@actor, @subject)
      end
      @rules
    end

    protected
    def find_ruleset_for_instance_or_closest_ancestor(subject)
      classes_to_look_at = subject.is_a?(Class) ? subject.ancestors : subject.class.ancestors
      classname_with_rules = classes_to_look_at.map(&:name).detect { |class_name| RulesMap.has_key?(class_name) }
      RulesMap[classname_with_rules]
    end
  end

  RulesMap = {
    'Object' => Rules::ObjectRules,
    'Symbol' => Rules::MiscellaneousRules,
    'Document' => Rules::DocumentRules,
    'Edition' => Rules::EditionRules,
    'FatalityNotice' => Rules::FatalityNoticeRules,
    'WorldLocationNewsArticle' => Rules::WorldEditionRules,
    'WorldwidePriority' => Rules::WorldEditionRules,
    'MinisterialRole' => Rules::MinisterialRoleRules,
    'PolicyGroup' => Rules::PolicyGroupRules
  }
end
