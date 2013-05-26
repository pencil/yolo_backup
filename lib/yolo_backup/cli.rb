require 'thor'
require 'yaml'

require 'yolo_backup'
require 'yolo_backup/storage_pool/file'
require 'yolo_backup/rotation_plan'
require 'yolo_backup/backup_runner'
require 'yolo_backup/server'
require 'yolo_backup/exclude_set'

module YOLOBackup
  class CLI < Thor
    DEFAULT_CONFIG_FILE = '/etc/yolo_backup.yml'
    DEFAULT_STORAGE_POOL_NAME = 'default'
    DEFAULT_ROTATION_PLAN_NAME = 'default'
    DEFAULT_EXCLUDE_SET_NAME = 'default'

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
          puts "  STORAGE NOT READY" unless storage_pool.ready?
        end
      end
    end

    desc 'backup [SERVER]', 'Start backup process'
    option :force, :type => :boolean
    def backup(server = nil)
      backup_runner = BackupRunner.new('servers' => servers, 'verbose' => verbose?, 'force' => force?)
      backup_runner.backup(server)
    end

    desc 'version', 'Display yolo_backup version'
    def version
      puts "yolo_backup #{YOLOBackup::VERSION}"
    end

    private
    def verbose?
      !!options[:verbose]
    end

    def force?
      !!options[:force]
    end

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

    def exclude_sets
      return @exclude_sets unless @exclude_sets.nil?

      (@exclude_sets = {}).tap do |exclude_sets|
        config['exclude_sets'].each do |name, options|
          exclude_sets[name] = ExcludeSet.new(name, options)
        end
      end
    end

    def servers
      return @servers unless @servers.nil?

      (@servers = {}).tap do |servers|
        config['servers'].each do |name, options|
          options['storage'] = storage_by_name(options['storage'])
          options['rotation'] = rotation_by_name(options['rotation'])
          options['excludes'] = (options['excludes'] || []) + exlude_set_by_name(options['exclude_set']).excludes
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

    def exlude_set_by_name(name = nil)
      name ||= DEFAULT_EXCLUDE_SET_NAME
      raise "Exclude set #{name} not defined" unless exclude_sets.key?(name)
      exclude_sets[name]
    end
  end
end
