RSpec.describe Mua::Client::Context, type: :reactor do
  it 'is a Mua::State::Context' do
    expect(Mua::Client::Context.ancestors).to include(Mua::State::Context)
  end

  it 'has properties with defaults' do
    context = Mua::Client::Context.new

    expect(context.smtp_username).to be(nil)
    expect(context.smtp_password).to be(nil)
    expect(context.smtp_host).to be(nil)
    expect(context.smtp_port).to be(nil)
    expect(context.smtp_timeout).to be(Mua::Constants::TIMEOUT_DEFAULT)
    expect(context.proxy_username).to be(nil)
    expect(context.proxy_password).to be(nil)
    expect(context.proxy_host).to be(nil)
    expect(context.proxy_port).to be(nil)
    expect(context.result_code).to be(nil)
    expect(context.result_message).to be(nil)
    expect(context.buffer).to eq([ ])
    expect(context.remote_host).to be(nil)
    expect(context.read_task).to be(nil)
    expect(context.service_extensions).to eq({ })
    expect(context.hostname).to eq('localhost')
    expect(context.protocol).to be(:esmtp)
    expect(context).to_not be_tls_connect
    expect(context).to be_tls_requested
    expect(context).to_not be_tls_required
    expect(context).to_not be_proxy
    expect(context.timeout).to be(Mua::Constants::TIMEOUT_DEFAULT)
    expect(context.batch).to be_empty
    expect(context.message).to be(nil)
    expect(context).to_not be_close_requested
  end

  it 'allows writing to properties' do
    context = Mua::Client::Context.new
    message = Mua::Message.new(
      mail_from: 'mail-from@example.org',
      rcpt_to: 'rcpt-to@example.org',
      data: 'From: Demo'
    )

    context.smtp_username = 'smtp/user'
    context.smtp_password = 'smtp/pass'
    context.smtp_host = 'smtp.example.org'
    context.smtp_port = 587
    context.smtp_timeout = 900
    context.proxy_username = 'socks5/user'
    context.proxy_password = 'socks5/pass'
    context.proxy_host = 'socks5.example.net'
    context.proxy_port = 1080
    context.result_code = 250
    context.result_message = 'Got it'
    context.buffer = %w[ Continues ]
    context.remote_host = 'mail.example.net'
    context.read_task = reactor
    context.service_extensions[:max_size] = 1024
    context.hostname = 'mta.example.org'
    context.protocol = :esmtp
    context.tls_requested = false
    context.tls_required!
    context.timeout = 999
    context.batch << message
    context.message = message
    context.close_requested!

    expect(context.smtp_username).to eq('smtp/user')
    expect(context.smtp_password).to eq('smtp/pass')
    expect(context.smtp_host).to eq('smtp.example.org')
    expect(context.smtp_port).to eq(587)
    expect(context.smtp_timeout).to eq(900)
    expect(context.proxy_username).to eq('socks5/user')
    expect(context.proxy_password).to eq('socks5/pass')
    expect(context.proxy_host).to eq('socks5.example.net')
    expect(context.proxy_port).to eq(1080)
    expect(context.result_code).to eq(250)
    expect(context.result_message).to eq('Got it')
    expect(context.buffer).to eq(%w[ Continues ])
    expect(context.remote_host).to eq('mail.example.net')
    expect(context.read_task).to be(reactor)
    expect(context.service_extensions).to eq(max_size: 1024)
    expect(context.hostname).to eq('mta.example.org')
    expect(context.protocol).to be(:esmtp)
    expect(context).to be_auth_required
    expect(context).to_not be_tls_requested
    expect(context).to be_tls_required
    expect(context).to be_proxy
    expect(context.timeout).to eq(999)
    expect(context.batch.include?(message))
    expect(context.batch.queued?(message))
    expect(context.message).to be(message)
    expect(context).to be_close_requested
  end
end
