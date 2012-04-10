require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |gem|
    gem.name = "hiera-simpledb"
    gem.version = "0.0.1"
    gem.summary = "Simpledb backend for Hiera"
    gem.email = "nathan.butler@newsweekdailybeast.com"
    gem.author = "Nathan Butler"
    gem.homepage = "http://github.com/butlern/hiera-simpledb"
    gem.description = "Hiera back end for retrieving configuration values from SimpleDB"
    gem.require_path = "lib"
    gem.files = FileList["lib/**/*"].to_a
    gem.add_dependency('hiera', '>=0.2.0')
    gem.add_dependency('aws-sdk', '>=1.3.9')
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end
