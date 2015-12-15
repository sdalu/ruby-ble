require 'yard'

Bundler::GemHelper.install_tasks

YARD::Rake::YardocTask.new do |t|
    t.files         = [ 'lib/**/*.rb' ]
    t.options       = [ ]
    t.stats_options = [ '--list-undoc' ]
end
