# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mini_mongo"
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Dwan"]
  s.date = "2012-02-15"
  s.description = "still pending"
  s.email = "mpdwan@gmail.com"
  s.executables = ["console"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/console",
    "lib/core_ext/hash.rb",
    "lib/extensions/object_id.rb",
    "lib/mini_mongo.rb",
    "lib/mini_mongo/concerns/callbacks.rb",
    "lib/mini_mongo/concerns/dirty.rb",
    "lib/mini_mongo/concerns/modifications.rb",
    "lib/mini_mongo/concerns/persistance.rb",
    "lib/mini_mongo/concerns/serialization.rb",
    "lib/mini_mongo/concerns/validation.rb",
    "lib/mini_mongo/document.rb",
    "lib/mini_mongo/dot_hash.rb",
    "mini_mongo.gemspec",
    "test/helper.rb",
    "test/test_dirty.rb",
    "test/test_document.rb",
    "test/test_dot_hash.rb",
    "test/test_mini_mongo.rb",
    "test/test_modifications.rb",
    "test/test_persistance.rb",
    "test/test_serialization.rb",
    "test/test_validation_errors.rb"
  ]
  s.homepage = "http://github.com/michaeldwan/mini_mongo"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "pending"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mongo>, ["~> 1.5.2"])
      s.add_runtime_dependency(%q<bson_ext>, ["~> 1.5.2"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.5"])
      s.add_runtime_dependency(%q<activemodel>, [">= 3.0.5"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<yard>, ["~> 0.7"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<mongo>, ["~> 1.5.2"])
      s.add_dependency(%q<bson_ext>, ["~> 1.5.2"])
      s.add_dependency(%q<activesupport>, [">= 3.0.5"])
      s.add_dependency(%q<activemodel>, [">= 3.0.5"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<yard>, ["~> 0.7"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<mongo>, ["~> 1.5.2"])
    s.add_dependency(%q<bson_ext>, ["~> 1.5.2"])
    s.add_dependency(%q<activesupport>, [">= 3.0.5"])
    s.add_dependency(%q<activemodel>, [">= 3.0.5"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<yard>, ["~> 0.7"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end

