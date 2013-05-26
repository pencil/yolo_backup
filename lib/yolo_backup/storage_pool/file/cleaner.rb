require 'fileutils'

require 'yolo_backup/storage_pool/file'

class YOLOBackup::StoragePool::File::Cleaner
  attr_reader :storage_pool, :server

  def initialize(storage_pool, server)
    @storage_pool = storage_pool
    @server = server
  end

  def cleanup
    unused_backups = all_backups - required_backups
    unused_backups.each do |unused_backup|
      path = "#{server_path}/#{unused_backup.iso8601}"
      p path
      FileUtils.rm_r path, :force => true
    end
    unused_backups
  end

  private
  def required_backups
    required_backups = {}
    all_backups.each do |date|
      {
        :year => :yearly,
        :month => :monthly,
        :week => :weekly,
        :day => :daily,
        :hour => :hourly
      }.each do |accuracy, schedule_option_name|
        keep_count = server.rotation.send("#{schedule_option_name}").to_i
        next if keep_count.nil? || keep_count.zero?
        if required_backups[accuracy].nil?
          required_backups[accuracy] = [date]
        elsif !same_date(date, required_backups[accuracy].last, accuracy)
          required_backups[accuracy] << date
        end
        if required_backups[accuracy].length > keep_count
          required_backups[accuracy].shift
        end
      end
    end
    required_backups = required_backups.values.flatten
    required_backups << server.latest_backup
    required_backups.uniq
  end

  def all_backups
    backups = []
    Dir.chdir(server_path) do
      Dir.entries('.').sort.each do |file|
        next if ['.', '..'].include?(file)
        next unless ::File.directory?(file) && !::File.symlink?(file)
        backups << Time.parse(file)
      end
    end
    backups
  end

  def server_path
    storage_pool.path.interpolate(:hostname => server)
  end

  def same_date(time1, time2, accuracy)
    end_of = "end_of_#{accuracy}"
    time1.send(end_of) == time2.send(end_of)
  end
end
