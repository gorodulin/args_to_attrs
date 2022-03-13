# frozen_string_literal: true

require "spec_helper"

RSpec.describe "binding.args_to_attrs!" do

  subject do
    dummy_class.new
  end

  let(:dummy_class) do
    Class.new do
      def self.evaluate(string)
        self.send :eval, string
        self
      end
      attr_accessor :attr_x, :attr_y
    end.evaluate(def_method)
  end

  context "when called not from a method" do
    it "raises OutOfMethodError error" do
      expect { binding.args_to_attrs! }.to raise_error ::ArgsToAttrs::OutOfMethodError
    end
  end

  
  context "when called without arguments" do
    let(:def_method) do
      <<~METHOD
        def call(#{method_args})
           binding.args_to_attrs!
        end
      METHOD
    end

    describe "for method" do

      context "with argument forwarding" do
        let(:method_args) { %Q{ ... } }
  
        it "raises ArgumentForwardingNotSupportedError" do
          expect { subject.call(:X, :Y) }.to raise_error ArgsToAttrs::ArgumentForwardingNotSupportedError
        end
      end
  
      context "with positional arguments only" do
        let(:method_args) { %Q{ attr_x, attr_y, attr_z } }

        it "sets attributes and instance vars" do
          subject.call(:X, :Y, :Z)
          expect(subject.attr_x).to eq(:X)
          expect(subject.attr_y).to eq(:Y)
          expect(subject.instance_variable_get("@attr_z")).to eq(:Z)
        end
      end

      context "with keyword arguments only" do
        let(:method_args) { %Q{ attr_x:, attr_y:, attr_z: } }

        it "sets attributes and instance vars" do
          subject.call(attr_x: :X, attr_y: :Y, attr_z: :Z)
          expect(subject.attr_x).to eq(:X)
          expect(subject.attr_y).to eq(:Y)
          expect(subject.instance_variable_get("@attr_z")).to eq(:Z)
        end
      end

      context "with mix of positional and arguments" do
        let(:method_args) { %Q{ attr_x, attr_y, attr_z:, attr_v: } }

        it "sets attributes and instance vars" do
          subject.call(:X, :Y, attr_z: :Z, attr_v: :V)
          expect(subject.attr_x).to eq(:X)
          expect(subject.attr_y).to eq(:Y)
          expect(subject.instance_variable_get("@attr_z")).to eq(:Z)
          expect(subject.instance_variable_get("@attr_v")).to eq(:V)
        end
      end

      context "with rest ** keyword arguments" do
        let(:method_args) { %Q{ attr_x, attr_y:, **args } }

        it "does NOT set instance vars" do
          subject.call(:X, attr_y: :Y, attr_z: :Z, attr_v: :V)
          expect(subject.attr_x).to eq(:X)
          expect(subject.attr_y).to eq(:Y)
          expect(subject.instance_variable_defined?("@attr_z")).to be_falsey
          expect(subject.instance_variable_defined?("@attr_v")).to be_falsey
        end
      end
    end    
  end

  context "when called with argument 'expand_keyrest'" do
    let(:def_method) do
      <<~METHOD
        def call(#{method_args})
           binding.args_to_attrs!(expand_keyrest: #{expand_keyrest})
        end
      METHOD
    end

    describe "for method" do
      context "with rest ** keyword arguments" do
        let(:method_args) { %Q{ attr_x = :X, **args } }
        let(:expand_keyrest) { true }

        it "does NOT set instance vars" do
          subject.call(attr_y: :Y, attr_z: :Z, attr_v: :V)
          expect(subject.attr_x).to eq(:X)
          expect(subject.attr_y).to eq(:Y)
          expect(subject.instance_variable_get("@attr_z")).to eq(:Z)
          expect(subject.instance_variable_get("@attr_v")).to eq(:V)
        end
      end
    end
  end

  context "when called with block" do
    let(:def_method) do
      <<~METHOD
        def call(#{method_args})
           binding.args_to_attrs!(expand_keyrest: #{expand_keyrest}) { #{block} }
        end
        def attr_y=(val)
          @attr_y = @attr_v.to_s + val.to_s
        end
      METHOD
    end
    let(:method_args) { %Q{ attr_x, attr_y:, **args } }
    let(:expand_keyrest) { true }

    context "when block returns array with some names" do
      let(:block) { %Q{ [:attr_v, :attr_y] } }

      it "assigns attrs/vars with names returned by the block" do
        subject.call(attr_x = :X, attr_y: :Y, attr_z: :Z, attr_v: :V)
        expect(subject.instance_variable_get("@attr_v")).to eq(:V)
        expect(subject.attr_y).to eq("VY")
      end

      it "does not assign not listed attrs/vars" do
        subject.call(attr_x = :X, attr_y: :Y, attr_z: :Z, attr_v: :V)
        expect(subject.attr_x).to be_nil
        expect(subject.instance_variable_defined?("@attr_z")).to be_falsey
      end
    end

    context "when block returns nil" do
      let(:block) { %Q{ nil } }

      it "raises error" do
        expect { subject.call(attr_x = :X, attr_y: :Y, attr_z: :Z, attr_v: :V) }
          .to raise_error NoMethodError, /undefined method `each' for nil:NilClass/
      end
    end
  end
end
