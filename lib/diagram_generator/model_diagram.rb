module DiagramGenerator

  def is_concern?(klass)
    klass.singleton_class.included_modules.include? ActiveSupport::Concern
  end
  module_function :is_concern?

  ClassNode = Struct.new(:name) do
    def to_uml
      klass = Object.const_get(name)
      if klass.instance_of?(Class)
        <<~UML
          class #{name}
        UML
      elsif klass.instance_of?(Module)
        <<~UML
          metaclass #{name} #{DiagramGenerator.is_concern?(klass) ? '<<concern>>' : ''}
        UML
      else
        raise "logic error - ClassNodes should be a Class or a Module, not #{klass.name} which is a #{klass.class}"
      end
    end
  end

  NormalRelationship = Struct.new(:macro, :name)
  ThroughRelationship = Struct.new(:macro, :name, :original)

  AssociationKey = Struct.new(:from, :to)

  class Associations
    def initialize(key)
      @key = key
      # a link can represent several relationships
      @normal_relationships = []
      @through_relationships = []
    end

    def add(relationship)
      @normal_relationships << relationship
    end

    def add_through(relationship)
      @through_relationships << relationship
    end

    def normal_description
      relationship_count_summary(@normal_relationships)
    end

    def through_description
      "(through) #{relationship_count_summary(@through_relationships)}"
    end

    def to_uml
      case [@normal_relationships.length, @through_relationships.length]
      in [0, 0]
        raise "logic error - no relationships"
      in [1.., 0]
        <<~UML
          #{@key.from} --> #{@key.to} : "#{normal_description}"
        UML
      in [0, 1..]
        <<~UML
          #{@key.from} ..> #{@key.to} : "#{through_description}"
        UML
      in [1.., 1..]
        <<~UML
          #{@key.from} --> #{@key.to} : "#{normal_description}"
          #{@key.from} ..> #{@key.to} : "#{through_description}"
        UML
      else
        raise "logic error - invalid relationship counts #{[@normal_relationships.length, @through_relationships.length]}"
      end
    end

    private

    def relationship_count_summary(relationships)
      counts = Hash.new(0)
      relationships.each { |rel| counts[rel.macro] += 1 }
      counts.map { |macro, count| count == 1 ? macro : "#{macro} x #{count}" }.join(",")
    end
  end

  Concern = Struct.new(:from, :to) do
    def to_uml
      <<~UML
        #{from} .u.|> #{to}
      UML
    end
  end

  # Don't store inheritance as a relationship because it's quite different and specific
  InheritanceLink = Struct.new(:from, :to) do
    def to_uml
      <<~UML
        #{from} <|-- #{to} #line:blue;line.bold
      UML
    end
  end

  class ModelDiagram
    def initialize(base_class_names, options)
      @options = options
      @show_associations = options[:show_associations]
      @show_through_associations = options[:through]
      @show_concerns = options[:show_concerns]
      @add_extra_classes = options[:extra_classes]

      @base_class_names = base_class_names
      @class_layers = Hash.new { |h, key| h[key] = [] } # group classes by base class name so we can group them
      @extra_classes = [] # classes with no known base class
      @inheritance_links = [] # order doesn't matter
      @concerns = []
      @associations = Hash.new { |h, key| h[key] = Associations.new(key) }
      @node_names = Set.new

      @base_class_names.each do |base_class_name|
        unless Object.const_defined?(base_class_name)
          raise "Unknown class #{base_class_name}"
        end

        base_class = Object.const_get(base_class_name)
        unless base_class < ActiveRecord::Base
          raise "#{base_class.name} does not descent from ActiveRecord::Base"
        end

        if base_class.subclasses.empty?
          warn "Note #{base_class_name} has no subclasses - maybe run `Rails.application.eager_load!` first?"
        end
        add_class!(base_class_name, base_class, nil, 0)
      end

      @base_class_names.each do |base_class_name|
        base_class = Object.const_get(base_class_name)
        if @show_concerns
          add_concerns!(base_class)
        end
        if @show_associations
          add_associations!(base_class)
        end
      end
    end

    def generate(dest)
      dest.print <<~UML
        @startuml
        allowmixing
        hide empty members

        note "Generated diagram on #{Time.now.strftime("%Y-%m-%d")} " as Note1

        ' Generated for classes #{@base_class_names.join(",")}
        ' Options: #{@options}

      UML

      @base_class_names.each do |base_class_name|
        nested_class_count = @class_layers[base_class_name].map(&:count).reduce(:+)
        dest.puts "rectangle \"#{base_class_name} Family\" {" if nested_class_count > 1
        @class_layers[base_class_name].each do |layer|
          layer.each do |plantuml_class|
            dest.print plantuml_class.to_uml
          end
        end
        dest.puts "}" if nested_class_count > 1

      end

      @extra_classes.each do |extra_class|
        dest.print extra_class.to_uml
      end

      @inheritance_links.each do |link|
        dest.print link.to_uml
      end
      @concerns.each do |link|
        dest.print link.to_uml
      end
      @associations.each_value do |link|
        dest.print link.to_uml
      end

      dest.puts "@enduml"
    end

    private

    def add_class!(base_class_name, klass, parent, depth)
      (@class_layers[base_class_name][depth] ||= []) << ClassNode.new(klass.name)
      @node_names << klass.name
      unless parent.nil?
        @inheritance_links << InheritanceLink.new(parent.name, klass.name)
      end
      klass.subclasses.each do |subclass|
        add_class!(base_class_name, subclass, klass, depth + 1)
      end
    end

    def add_associations!(klass)
      associations = klass.reflect_on_all_associations
      superclass_associations = klass.superclass.reflect_on_all_associations
      my_associations = associations.reject { |a| superclass_associations.include? a }
      my_associations.each do |a|
        process_association klass.name, a, associations
      end

      klass.subclasses.each do |subclass|
        add_associations!(subclass)
      end
    end

    def add_concerns!(klass)
      concerns = (klass.included_modules - klass.superclass.included_modules).select { |c| DiagramGenerator.is_concern?(c) }
      concerns.each do |concern|
        if known_class?(concern.name) || @add_extra_classes
          add_extra_class_if_needed(concern.name)
        end
        if known_class?(concern.name)
          @concerns << Concern.new(klass.name, concern.name)
        end
      end

      klass.subclasses.each do |subclass|
        add_concerns!(subclass)
      end
    end

    def known_class?(class_name)
      @node_names.include? class_name
    end

    def add_extra_class_if_needed(class_name)
      if @add_extra_classes && !known_class?(class_name)
        @extra_classes << ClassNode.new(class_name)
        @node_names << class_name
      end
    end

    def add_model_link(new_link)
      if @inheritance_links.any? { |link| link.from == new_link.from && link.to == new_link.to }
        warn "ignoring duplicate inheritance link"
      end
    end

    def process_association(class_name, assoc, all_assoc)
      #  some of this is from railroady, but kept a lot simpler
      macro = assoc.macro.to_s
      through = assoc.options.include?(:through)

      if through
        return unless @show_through_associations

        through_name = assoc.options[:through]
        through_assoc = all_assoc.find { |a| a.name == through_name }
        unless through_assoc
          warn "Can't find through association from #{class_name} to #{assoc.name} through #{through_name}"
          return
        end
        if (known_class?(assoc.class_name) && known_class?(through_assoc.class_name)) || @add_extra_classes
          add_extra_class_if_needed(assoc.class_name)
          add_extra_class_if_needed(through_assoc.class_name)
          @associations[AssociationKey.new(through_assoc.class_name, assoc.class_name)].add_through(ThroughRelationship.new(macro, assoc.name, class_name))
        end
      else
        if known_class?(assoc.class_name) || @add_extra_classes
          add_extra_class_if_needed(assoc.class_name)
          @associations[AssociationKey.new(class_name, assoc.class_name)].add(NormalRelationship.new(macro, assoc.name))
        end
      end
    end
  end
end
