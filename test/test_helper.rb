require 'rubygems'
require 'bundler'
Bundler.setup

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'active_support'
require 'action_controller'

require 'test/unit'
require 'shoulda'
require 'mocha'
begin require 'redgreen'; rescue LoadError; end
begin require 'turn'; rescue LoadError; end

RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), 'app'))

class NullBacktraceCleaner
  def clean(x); x; end
end

module Rails
  class << self
    def root
      RAILS_ROOT
    end

    def public_path
      File.join(RAILS_ROOT, 'public')
    end

    def env
      "production"
    end

    def backtrace_cleaner
      @@backtrace_cleaner ||= begin
        NullBacktraceCleaner.new
      end
    end
  end
end

require File.join(File.dirname(__FILE__), '..', 'lib', 'cloudfront_asset_host')
