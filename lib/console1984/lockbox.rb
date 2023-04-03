require 'console1984'
require 'lockbox'
require 'console1984/lockbox/version'

module Console1984::Lockbox
  def self.root
    Gem::Specification.find_by_name('console1984-lockbox').gem_dir
  end

  def self.config
    File.join root, 'config'
  end

  def self.lockbox_protections_path
    File.join config, 'lockbox-protections.yml'
  end
end

module Console1984::Shield::Modes
  def enable_unprotected_mode(silent: false)
    command_executor.run_as_system do
      show_warning Console1984.enter_unprotected_encryption_mode_warning if !silent && protected_mode?
      justification = ask_for_value "\nBefore you can access personal information, you need to ask for and get explicit consent from the user(s). #{current_username}, where can we find this consent (a URL would be great)?"
      session_logger.start_sensitive_access justification
      nil
    end
  ensure
    @mode = UNPROTECTED_MODE
    Lockbox.disable_protected_mode
    nil
  end

  def enable_protected_mode(silent: false)
    command_executor.run_as_system do
      show_warning Console1984.enter_protected_mode_warning if !silent && unprotected_mode?
      session_logger.end_sensitive_access
      nil
    end
  ensure
    @mode = PROTECTED_MODE
    Lockbox.enable_protected_mode
    nil
  end
end

class Console1984::Config
  def protections_config
    return @protections_config if @protections_config

    default_configs = YAML.safe_load(File.read(PROTECTIONS_CONFIG_FILE_PATH)).symbolize_keys
    lockbox_configs = YAML.safe_load(File.read(Console1984::Lockbox.lockbox_protections_path)).symbolize_keys
    configs = default_configs.deep_merge(lockbox_configs) { |k, def_conf, lock_conf| def_conf + lock_conf }

    @protections_config = Console1984::ProtectionsConfig.new(configs)
  end
end
