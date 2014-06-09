class NotifierManager

  def initialize
    @notifiers = Array.new
  end

  def add_notifiers(config)
    return if config['notifications'].nil?
    config['notifications'].each do |n|
      notify_method = n[0]
      notifier_obj = Object.const_get("#{notify_method.capitalize}Notifier").new(config)
      add_notifier(notifier_obj)
    end
  end

  def add_notifier(notifier)
    @notifiers << notifier
  end

  def update_notifiers(args)
    @notifiers.each { |n| n.update(args) }
  end
end