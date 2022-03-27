require_relative '../components/default'

module DSL
  class Api
    attr_reader :functions, :meta

    def initialize(component)
      @component = component

      @functions = @component[:signatures].keys

      build_meta

      extend @component[:api]
    end

    def build_global_ffi
      global_ffi = Component::Default.instance.options[:global_ffi]

      unless @component[:meta][:options][:global_ffi].nil?
        global_ffi = @component[:meta][:options][:global_ffi]
      end

      global_ffi
    end

    def build_meta
      meta_data = @component[:meta][:elected].clone

      meta_data[:global_ffi] = build_global_ffi

      @meta = Struct.new(
        *meta_data.keys
      ).new(*meta_data.values)
    end

    def signature_for(function)
      @component[:signatures][function.to_sym]
    end

    def inspect
      output = "#<#{self.class}:0x#{format('%016x', object_id)}"

      variables = ['@meta'].map do |struct_name|
        "#{struct_name}=#{instance_variable_get(struct_name).inspect}"
      end

      "#{output} #{variables.join(' ')}>"
    end
  end
end
