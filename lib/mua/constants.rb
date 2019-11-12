module Mua::Constants
  # == Constants ============================================================
  
  LINE_REGEXP = /\A.*?\r?\n/.freeze
  CRLF = "\r\n".freeze
  
  SERVICE_PORT = {
    smtp: 25,
    imap: 993,
    socks5: 1080
  }.freeze
end