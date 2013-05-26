class String
  INTERPOLATION_PATTERN = Regexp.union(
    /%%/,
    /%\{(\w+)\}/
  )
  def interpolate(values)
    self.gsub(INTERPOLATION_PATTERN) do |match|
      if match == '%%'
        '%'
      else
        key = ($1 || $2).to_sym
        unless values.key?(key)
          raise "Mission interpolation argument: #{key}"
        end
        value = values[key]
        value = value.call(values) if value.respond_to?(:call)
        $3 ? sprintf("%#{$3}", value) : value
      end
    end
  end
end
