require_relative 'context_extensions'
require_relative '../state'
require_relative '../smtp/common/context_extensions'

Mua::Client::Context = Mua::State::Context.define(
  :remote_host,
  :smtp_host,
  :smtp_port,
  :smtp_username,
  :smtp_password,
  :proxy_username,
  :proxy_password,
  :proxy_host,
  :proxy_port,
  :read_task,
  :reply_code,
  :reply_message,
  :exception,
  :connection_stage,
  :local_ip,
  :local_port,
  :remote_ip,
  :remote_port,
  :smtp_banner,
  reply_buffer: {
    default: -> { [ ] }
  },
  smtp_timeout: {
    default: Mua::Constants::TIMEOUT_DEFAULT
  },
  service_extensions: {
    default: -> { { } }
  },
  hostname: {
    default: 'localhost'
  },
  protocol: {
    default: :smtp
  },
  tls_connect: {
    default: false,
    boolean: true
  },
  tls_requested: {
    default: true,
    boolean: true
  },
  tls_required: {
    default: false,
    boolean: true
  },
  timeout: {
    default: Mua::Constants::TIMEOUT_DEFAULT
  },
  delivery_queue: {
    default: -> { [ ] }
  },
  delivery: {
    default: nil
  },
  message: {
    default: nil
  },
  close_requested: {
    boolean: true,
    default: false
  },
  closed: {
    boolean: true,
    default: false
  },
  includes: [
    Mua::SMTP::Common::ContextExtensions,
    Mua::Client::ContextExtensions
  ]
)
