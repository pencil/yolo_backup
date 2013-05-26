require 'thor'

module YOLOBackup
  class CLI < Thor
    DEFAULT_CONFIG_FILE = '/etc/yolo_backup.yml'

    class_option :verbose, :type => :boolean
    class_option :config, :type => :string, :banner => "path to config file (default #{DEFAULT_CONFIG_FILE})"

    desc 'status [SERVER]', 'Display backup status and statistics'
    def status(server = nil)
      puts 'STATUS'
    end

    desc 'backup [SERVER]', 'Start backup process'
    def backup(server = nil)
      puts 'BACKUP'
    end

    private
    def config
      @config ||= YAML::load(File.open(options[:config] || DEFAULT_CONFIG_FILE))
    end
  end
end
