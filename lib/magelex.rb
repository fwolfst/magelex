require "magelex/version"

require 'logger'

module Magelex
  def self.logger
    @logger ||= Logger.new
  end
  def self.logger= logger
    @logger = logger
  end
end
