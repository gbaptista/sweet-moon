module DSL
  class Api
    attr_reader :functions, :meta

    def initialize(component)
      @component = component

      @functions = @component[:signatures].keys

      @meta = Struct.new(
        *@component[:meta][:elected].keys
      ).new(*@component[:meta][:elected].values)

      extend @component[:api]
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
