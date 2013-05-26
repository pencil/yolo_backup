require 'time'
require 'sys/filesystem'

require 'yolo_backup/storage_pool'
require 'yolo_backup/core_ext/string'

class YOLOBackup::StoragePool::File < YOLOBackup::StoragePool
  require 'yolo_backup/storage_pool/file/cleaner'

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
    server_path = server_path(server)
    return nil unless ::File.directory?(server_path) && ::File.symlink?("#{server_path}/latest")
    target = ::File.basename(::File.readlink("#{server_path}/latest"))
    Time.parse(target)
  end

  def initiate_backup(server, &block)
    server_path = server_path(server)
    path = "#{server_path}/#{Time.now.iso8601}/"
    FileUtils.mkdir_p(path)
    yield(path)
    latest_path = "#{server_path}/latest"
    ::File.unlink(latest_path) if ::File.exists?(latest_path)
    ::File.symlink(path, latest_path)
  end

  def cleanup(server)
    cleaner = Cleaner.new(self, server)
    cleaner.cleanup
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
