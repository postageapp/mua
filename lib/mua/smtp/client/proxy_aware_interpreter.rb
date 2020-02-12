require_relative 'interpreter'
require_relative '../../socks5'

Mua::SMTP::Client::ProxyAwareInterpreter = Mua::Interpreter.define(
  name: 'Mua::SMTP::Client::ProxyAwareInterpreter',
  context: Mua::Client::Context
) do
  state(:initialize) do
    enter do |context|
      if (context.exception)
        # Before the interpreter can kick off an exception may have occurred
        context.transition!(state: :terminated)
      else
        if (context.proxy?)
          context.transition!(state: :proxy_connect)
        else
          context.transition!(state: :smtp_connect)
        end
      end
    end
  end

  state(:proxy_connect, Mua::SOCKS5::Client::Interpreter)

  state(:proxy_connected) do
    enter do |context|
      context.transition!(state: :smtp_connect)
    end
  end

  state(:proxy_failed) do
    enter do |context|
      context.transition!(state: :finished)
    end
  end

  state(:smtp_connect, Mua::SMTP::Client::Interpreter)

  state(:smtp_finished) do
    enter do |context|
      context.transition!(state: :finished)
    end
  end

  state(:finished) do
    enter do |context|
      context.close!
    end
  end

  state(:terminated) do
    enter do |context|
      context.terminated!
    end
  end
end
