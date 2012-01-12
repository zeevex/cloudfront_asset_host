# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "cloudfront_asset_host"
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Menno van der Sman"]
  s.date = "2012-01-12"
  s.description = "Easy deployment of your assets on CloudFront or S3 using a simple rake-task. When enabled in production, the application's asset_host and public_paths will point to the correct location."
  s.email = "menno@wakoopa.com"
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "BUGS-zeevex.txt",
    "Gemfile",
    "Gemfile.lock",
    "MIT-LICENSE",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "cloudfront_asset_host.gemspec",
    "lib/cloudfront_asset_host.rb",
    "lib/cloudfront_asset_host/asset_tag_helper_ext.rb",
    "lib/cloudfront_asset_host/css_rewriter.rb",
    "lib/cloudfront_asset_host/mime_types.yml",
    "lib/cloudfront_asset_host/uploader.rb",
    "lib/tasks/cloudfront_asset_host.rake",
    "test/app/config/s3-env.yml",
    "test/app/config/s3.yml",
    "test/app/public/images/image.png",
    "test/app/public/javascripts/.gitignore",
    "test/app/public/javascripts/application.js",
    "test/app/public/stylesheets/.gitignore",
    "test/app/public/stylesheets/style.css",
    "test/cloudfront_asset_host_test.rb",
    "test/css_rewriter_test.rb",
    "test/taghelper_ext_test.rb",
    "test/test_helper.rb",
    "test/uploader_test.rb"
  ]
  s.homepage = "http://github.com/menno/cloudfront_asset_host"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Rails plugin to easily and efficiently deploy your assets on Amazon's S3 or CloudFront"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<cloudfront_asset_host>, [">= 0"])
      s.add_development_dependency(%q<rails>, ["= 2.3.9"])
      s.add_development_dependency(%q<activesupport>, ["= 2.3.9"])
      s.add_development_dependency(%q<actionpack>, ["= 2.3.9"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<redgreen>, [">= 0"])
      s.add_development_dependency(%q<turn>, [">= 0"])
      s.add_runtime_dependency(%q<right_aws>, [">= 0"])
      s.add_development_dependency(%q<activesupport>, ["= 2.3.9"])
      s.add_development_dependency(%q<actionpack>, ["= 2.3.9"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<redgreen>, [">= 0"])
      s.add_development_dependency(%q<turn>, [">= 0"])
    else
      s.add_dependency(%q<cloudfront_asset_host>, [">= 0"])
      s.add_dependency(%q<rails>, ["= 2.3.9"])
      s.add_dependency(%q<activesupport>, ["= 2.3.9"])
      s.add_dependency(%q<actionpack>, ["= 2.3.9"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<redgreen>, [">= 0"])
      s.add_dependency(%q<turn>, [">= 0"])
      s.add_dependency(%q<right_aws>, [">= 0"])
      s.add_dependency(%q<activesupport>, ["= 2.3.9"])
      s.add_dependency(%q<actionpack>, ["= 2.3.9"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<redgreen>, [">= 0"])
      s.add_dependency(%q<turn>, [">= 0"])
    end
  else
    s.add_dependency(%q<cloudfront_asset_host>, [">= 0"])
    s.add_dependency(%q<rails>, ["= 2.3.9"])
    s.add_dependency(%q<activesupport>, ["= 2.3.9"])
    s.add_dependency(%q<actionpack>, ["= 2.3.9"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<redgreen>, [">= 0"])
    s.add_dependency(%q<turn>, [">= 0"])
    s.add_dependency(%q<right_aws>, [">= 0"])
    s.add_dependency(%q<activesupport>, ["= 2.3.9"])
    s.add_dependency(%q<actionpack>, ["= 2.3.9"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<redgreen>, [">= 0"])
    s.add_dependency(%q<turn>, [">= 0"])
  end
end

