module YOLOBackup
  class Server
    OPTIONS = %w{ ssh_key rotation storage }

    OPTIONS.each do |option|
      attr_accessor option
    end

    attr_reader :name

    def initialize(name, options)
      @name = name
      OPTIONS.each do |option|
        send("#{option}=", options[option]) if options.key?(option)
      end
    end
  end
end