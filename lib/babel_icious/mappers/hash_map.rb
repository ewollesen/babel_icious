module Babelicious

  class HashMap < BaseMap
    class << self
      
      def initial_target
        {}
      end
      
      def filter_source(source)
        source
      end
      
    end

    def initialize(path_translator, opts={})
      @path_translator, @opts = path_translator, opts
    end
    
    def value_from(source)
      hash = {}
      @path_translator.inject_with_index(hash) do |hsh, element, index|
        return hsh[element.to_sym] if (index == @path_translator.last_index)
        if hsh.empty?
          source[element.to_sym]
        else 
          hsh[element.to_sym]
        end
      end
    end

    private

    def map_output(hash_output, source_value)
      catch :no_value do
        @path_translator.inject_with_index(hash_output) do |hsh, element, index|
          if(hsh[element])
            hsh[element]
          else
            hsh[element] = (index == @path_translator.last_index ? source_value : {})
          end 
        end
      end 
    end 
    
  end
end