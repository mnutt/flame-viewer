# via: https://gist.github.com/es/2fd281eebcf82532a453

# Ps.all to get an array of hashes
# Example hash:
# {
#   :user=>"Username",
#   :pid=>5321.0,
#   :cpu=>6.2,
#   :mem=>0.7,
#   :vsz=>3438156.0,
#   :rss=>56568.0,
#   :tt=>"??",
#   :stat=>"S",
#   :started=>"12:59pm",
#   :time=>"14:33.15",
#   :command=>"/Applications/Google"
# }
class Ps
  class << self
    def user
      parse(ps_aux)
    end

    def all
      parse(ps_aux)
    end

    private

    def parse(str)
      processes = str.split /\r?\n/
      processes.shift
      processes.map do |process_str|
        p_obj = {}
        p_arr = process_str.split ' '
        sym_arr = [:user, :pid, :cpu, :mem, :vsz, :rss, :tt, :stat, :started, :time, :command]
        sym_arr.each_with_index do |sym, i|
          begin
            p_obj[sym] = Float(p_arr[i])
          rescue
            p_obj[sym] = p_arr[i]
          end
        end

        p_obj
      end
    end

    def ps_aux
      `ps aux`
    end
  end
end

