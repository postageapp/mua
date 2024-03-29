require 'date'

RSpec.describe Mua::State::Context::Builder do
  context 'class_with_attributes()' do
    context_type = Mua::State::Context::Builder.class_with_attributes(
      [ ],
      initial_state: :custom_initial_state,
      terminal_states: :custom_terminal_state,
      boolean_value: {
        boolean: true,
        default: false
      }
    )

    it 'overrides initial_state' do
      context = context_type.new

      expect(context_type.initial_state).to eq(:custom_initial_state)
      expect(context.initial_state).to eq(:custom_initial_state)
      expect(context.state).to eq(:custom_initial_state)

      expect(context.to_h).to eq(
        state: :custom_initial_state,
        boolean_value: false
      )
    end

    it 'overrides terminal_states' do
      context = context_type.new

      expect(context_type.terminal_states).to eq(:custom_terminal_state)
      expect(context.terminal_states).to eq(:custom_terminal_state)
    end

    it 'properly defaults' do
      context = context_type.new

      expect(context).to_not be_boolean_value
    end

    it 'accepts overrides on initialize' do
      context = context_type.new(boolean_value: true)

      expect(context).to be_boolean_value
    end

    it 'accepts input and modifications' do
      context = context_type.new(boolean_value: true)

      context.boolean_value = false

      expect(context).to_not be_boolean_value
    end

    it 'converts input values to booleans' do
      context = context_type.new(boolean_value: nil)

      expect(context).to_not be_boolean_value

      context.boolean_value = false

      expect(context).to_not be_boolean_value

      context.boolean_value = 'yes'

      expect(context).to be_boolean_value
    end

    it 'implements a quick switcher with ! postfix' do
      context = context_type.new

      expect(context.boolean_value!).to be(true)

      expect(context.boolean_value!).to be(false)
    end

    it 'executes blocks only if not set' do
      context = context_type.new
      executed = 0

      expect(context).to_not be_boolean_value
      expect(executed).to eq(0)

      context.boolean_value! do
        executed += 1
      end

      expect(context).to be_boolean_value
      expect(executed).to eq(1)

      context.boolean_value! do
        executed += 1
      end

      expect(context).to be_boolean_value
      expect(executed).to eq(1)
    end

    it 'can include a module in the generated class' do
      inclusion = Module.new do
        def demo
          :demo
        end
      end

      built = Mua::State::Context::Builder.class_with_attributes(
        [ ],
        includes: inclusion
      )

      expect(built).to be_kind_of(Class)
      expect(built.ancestors).to include(inclusion)

      instance = built.new

      expect(instance).to respond_to(:demo)
    end

    it 'can extend the generated class with a module' do
      extension = Module.new do
        def demo
          :demo
        end
      end

      built = Mua::State::Context::Builder.class_with_attributes(
        [ ],
        extends: extension
      )

      expect(built).to be_kind_of(Class)
      expect(built.ancestors).to include(extension)

      expect(built).to respond_to(:demo)
    end

    it 'can include multiple modules in the generated class' do
      inclusions = [
        Module.new do
          def a
            :a
          end
        end,
        Module.new do
          def b
            :b
          end
        end
      ]

      built = Mua::State::Context::Builder.class_with_attributes(
        [ ],
        includes: inclusions
      )

      expect(built).to be_kind_of(Class)
      expect(built.ancestors).to include(*inclusions)

      instance = built.new

      expect(instance).to respond_to(:a, :b)
    end

    it 'can customize the class by supplying a block' do
      built = Mua::State::Context::Builder.class_with_attributes([ ], { }) do
        def customized?
          true
        end
      end

      context = built.new

      expect(context).to be_customized
    end

    it 'can convert input values' do
      built = Mua::State::Context::Builder.class_with_attributes([ ], {
        as_date: {
          convert: -> (date) { Date.parse(date) }
        }
      })

      context = built.new(as_date: '2020-01-01')

      expect(context.as_date).to eq(Date.parse('2020-01-01'))
    end
  end
end
