require 'sinatra'
require './ps'
require 'tempfile'

if ENV['EUID'] == '0' && !ENV['RUN_UNSAFELY_AS_ROOT']
  puts "You should not run this as root."
  exit 1
end

def get_processes(search)
  Ps.all.select{|i| i[:command] =~ /#{search}/ && !i[:command].start_with?('[') }
end

# Listening on anything other than the loopback is almost certainly unsafe
set :bind, '127.0.0.1'

get '/' do
  @processes = get_processes(ENV['PROC_PATTERN'])

  erb :index
end

post '/profile/:pid' do
  referer = request.env['HTTP_REFERER']
  referer_host = URI.parse(referer).host

  return "BAD REQUEST" unless referer_host == "localhost"

  pid = params[:pid].to_i
  process = get_processes(ENV['PROC_PATTERN']).find{|process| process[:pid].to_i == pid }
  return "BAD PID" unless process

  sample_time = (params[:sample_time] || 20).to_i
  sample_rate = (params[:sample_rate] || 99).to_i

  if sample_time <= 0 || sample_rate <= 0 || sample_time > 120 || sample_rate > 999
    return "BAD REQUEST"
  end

  data_path = Tempfile.new.path
  puts "Writing to: #{data_path}"

  puts `sudo perf record -p #{pid} -o "#{data_path}" -F #{sample_rate} --call-graph dwarf -g -- sleep #{sample_time}`

  perf_path = Tempfile.new.path
  puts `perf script -i "#{data_path}" > "#{perf_path}"`

  folded_path = Tempfile.new.path
  puts `./flame-graph/stackcollapse-perf.pl "#{perf_path}" > "#{folded_path}"`

  svg = `./flame-graph/flamegraph.pl "#{folded_path}"`.chomp

  content_type :svg
  svg
end
