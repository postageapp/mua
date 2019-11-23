RSpec.describe Mua::SMTP::Client::Context do
  it 'is a Mua::State::Context' do
    expect(Mua::SMTP::Client::Context.ancestors).to include(Mua::State::Context)
  end

  it 'has properties with defaults' do
    context = Mua::SMTP::Client::Context.new

    expect(context.username).to be(nil)
    expect(context.password).to be(nil)
    expect(context.remote).to be(nil)
    expect(context.hostname).to eq('localhost')
    expect(context.protocol).to be(:smtp)
    expect(context).to_not be_auth_support
    expect(context).to_not be_auth_required
    expect(context).to_not be_tls
    expect(context).to_not be_proxy
    expect(context.timeout).to be(Mua::Constants::TIMEOUT_DEFAULT)
  end

  it 'allows writing to properties' do
    context = Mua::SMTP::Client::Context.new

    context.username = 'user'
    context.password = 'pass'
    context.remote = 'mail.example.net'
    context.hostname = 'mta.example.org'
    context.protocol = :esmtp
    context.auth_support = true
    context.auth_required = true
    context.tls = true
    context.proxy = true
    context.timeout = 999

    expect(context.username).to eq('user')
    expect(context.password).to eq('pass')
    expect(context.remote).to eq('mail.example.net')
    expect(context.hostname).to eq('mta.example.org')
    expect(context.protocol).to be(:esmtp)
    expect(context).to be_auth_support
    expect(context).to be_auth_required
    expect(context).to be_tls
    expect(context).to be_proxy
    expect(context.timeout).to eq(999)
  end
end
