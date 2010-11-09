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

  context "A configured uploader" do
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

    should "use assethost for included asset path" do
      assert_equal "http://assethost.com/d41d8cd98/images/image.png", image_path("image.png")
    end

    should "allow standard Rails path generation for an excluded asset" do
      assert_match %r{^/stylesheets/style.css\?\d+$}, stylesheet_path("style.css")
    end
  end
end