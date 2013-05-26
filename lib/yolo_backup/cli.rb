require 'thor'
require 'yaml'

require 'yolo_backup/storage_pool/file'

module YOLOBackup
  class CLI < Thor
    DEFAULT_CONFIG_FILE = '/etc/yolo_backup.yml'

    class_option :verbose, :type => :boolean
    class_option :config, :type => :string, :banner => "path to config file (default #{DEFAULT_CONFIG_FILE})"

    desc 'status', 'Display backup status and statistics'
    def status(storage = nil)
      storage_pools.each do |storage_pool|
        puts "#{storage_pool}:"
      end
    end

    desc 'backup [SERVER]', 'Start backup process'
    def backup(server = nil)
      puts 'BACKUP'
    end

    private
    def config
      @config ||= YAML::load(File.open(options[:config] || DEFAULT_CONFIG_FILE))
    end

    def storage_pools
      return @storage_pools unless @storage_pools.nil?

      (@storage_pools = []).tap do |storage_pools|
        config['storages'].each do |name, options|
          storage_pools << StoragePool::File.new(name, options)
        end
      end
    end
  end
end