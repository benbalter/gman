module RubyProf
  class Thread
    def top_methods
      self.methods.select do |method_info|
        method_info.call_infos.detect(&:root?)
      end
    end

    def top_call_infos
      top_methods.map(&:call_infos).flatten.select(&:root?)
    end

    def total_time
      self.top_methods.inject(0) do |sum, method_info|
        method_info.call_infos.each do |call_info|
          if call_info.parent.nil?
            sum += call_info.total_time
          end
        end
        sum
      end
    end

    def wait_time
      # wait_time, like self:time, is always method local
      # thus we need to sum over all methods and call infos
      self.methods.inject(0) do |sum, method_info|
        method_info.call_infos.each do |call_info|
          sum += call_info.wait_time
        end
        sum
      end
    end
  end
end
