module I18nTestHelper
  def using_translation_file(filename, &block)
    @i18n_load_path_stack ||= []
    @i18n_load_path_stack.push I18n.config.load_path.dup
    I18n.config.load_path.unshift(filename)
    I18n.reload!
    yield
    I18n.config.load_path = @i18n_load_path_stack.pop
    I18n.reload!
  end

  def use_only_translation_file!(filename)
    @i18n_load_path_stack ||= []
    @i18n_load_path_stack.push I18n.config.load_path.dup
    I18n.config.load_path = [filename]
    I18n.reload!
  end

  def reset_translation_files!
    I18n.config.load_path = @i18n_load_path_stack.pop
    I18n.reload!
  end

  def using_only_translation_file(filename, &block)
    use_only_translation_file!(filename)
    yield
    reset_translation_files!
  end
end
