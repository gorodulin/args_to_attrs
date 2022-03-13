# frozen_string_literal: true

module ArgsToAttrs

  module InstanceMethods
    def args_to_attrs!(expand_keyrest: false)
      arguments = Array.new
      rest_keyword_args = {}
      receiver.method(self.eval('__method__')).parameters.each do |kind, name|
        case kind
        when :key, :keyreq, :req, :opt
          arguments << name
        when :keyrest
          next unless expand_keyrest
          rest_keyword_args = self.local_variable_get(name)
          arguments = arguments.union(rest_keyword_args.keys)
        end
      end
      assignment_order = block_given? ? yield(arguments.to_a) : arguments
      assignment_order.each do |name|
        value = rest_keyword_args.fetch(name) { self.local_variable_get(name) }
        method_name = :"#{name}="
        if receiver.class.private_method_defined?(method_name) ||
          receiver.class.public_method_defined?(method_name) ||
          receiver.class.protected_method_defined?(method_name)
          receiver.send(method_name, value)
        else
          receiver.instance_variable_set(:"@#{name}", value)
        end
      end
      true
    rescue NameError => e
      raise e unless e.message =~ /wrong local variable name/
  
      raise "Argument forwarding is not supported"
    end
  end
end

Binding.include ArgsToAttrs::InstanceMethods unless Binding.include?(ArgsToAttrs::InstanceMethods)
