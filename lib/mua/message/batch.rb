require 'async/notification'
require 'mail'

class Mua::Message::Batch < Async::Notification
  # == Constants ============================================================

  # == Exceptions ===========================================================

  QueueClosedError = Class.new(Mua::Error)
  RetryMessage = Class.new(Mua::Signal)

  # == Extensions ===========================================================

  # == Properties ===========================================================

  attr_reader :messages

  # == Class Methods ========================================================

  def self.from_path(path, recursive: false, shuffle: false, limit: false, into: nil)
    files = [ ]

    if (File.file?(path))
      files << path
    else
      spec = recursive ? '**/*' : '*'

      files += Dir.glob(File.expand_path(File.join(path, spec), Dir.pwd)).select do |f|
        File.file?(f)
      end

      if (shuffle)
        files.shuffle!
      end

      if (limit)
        files = files.first(limit)
      end
    end

    into ||= new

    files.each do |file|
      into << Mua::Message.load_file(file)
    end

    into
  end

  # == Instance Methods =====================================================

  def initialize(messages = nil, closed: nil)
    super()

    @messages = (messages || [ ]).map do |message|
      Mua::Message.from(message)
    end

    @queue = [ ]

    @messages.each do |message|
      message.batch = self
      @queue << message
    end

    @processed = [ ]

    @closed = closed.nil? ? !!messages : !!closed
  end

  def to_a
    @messages.dup
  end

  def closed?
    @closed
  end

  def close!
    @closed = true
  end

  def complete?
    @closed and @queue.empty?
  end

  def requeue(message)
    @queue << message

    self.signal
  end

  def processed(message)
    @processed << message
  end

  def <<(message)
    if (@closed)
      raise QueueClosedError, 'Unable to write to closed queue'
    end

    message = Mua::Message.from(message).tap do |message|
      message.batch = self
    end

    @messages << message
    @queue << message

    self.signal
  end

  def queue_length
    @queue.size
  end
  alias_method :queue_size, :queue_length

  def processed_length
    @processed.size
  end
  alias_method :processed_size, :processed_length

  def length
    @messages.length
  end
  alias_method :size, :length

  def include?(message)
    @messages.include?(message)
  end

  def queued?(message)
    @queue.include?(message)
  end

  def queue_empty?
    @queue.empty?
  end

  def processed_empty?
    @processed.empty?
  end

  def empty?
    @messages.empty?
  end

  def queue_any?(&block)
    @queue.any?(&block)
  end

  def any?(&block)
    @messages.any?(&block)
  end

  def processed_any?(&block)
    @processed.any?(&block)
  end

  def message_ids
    @messages.map(&:id)
  end

  def message_report
    @messages.each_with_object(Hash.new(0)) do |message, count|
      count[message.state] += 1
    end
  end

  def message_results
    @messages.map do |message|
      {
        id: message.id,
        state: message.delivery_results.last&.state || :failed,
        results: message.delivery_results.map do |result|
          {
            state: result.state,
            result_code: result.result_code,
            result_message: result.result_message
          }
        end
      }
    end
  end

  def next(&block)
    loop do
      return if (@closed and @queue.empty?)

      if (message = @queue.shift)
        if (block_given?)
          yield(message)
        end

        break message
      end

      self.wait
    end
  end

  def each(&block)
    loop do
      while (!@closed and @queue.empty?)
        self.wait
      end

      return if (@closed and @queue.empty?)

      message = @queue.shift

      yield(message)
    end
  end

  def inspect
    "<#{self.class}##{self.object_id} length=#{@messages.length}>"
  end
end
