require 'net/ftp'
require 'fileutils'

class FtpTransfer

  attr_reader :cwk, :config, :notifier_manager

  LOCK_FILE = 'uploader.lock'

  def initialize(config, notifier_manager)
    @cwk = Dir.getwd
    @notifier_manager = notifier_manager
    @config = config
  end

  def run
    transfer(config['source'], config['destination'])
  end

  def transfer(src, dest)
    check_lock
    local_files = get_local_files(src, config['exclude'])
    upload_files(local_files, dest)
    notifier_manager.update_notifiers(local_files) unless local_files.empty?
    remove_lock
  end

  private

  def check_lock
    if File.file?(LOCK_FILE)
      file_younger_than?(3600) ? exit : remove_lock
    end
    FileUtils.touch(LOCK_FILE)
  end

  def file_younger_than?(seconds)
    Time.now - File.ctime(LOCK_FILE) < seconds
  end

  def remove_lock
    Dir.chdir(cwk)
    FileUtils.rm(LOCK_FILE)
  end

  def get_local_files(local_dir, exclude = [])
    Dir.chdir(local_dir)
    Dir.glob('**/*.*').delete_if do |f|
      f.start_with?(*exclude)
    end
  end

  def upload_files(local_files, dest_dir)
    ftp_setting = config['ftp_settings']
    Net::FTP.open(ftp_setting['host'], ftp_setting['username'], ftp_setting['password']) do |ftp|
      ftp.passive = true
      local_files.each { |file| upload_file(ftp, file, dest_dir) }
    end
  end

  def upload_file(ftp, local_file, dest_dir)
    ftp.chdir(dest_dir)
    local_dirs = File.dirname(local_file).split('/')
    local_dirs.each do |dir|
      begin
        ftp.chdir dir
      rescue Net::FTPPermError => e
        ftp.mkdir dir
        ftp.chdir dir
      end
    end
    ftp.putbinaryfile(local_file)
    File.delete(local_file)
  end
end