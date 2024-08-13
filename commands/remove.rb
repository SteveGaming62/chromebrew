require 'fileutils'
require 'json'
require_relative '../lib/const'
require_relative '../lib/package_utils'

class Command
  def self.remove(pkg, verbose)
    device_json = JSON.load_file(File.join(CREW_CONFIG_PATH, 'device.json'))

    # Make sure the package is actually installed before we attempt to remove it.
    unless PackageUtils.installed?(pkg.name)
      puts "Package #{pkg.name} isn't installed.".lightred
      return
    end

    # Don't remove any of the packages ruby (and thus crew) needs to run.
    if CREW_ESSENTIAL_PACKAGES.include?(pkg.name)
      puts "Refusing to remove essential package #{pkg.name}.".lightred
      return
    end

    # Perform any operations required prior to package removal.
    pkg.preremove

    # Use gem to first try to remove gems...
    if pkg.name.start_with?('ruby_')
      @gem_name = pkg.name.sub('ruby_', '').sub('_', '-')
      if Kernel.system "gem list -i \"^#{@gem_name}\$\""
        puts "Uninstalling #{@gem_name} before updating. It's ok if this fails.".orange
        system "gem uninstall -aIx --abort-on-dependent #{@gem_name}", exception: false
      end
    end

    # Remove the files and directories installed by the package.
    unless pkg.is_fake?
      Dir.chdir CREW_CONFIG_PATH do
        # Remove all files installed by the package.
        flist = File.join(CREW_META_PATH, "#{pkg.name}.filelist")
        if File.file?(flist)
          File.foreach(flist, chomp: true) do |line|
            next unless line.start_with?(CREW_PREFIX)
            if system("grep --exclude #{pkg.name}.filelist -Fxq '#{line}' ./meta/*.filelist")
              puts "#{line} is in another package. It will not be removed during the removal of #{pkg.name}.".orange
            else
              puts "Removing file #{line}".yellow if verbose
              FileUtils.remove_file line, exception: false
            end
          end
          FileUtils.remove_file flist
        end

        # Remove all directories installed by the package.
        dlist = File.join(CREW_META_PATH, "#{pkg.name}.directorylist")
        if File.file?(dlist)
          File.foreach(dlist, chomp: true) do |line|
            next unless Dir.exist?(line) && Dir.empty?(line) && line.include?(CREW_PREFIX)
            puts "Removing directory #{line}".yellow if verbose
            FileUtils.remove_dir line, exception: false
          end
          FileUtils.remove_file dlist
        end
      end
    end

    # Remove the package from the list of installed packages in device.json.
    puts "Removing package #{pkg.name} from device.json".yellow if verbose
    device_json['installed_packages'].delete_if { |entry| entry['name'] == pkg.name }

    # Update device.json with our changes.
    save_json(device_json)

    # Perform any operations required after package removal.
    pkg.postremove

    puts "#{pkg.name} removed!".lightgreen
  end
end
