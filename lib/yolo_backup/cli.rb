require 'thor'

module YOLOBackup
  class CLI < Thor
    class_option :verbose, :type => :boolean

    desc 'status [SERVER]', 'Display backup status and statistics'
    def status(server = nil)
      puts 'STATUS'
    end

    desc 'backup [SERVER]', 'Start backup process'
    def backup(server = nil)
      puts 'BACKUP'
    end
  end
end
