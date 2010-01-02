require 'singleton'
require 'fileutils'

class BuilderStarter

  include FileUtils
  
  @@run_builders_at_startup = true;
  
  def self.run_builders_at_startup=(value)
    @@run_builders_at_startup = value
  end

  def self.start_builders
    if @@run_builders_at_startup
      Project.all.each do |project|
        begin_builder project.name
      end
    end
  end
  
  def self.begin_builder(project_name)
    cruise_executable = "#{builder_interpreter} #{path_to_cruise}".strip
    verbose_option = $VERBOSE_MODE ? " --trace" : ""
    command = "#{cruise_executable} build #{project_name}#{verbose_option}"

    Platform.create_child_process(project_name, command)
  end

  def self.path_to_cruise(extension = '')
    CommandLine.escape(File.join(RAILS_ROOT, "cruise#{extension}"))
  end

  private
    # Returns the interpreter command to be used when running cruise
    def self.builder_interpreter
      if Platform.interpreter =~ /jruby/
        Platform.interpreter
      elsif Platform.family == 'mswin32'
        'ruby'
      else
        ''
      end
    end
end
