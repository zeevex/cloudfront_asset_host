require File.join(File.dirname(__FILE__), 'test_helper')

require 'action_view'

require 'action_view/test_case'
require "action_controller/test_process"
require 'action_view/helpers/asset_tag_helper'

# ActionView::Helpers is for recent rails version, ActionView::Base for older ones (in which case ActionView::Helpers::AssetTagHelper is also needed for tests...)
ActionView::Helpers.class_eval  { include ActionView::Helpers::AssetTagHelper } # For recent rails version...
ActionView::Base.class_eval     { include ActionView::Helpers::AssetTagHelper } # ...and for older ones
ActionView::TestCase.class_eval { include ActionView::Helpers::AssetTagHelper } if defined? ActionView::TestCase # ...for tests in older versions

class TagHelperExtTest < ActionView::TestCase

  CF_TAG_PATTERN = %r{.*(src|href)="http://assethost.com/[a-fA-F0-9]+/.*}

  def is_cloudfront_tag(tag)
    !! tag.match(CF_TAG_PATTERN)
  end
  
  def shared_teardown
    ActionView::Helpers::AssetTagHelper.class_eval do
      @@asset_timestamps_cache = {}
    end
    ['javascripts/all.js', 'stylesheets/all.css'].each do |name|
      file = File.join(Rails.public_path, name) 
      File.delete(file) if File.exist?(file)
    end
  end
  
  context "A configured uploader with no exclusions" do
    setup do
      CloudfrontAssetHost.configure do |config|
        config.cname  = "assethost.com"
        config.bucket = "bucketname"
        config.key_prefix = ""
        config.s3_config = "#{RAILS_ROOT}/config/s3.yml"
        config.exclude_pattern = nil
        config.enabled = true
      end
    end

      
    teardown do
      shared_teardown
    end

    should "use assethost for included asset path of image" do
      assert_equal "http://assethost.com/d41d8cd98/images/image.png", image_path("image.png")
    end

    should "use assethost for included asset path of stylesheet" do
      assert_equal "http://assethost.com/ad8b295cb/stylesheets/style.css", stylesheet_path("style.css")
    end

    should "use cloudfront javascript paths if :cache is NOT true" do
      assert_match CF_TAG_PATTERN, javascript_include_tag("application.js")
    end

    should "use cloudfront stylesheet paths if :cache is NOT true" do
      assert_match CF_TAG_PATTERN, stylesheet_link_tag("style.css")
    end

    should "use non-cloudfront javascript paths if :cache => true" do
      assert_no_match CF_TAG_PATTERN, javascript_include_tag("application.js", :cache => true)
    end

    should "use non-cloudfront stylesheet paths if :cache => true" do
      assert_no_match CF_TAG_PATTERN, stylesheet_link_tag("style.css", :cache => true)
    end
  end
    
  context "A configured uploader excluding /style/" do
    setup do
      CloudfrontAssetHost.configure do |config|
        config.cname  = "assethost.com"
        config.bucket = "bucketname"
        config.key_prefix = ""
        config.s3_config = "#{RAILS_ROOT}/config/s3.yml"
        config.exclude_pattern = /style/
        config.enabled = true
      end
    end
      
    teardown do
      shared_teardown
    end

    should "allow standard Rails path generation for an excluded asset" do
      assert_match %r{^/stylesheets/style.css\?\d+$}, stylesheet_path("style.css")
    end

    should "use cloudfront javascript paths if :cache is NOT true" do
      assert_match CF_TAG_PATTERN, javascript_include_tag("application.js")
    end

    should "use non-cloudfront javascript paths if :cache => true" do
      assert_no_match CF_TAG_PATTERN, javascript_include_tag("application.js", :cache => true)
    end

    should "use non-cloudfront asset paths for excluded asset if :cache is NOT true" do
      assert_no_match CF_TAG_PATTERN, stylesheet_link_tag("style.css")
    end

    should "use non-cloudfront stylesheet paths if :cache => true" do
      assert_no_match CF_TAG_PATTERN, stylesheet_link_tag("style.css", :cache => true)
    end
  end
end