class MapDefinitionError < Exception; end

module Babelicious

  class MapDefinition
    attr_reader :mappings, :direction
    
    def initialize
      @mappings = []
    end

    def direction=(dir)
      raise MapDefinitionError, "Direction must be a hash" unless dir.is_a?(Hash)
      raise MapDefinitionError, "Both :from and :to keys must be set (e.g., {:from => :xml, :to => :hash}" unless (dir[:from] && dir[:to])

      @direction = dir
    end
    
    def translate(source)
      target = nil
      @mappings.each do |rule|
        target = rule.initial_target if target.nil?
        filtered_source = rule.filtered_source(source) if filtered_source.nil?
        
        source_value = rule.source.value_from(filtered_source)
        rule.translate(target, source_value)
      end
      target
    end
    
    def register_condition(condition_key, condition=nil, &block)
      @mappings.last.target.register_condition(condition_key, condition, &block)
    end
    
    def register_customized(&block)
      @mappings.last.target.register_customized(&block)
    end
    
    def register_from(from_str)
      raise MapDefinitionError, "Please specify a source mapping" if from_str.nil?
      source = MapFactory.source(@direction, {:from => from_str})

      @mappings << MapRule.new(source)
    end

    def register_to(&block)
      raise MapDefinitionError, "You must call the .from method before customizing the .to method (e.g., m.from(\"foo\").to {|value| ...}" unless @mappings.last

      target = MapFactory.target(@direction, {:to => '', :to_proc => block})
      @mappings.last.target = target
    end

    def register_include(map_definition=nil, opts={})
      raise MapDefinitionError, "A mapping definition key is required (e.g., m.include(:another_map))" if map_definition.nil?
      raise MapDefinitionError, "Mapping definition for #{map_definition} does not exist" unless (other_mapper = Mapper[map_definition.to_sym])

      other_mapper.mappings.each do |m|
        source = m.source.dup
        target = m.target.dup

        if opts[:inside_of]
          source.path_translator.unshift(opts[:inside_of])
          target.path_translator.unshift(opts[:inside_of])
        end 
        
        @mappings << MapRule.new(source, target)
      end 
    end

    def register_mapping(opts={})
      raise MapDefinitionError, "Both :from and :to keys must be set (e.g., {:from => \"foo/bar\", :to => \"bar/foo\")" unless (opts[:from] && opts[:to])
      
      @mappings << MapRule.new(MapFactory.source(@direction, opts), MapFactory.target(@direction, opts))
    end
    
    def reset
      @mappings, @direction = [], nil
    end
  end
end
