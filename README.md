Moves files from one location to another via FTP while preserving their folder structure.
Get notifications when the files have been uploaded.

## Usage
Create a `config.yml` and set the following.

```
ftp_settings:
  host: example.com
  username: example
  password: pa55word

source: /downloads
destination: /files
exclude: [dir1, dir2]
```

### Adding Notifications

Inside `config.yml`, add your notifier to the `notifications` list and include any settings.

```
notifications:
  email:
    some: setting
    settings:
      - setting
      - setting
```

#### Create a notifier class

1. Class name must start with the name given in the `config.yml` notifications and end with `Notifier` such as  `EmailNotifier`. `notifier_manager.rb` will initialize each notifier with a hash of the config settings.
3. Implement an `update` method. This is called once the files have been uploaded. A list of uploaded files will be passed to this method.

### Running

```ruby
config = YAML.load_file(File.join(__dir__, 'config.yml'))

notifier_manager = NotifierManager.new
notifier_manager.add_notifiers(config)

ftp_transfer = FtpTransfer.new(config, notifier_manager)
ftp_transfer.run
```