require 'thor'
require 'yaml'

require 'yolo_backup/storage_pool/file'
require 'yolo_backup/rotation_plan'
require 'yolo_backup/backup_runner/rsync'
require 'yolo_backup/server'

module YOLOBackup
  class CLI < Thor
    DEFAULT_CONFIG_FILE = '/etc/yolo_backup.yml'
    DEFAULT_STORAGE_POOL_NAME = 'default'
    DEFAULT_ROTATION_PLAN_NAME = 'default'

    class_option :verbose, :type => :boolean
    class_option :config, :type => :string, :banner => "path to config file (default #{DEFAULT_CONFIG_FILE})"

    desc 'status', 'Display backup status and statistics'
    def status(storage = nil)
      storage_pools.values.each do |storage_pool|
        puts "#{storage_pool}:"
        if storage_pool.ready?
          storage_pool.statistics.tap do |stats|
            puts "  Capacity:  #{'%4d' % (stats[:capacity] / 1000 / 1000 / 1000)} GB"
            puts "  Available: #{'%4d' % (stats[:available] / 1000 / 1000 / 1000)} GB"
          end
        else
          puts "  DEVICE NOT READY" unless storage_pool.ready?
        end
      end
    end

    desc 'backup [SERVER]', 'Start backup process'
    def backup(server = nil)
      puts 'BACKUP'
      p servers
      p rotation_plans
    end

    private
    def config
      @config ||= YAML::load(File.open(options[:config] || DEFAULT_CONFIG_FILE))
    end

    def storage_pools
      return @storage_pools unless @storage_pools.nil?

      (@storage_pools = {}).tap do |storage_pools|
        config['storages'].each do |name, options|
          storage_pools[name] = StoragePool::File.new(name, options)
        end
      end
    end

    def rotation_plans
      return @rotation_plans unless @rotation_plans.nil?

      (@rotation_plans = {}).tap do |rotation_plans|
        config['rotations'].each do |name, options|
          rotation_plans[name] = RotationPlan.new(name, options)
        end
      end
    end

    def servers
      return @servers unless @servers.nil?

      (@servers = {}).tap do |servers|
        config['servers'].each do |name, options|
          options['storage'] = storage_by_name(options['storage'])
          options['rotation'] = rotation_by_name(options['rotation'])
          servers[name] = Server.new(name, options)
        end
      end
    end

    def storage_by_name(name = nil)
      name ||= DEFAULT_STORAGE_POOL_NAME
      raise "Storage #{name} not defined" unless storage_pools.key?(name)
      storage_pools[name]
    end

    def rotation_by_name(name = nil)
      name ||= DEFAULT_ROTATION_PLAN_NAME
      raise "Rotation plan #{name} not defined" unless rotation_plans.key?(name)
      rotation_plans[name]
    end
  end
end
