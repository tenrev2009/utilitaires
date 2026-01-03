module JackUtils
  module SelectSimilar
    def self.select_similar
      model = Sketchup.active_model
      sel = model.selection
      if sel.empty?
        UI.messagebox("Sélectionnez un composant.")
        return
      end
      
      names = sel.grep(Sketchup::ComponentInstance).map { |c| c.definition.name.split("#").first }.uniq
      patterns = names.map { |n| /^#{Regexp.escape(n)}(#\d+)?$/ }
      
      sel.clear
      model.definitions.each do |d|
        next unless patterns.any? { |p| d.name =~ p }
        d.instances.each { |i| sel.add(i) }
      end
      Sketchup.status_text = "Sélection similaire terminée."
    end
  end
end