require 'digest/md5'
require 'cloudfront_asset_host/asset_tag_helper_ext'
require 'digest/md5'

module CloudfrontAssetHost

  autoload :Uploader,    'cloudfront_asset_host/uploader'
  autoload :CssRewriter, 'cloudfront_asset_host/css_rewriter'

  # Bucket that will be used to store all the assets (required)
  mattr_accessor :bucket

  # CNAME that is configured for the bucket or CloudFront distribution
  mattr_accessor :cname

  # Prefix keys
  mattr_accessor :key_prefix

  # Path to S3 config. Expects an +access_key_id+ and +secret_access_key+
  mattr_accessor :s3_config

  # Log S3 server access on a bucket
  mattr_accessor :s3_logging

  # Indicates whether the plugin should be enabled
  mattr_accessor :enabled

  # Upload gzipped assets and serve those assets when applicable
  mattr_accessor :gzip

  # Which extensions to serve as gzip
  mattr_accessor :gzip_extensions

  # Key-prefix under which to store gzipped assets
  mattr_accessor :gzip_prefix

  # Key-prefix under which to store plain (unzipped) assets
  mattr_accessor :plain_prefix

  # Which extensions are likely to occur in css files
  mattr_accessor :image_extensions

  # Array of directories to search for asset files in
  mattr_accessor :asset_dirs

  # Key Regular Expression to filter out/exclude content
  mattr_accessor :exclude_pattern

  class << self

    def configure
      # default configuration
      self.bucket     = nil
      self.cname      = nil
      self.key_prefix = ""
      self.s3_config  = "#{RAILS_ROOT}/config/s3.yml"
      self.s3_logging = false
      self.enabled    = false

      self.asset_dirs = %w(images javascripts stylesheets)
      self.exclude_pattern = nil

      self.gzip            = true
      self.gzip_extensions = %w(js css)
      self.gzip_prefix     = "gz"

      self.plain_prefix = ""

      self.image_extensions = %w(jpg jpeg gif png)

      yield(self)

      if properly_configured?
        enable!
      end
    end

    def asset_host(source = nil, request = nil)
      if cname.present?
        if cname.is_a?(Proc)
          host = cname.call(source, request)
        else
          host = (cname =~ /%d/) ? cname % (source.hash % 4) : cname.to_s
          host = "http://#{host}"
        end
      else
        host = "http://#{self.bucket_host}"
      end

      if source && request && CloudfrontAssetHost.gzip
        gzip_allowed  = CloudfrontAssetHost.gzip_allowed_for_source?(source)

        # Only Netscape 4 does not support gzip
        # IE masquerades as Netscape 4, so we check that as well
        user_agent = request.headers['User-Agent'].to_s
        gzip_accepted = !(user_agent =~ /^Mozilla\/4/) || user_agent =~ /\bMSIE/
        gzip_accepted &&= request.headers['Accept-Encoding'].to_s.include?('gzip')

        if gzip_accepted && gzip_allowed
          host << "/#{CloudfrontAssetHost.gzip_prefix}"
        else
          host << "/#{CloudfrontAssetHost.plain_prefix}" if CloudfrontAssetHost.plain_prefix.present?
        end
      else
        host << "/#{CloudfrontAssetHost.plain_prefix}" if CloudfrontAssetHost.plain_prefix.present?
      end

      host
    end

    def bucket_host
      "#{self.bucket}.s3.amazonaws.com"
    end

    def enable!
      if enabled && !ActionView::Helpers::AssetTagHelper.private_method_defined?(:rewrite_asset_path_without_cloudfront)
        ActionView::Helpers::AssetTagHelper.send(:alias_method_chain, :rewrite_asset_path, :cloudfront)
        ActionView::Helpers::AssetTagHelper.send(:alias_method_chain, :rails_asset_id, :cloudfront)
        ActionView::Helpers::AssetTagHelper.send(:alias_method_chain, :compute_asset_host, :cloudfront)
        ActionView::Helpers::AssetTagHelper.send(:alias_method_chain, :compute_public_path, :cloudfront)
        ActionView::Helpers::AssetTagHelper.send(:alias_method_chain, :stylesheet_link_tag, :cloudfront)
        ActionView::Helpers::AssetTagHelper.send(:alias_method_chain, :javascript_include_tag, :cloudfront)
      end
    end

    def key_for_path(path)
      key_prefix + md5sum(path)[0..8]
    end

    def gzip_allowed_for_source?(source)
      extension = source.split('.').last
      CloudfrontAssetHost.gzip_extensions.include?(extension)
    end

    def image?(path)
      extension = path.split('.').last
      CloudfrontAssetHost.image_extensions.include?(extension)
    end

    def css?(path)
      File.extname(path) == '.css'
    end

    def disable_cdn_for_source?(source)
      source.match(exclude_pattern) if exclude_pattern.present?
    end

  private

    def properly_configured?
      raise "You'll need to specify a bucket" if bucket.blank?
      raise "Could not find S3-configuration" unless File.exists?(s3_config)
      true
    end

    def md5sum(path)
      Digest::MD5.hexdigest(File.read(path))
    end

  end

end
