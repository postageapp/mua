require 'async/io/host_endpoint'

class Mua::SMTP::Server
  # == Constants ============================================================

  PORT_DEFAULT = 1025
  BIND_DEFAULT = '127.0.0.1'.freeze
  BACKLOG_DEFAULT = 128
  TIMEOUT_DEFAULT = 30

  EVENTS_PROPAGATED = %i[
    connected
    deliver_accept
    deliver_reject
    disconnected
    timeout
  ].freeze

  # == Extensions ===========================================================

  # == Properties ===========================================================

  attr_reader :bind
  attr_reader :port

  # == Class Methods ========================================================

  def self.interpreter
    Mua::SMTP::Server::Interpreter
  end

  # == Instance Methods =====================================================

  def initialize(interpreter: nil, hostname: nil, bind: nil, port: nil, start: true, tls_key_path: nil, tls_cert_path: nil, tls_initial: false, pipelining: nil, timeout: nil, logger: nil, &events)
    @interpreter = interpreter || self.class.interpreter
    @hostname = hostname
    @bind = bind || BIND_DEFAULT
    @port = port || PORT_DEFAULT
    @timeout = timeout || TIMEOUT_DEFAULT
    @logger = logger
    @pipelining = !!pipelining

    @tls_key_path = tls_key_path
    @tls_cert_path = tls_cert_path
    @tls_initial = !!tls_initial

    if (start)
      self.start!(&events)
    end
  end

  def tls_configured?
    @tls_key_path and @tls_cert_path
  end

  def tls_initial?
    @tls_initial
  end

  def start!(&events)
    @endpoint = Async::IO::Endpoint.tcp(@bind, @port)

    @endpoint.bind do |server, task|
      server.listen(BACKLOG_DEFAULT)

      @port = server.local_address.ip_port

      server.accept_each do |peer|
        peer.timeout = @timeout

        # FIX: Allow submitting context options to new()
        @interpreter.new(
          # FIX: Force TLS if necessary here with if (tls_initial?)
          Async::IO::Stream.new(peer)
        ) do |interpreter|
          context = interpreter.context

          context.hostname = @hostname
          context.events = events
          context.assign_remote_ip!
          context.tls_advertise = true
          context.tls_key_path = @tls_key_path
          context.tls_cert_path = @tls_cert_path
          context.logger = @logger
          context.pipelining = @pipelining
        end.run do |context, state, event, *args|
          events&.call(context, state, event, *args)
        end
      end
    end
  end
end

require_relative 'server/interpreter'
require_relative 'server/context'
