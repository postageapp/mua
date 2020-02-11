Mua::Client::DeliveryResult = Mua::State::Context.define(
  message: {
    # Arbitrary message payload object
  },
  result_code: {
    # Should be a result code of the form SMTP_NNN, SOCKS5_NNN or HTTP_NNN
  },
  result_message: {
  },
  proxy_host: {
  },
  proxy_port: {
    convert: :to_i.to_proc
  },
  target_host: {
  },
  target_port: {
    convert: :to_i.to_proc
  },
  delivered: {
    boolean: true,
    default: false
  }
)
