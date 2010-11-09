require 'rubygems'
require 'bundler'
Bundler.setup

# get ref to test dir and then move to parent dir
testdir = File.expand_path(File.dirname(__FILE__))
Dir.chdir File.join(testdir, "..")

$LOAD_PATH.unshift(File.join(testdir, '..', 'lib'))

require 'active_support'
require 'action_controller'

require 'test/unit'
require 'shoulda'
require 'mocha'
begin require 'redgreen'; rescue LoadError; end
begin require 'turn'; rescue LoadError; end

RAILS_ROOT = File.expand_path(File.join(testdir, 'app'))

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

require File.join(testdir, '..', 'lib', 'cloudfront_asset_host')
