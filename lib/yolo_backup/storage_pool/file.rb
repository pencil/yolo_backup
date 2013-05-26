require 'yolo_backup/storage_pool'
require 'yolo_backup/string_interpolate'

class YOLOBackup::StoragePool::File < YOLOBackup::StoragePool
  OPTIONS = %w{ path }

  attr_accessor :path

  def initialize(name, options = nil)
    super
    OPTIONS.each do |key|
      send("#{key}=", options[key]) if options[key]
    end
  end

  def to_s
    "#{name} (#{wildcard_path})"
  end

  private
  def wildcard_path
    YOLOBackup::StringInterpolate.interpolate path, hostname: '*'
  end
end
