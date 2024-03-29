module Mua
  # == Exceptions ===========================================================

  Error = Class.new(StandardError)
  Signal = Class.new(StandardError)
end

require_relative 'mua/version'
require_relative 'mua/debug'

require_relative 'mua/attr_boolean'
require_relative 'mua/client'
require_relative 'mua/constants'
require_relative 'mua/email_address'
require_relative 'mua/interpreter'
require_relative 'mua/message'
require_relative 'mua/parser'
require_relative 'mua/state'
require_relative 'mua/struct'
require_relative 'mua/support'

# require_relative 'mua/imap' # Pending implementation
require_relative 'mua/smtp'
require_relative 'mua/token'
require_relative 'mua/socks5'
