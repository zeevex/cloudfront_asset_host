module ActionView
   module Helpers
     module AssetTagHelper

    private

      def compute_asset_host_with_cloudfront(source)
        if CloudfrontAssetHost.disable_cdn_for_source?(source)
          compute_asset_host_without_cloudfront(source)
        else
          request = controller.respond_to?(:request) && controller.request
          CloudfrontAssetHost.asset_host(source, request)
        end
      end

      def rewrite_host_and_protocol_with_cloudfront(source, has_request)
        if CloudfrontAssetHost.disable_cdn_for_source?(source)
          rewrite_host_and_protocol_without_cloudfront(source, has_request)
        else
          host = CloudfrontAssetHost.asset_host(source, has_request)
          if has_request && host.present? && !is_uri?(host)
            host = "#{controller.request.protocol}#{host}"
          end
          "#{host}#{source}"
        end
      end

      # Override asset_id so it calculates the key by md5 instead of modified-time
      def rails_asset_id_with_cloudfront(source)
        if CloudfrontAssetHost.disable_cdn_for_source?(source)
          return rails_asset_id_without_cloudfront(source)
        end

        if @@cache_asset_timestamps && (asset_id = @@asset_timestamps_cache[source])
          asset_id
        else
          path = File.join(ASSETS_DIR, source)
          rewrite_path = File.exist?(path) && !CloudfrontAssetHost.disable_cdn_for_source?(source)
          asset_id = rewrite_path ? CloudfrontAssetHost.key_for_path(path) : ''

          if @@cache_asset_timestamps
            @@asset_timestamps_cache_guard.synchronize do
              @@asset_timestamps_cache[source] = asset_id
            end
          end

          asset_id
        end
      end

      # Override asset_path so it prepends the asset_id
      def rewrite_asset_path_with_cloudfront(source)
        if CloudfrontAssetHost.disable_cdn_for_source?(source)
          rewrite_asset_path_without_cloudfront(source)
        else
          asset_id = rails_asset_id_with_cloudfront(source)
          if asset_id.blank?
            source
          else
            "/#{asset_id}#{source}"
          end
        end
      end

     end
   end
end
