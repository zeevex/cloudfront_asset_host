require 'right_aws'
require 'tempfile'

module CloudfrontAssetHost
  module Uploader

    class << self

      def upload!(options = {})
        puts "-- Updating uncompressed files" if options[:verbose]
        upload_keys_with_paths(keys_with_paths, options)

        if CloudfrontAssetHost.gzip
          puts "-- Updating compressed files" if options[:verbose]
          upload_keys_with_paths(gzip_keys_with_paths, options.merge(:gzip => true))
        end

        @existing_keys = nil
      end

      def upload_keys_with_paths(keys_paths, options={})
        gzip = options[:gzip] || false
        dryrun = options[:dryrun] || false
        verbose = options[:verbose] || false

        keys_paths.each do |key, path|
          if should_upload?(key, options)
            puts "+ #{key}" if verbose

            extension = File.extname(path)[1..-1]

            path = rewritten_css_path(path)

            data_path = gzip ? gzipped_path(path) : path
            bucket.put(key, File.read(data_path), {}, 'public-read', headers_for_path(extension, gzip)) unless dryrun

            File.unlink(data_path) if gzip && File.exists?(data_path)
          else
            puts "= #{key}" if verbose
          end
        end
      end

      def should_upload?(key, options={})
        return false if CloudfrontAssetHost.disable_cdn_for_source?(key)
        return true  if CloudfrontAssetHost.css?(key) && rewrite_all_css?

        options[:force_write] || !existing_keys.include?(key)
      end

      def gzipped_path(path)
        tmp = Tempfile.new("cfah-gz")
        `gzip '#{path}' -q -c > '#{tmp.path}'`
        tmp.path
      end

      def rewritten_css_path(path)
        if CloudfrontAssetHost.css?(path)
          tmp = CloudfrontAssetHost::CssRewriter.rewrite_stylesheet(path)
          tmp.path
        else
          path
        end
      end

      def keys_with_paths
        current_paths.inject({}) do |result, path|
          key = CloudfrontAssetHost.plain_prefix.present? ? "#{CloudfrontAssetHost.plain_prefix}/" : ""
          key << CloudfrontAssetHost.key_for_path(path) + path.gsub(Rails.public_path, '')

          result[key] = path
          result
        end
      end

      def gzip_keys_with_paths
        current_paths.inject({}) do |result, path|
          source = path.gsub(Rails.public_path, '')

          if CloudfrontAssetHost.gzip_allowed_for_source?(source)
            key = "#{CloudfrontAssetHost.gzip_prefix}/" << CloudfrontAssetHost.key_for_path(path) << source
            result[key] = path
          end

          result
        end
      end

      def rewrite_all_css?
        @rewrite_all_css ||= !keys_with_paths.delete_if { |key, path| existing_keys.include?(key) || !CloudfrontAssetHost.image?(path) }.empty?
      end

      def existing_keys
        @existing_keys ||= begin
          keys = []
          prefix = CloudfrontAssetHost.key_prefix
          prefix = "#{CloudfrontAssetHost.plain_prefix}/#{prefix}" if CloudfrontAssetHost.plain_prefix.present?
          keys.concat bucket.keys('prefix' => prefix).map  { |key| key.name }
          keys.concat bucket.keys('prefix' => CloudfrontAssetHost.gzip_prefix).map { |key| key.name }
          keys
        end
      end

      def current_paths
        @current_paths ||= Dir.glob("#{Rails.public_path}/{#{asset_dirs.join(',')}}/**/*").reject { |path| File.directory?(path) }
      end

      def headers_for_path(extension, gzip = false)
        mime = ext_to_mime[extension] || 'application/octet-stream'
        headers = {
          'Content-Type' => mime,
          'Cache-Control' => "max-age=#{10.years.to_i}",
        }
        headers['Content-Encoding'] = 'gzip' if gzip

        headers
      end

      def ext_to_mime
        @ext_to_mime ||= Hash[ *( YAML::load_file(File.join(File.dirname(__FILE__), "mime_types.yml")).collect { |k,vv| vv.collect{ |v| [v,k] } }.flatten ) ]
      end

      def bucket
        @bucket ||= begin
          bucket = s3.bucket(CloudfrontAssetHost.bucket)
          bucket.disable_logging unless CloudfrontAssetHost.s3_logging
          bucket
        end
      end

      def s3
        @s3 ||= RightAws::S3.new(config['access_key_id'], config['secret_access_key'])
      end

      def config
        @config ||= begin 
          config = YAML::load_file(CloudfrontAssetHost.s3_config)
          config.has_key?(Rails.env) ? config[Rails.env] : config
        end
      end

      def asset_dirs
        @asset_dirs ||= CloudfrontAssetHost.asset_dirs
      end

    end

  end
end
