require 'async/io/stream'

require_relative '../attr_boolean'
require_relative '../constants'
require_relative '../struct'
require_relative '../token'

class Mua::State::Context < Mua::Struct
  # == Constants ============================================================

  # == Extensions ===========================================================

  extend Mua::AttrBoolean

  # == Properties ===========================================================

  attr_accessor :reactor
  attr_accessor :state
  attr_accessor :input
  attr_accessor :events
  attr_boolean :terminated
  attr_accessor :iteration_limit

  # == Class Methods ========================================================

  def self.define(*attr_list, **attr_spec, &block)
    Mua::State::Context::Builder.class_with_attributes(
      attr_list,
      attr_spec,
      self,
      &block
    )
  end

  def self.attr_map
    {
      state: {
        variable: :@state,
        default: -> (context) { context.initial_state }
      }
    }
  end

  def self.initial_state
    Mua::State::INITIAL_DEFAULT
  end

  def self.terminal_states
    Mua::State::TERMINAL_DEFAULT
  end

  # == Instance Methods =====================================================

  def initialize(reactor: nil, state: nil, input: nil, iteration_limit: nil)
    super()

    @reactor = reactor
    @input = input
    @state = state || self.initial_state
    @terminated = false
    @events = nil

    @iteration_limit = iteration_limit&.to_i

    yield(self) if (block_given?)
  end

  def initial_state
    Mua::State::INITIAL_DEFAULT
  end

  def terminal_states
    Mua::State::TERMINAL_DEFAULT
  end

  def async(&block)
    @reactor.async(&block)
  end

  # Reads an element out of the provided input array. Subclasses can redefine
  # this behavior to match the type of input object used.
  def input_read
    case (input)
    when IO, Async::IO::Stream
      @input.read
    when Array
      @input.shift
    else
      @input
    end
  end

  def parser_redo!
    Mua::Token::Redo
  end

  # Emits a state transition
  def transition!(state:, parent: nil)
    Mua::State::Transition.new(state: state, parent: parent)
  end

  # Emits a local state transition
  def local_transition!(state:)
    Mua::State::Transition.new(state: state, parent: false)
  end

  # Emits a local state transition
  def parent_transition!(state:)
    Mua::State::Transition.new(state: state, parent: true)
  end

  # Emits a state transition to the default final state
  def finished!
    Mua::State::Transition.new(state: self.terminal_states[0])
  end

  # Returns true if a reactor is associated with this context, false otherwise.
  def reactor?
    !!@reactor
  end

  # Used to relay events to the event receiver, if any is defined
  def event!(*args)
    @events&.call(*args)
  end
end

require_relative 'context/builder'
