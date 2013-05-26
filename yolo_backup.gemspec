# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'yolo_backup/version'

Gem::Specification.new do |s|
  s.name        = 'yolo_backup'
  s.version     = YOLOBackup::VERSION
  s.authors     = ['Nils Caspar']
  s.email       = 'ncaspar@me.com'
  s.homepage    = 'http://github.org/pencil/yolo_backup'
  s.license     = 'MIT'
  s.summary     = 'A simple Ruby script to create incremental backups of multiple servers using rsync over SSH.'
  s.description = 'yolo_backup allows you to create incremental backups of multiple servers using rsync over SSH. You can specify which backups to keep (daily, weekly, monthly, …) on a per-server basis.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec', '~> 2.12'
  s.add_development_dependency 'simplecov', '~> 0.7'

end
