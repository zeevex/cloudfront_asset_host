namespace :cloudfront do
  desc <<-DESC
  Upload assets to Cloudfront CDN.
  
  Set VERBOSE=true for detailed output
      FORCE=true to force upload of unchanged assets
      DRYRUN=true to simulate an upload'
  DESC
  task :upload => :environment do
    CloudfrontAssetHost::Uploader.upload!(:verbose => ENV["VERBOSE"] == "true",
                                          :dryrun => ENV["DRYRUN"] == "true", 
                                          :force_write => ENV["FORCE"] == "true")
  end
end
