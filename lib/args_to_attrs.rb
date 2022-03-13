# frozen_string_literal: true

module ArgsToAttrs

  ArgumentForwardingNotSupportedError = Class.new(StandardError)

  OutOfMethodError = Class.new(StandardError)
  
  module InstanceMethods
    def args_to_attrs!(expand_keyrest: false)
      arguments = Array.new
      rest_keyword_args = {}
      method_name = self.eval('__method__') or raise OutOfMethodError
      receiver.method(method_name).parameters.each do |kind, name|
        case kind
        when :key, :keyreq, :req, :opt
          arguments << name
        when :keyrest
          next unless expand_keyrest
          rest_keyword_args = self.local_variable_get(name)
          arguments = arguments.union(rest_keyword_args.keys)
        when :rest
          fail ArgumentForwardingNotSupportedError if name == :*
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
    end
  end
end

Binding.include ArgsToAttrs::InstanceMethods unless Binding.include?(ArgsToAttrs::InstanceMethods)
