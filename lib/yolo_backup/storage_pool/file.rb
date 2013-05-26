require 'sys/filesystem'

require 'yolo_backup/storage_pool'
require 'yolo_backup/core_ext/string'

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

  def statistics
    stats = Sys::Filesystem.stat(base_path)
    {
      capacity: stats.blocks * stats.block_size,
      available: stats.blocks_available * stats.block_size
    }
  end

  def ready?
    ::File.directory?(base_path) && ::File.readable?(base_path)
  end

  def latest_backup(server)
    return nil unless ::File.directory?(base_path) && ::File.symlink?("#{base_path}/latest")
    target = File.readlink("#{base_path}/latest")
  end

  private
  def wildcard_path
    path.interpolate :hostname => '*'
  end

  def base_path
    path.interpolate(:hostname => '')
  end

  def server_path(hostname)
    path.interpolate(:hostname => hostname)
  end
end
