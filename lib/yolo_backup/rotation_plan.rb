module YOLOBackup
  class RotationPlan
    SCHEDULE_OPTIONS = %w{ hourly daily weekly monthly yearly }

    SCHEDULE_OPTIONS.each do |option|
      attr_accessor option
    end

    attr_reader :name

    def initialize(name, options)
      @name = name
      SCHEDULE_OPTIONS.each do |option|
        send("#{option}=", options[option]) if options.key?(option)
      end
    end
  end
end
