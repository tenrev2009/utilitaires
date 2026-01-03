module JackUtils
  module CleanHidden
    def self.remove
      model = Sketchup.active_model
      model.start_operation("Purge Masqués", true)
      model.selection.grep(Sketchup::ComponentInstance).each { |i| clean_rec(i.definition) }
      model.commit_operation
    end

    def self.clean_rec(definition)
      definition.entities.each do |e|
        if e.is_a?(Sketchup::ComponentInstance) || e.is_a?(Sketchup::Group)
          if e.hidden?
            e.erase!
          elsif e.respond_to?(:definition)
            clean_rec(e.definition)
          end
        end
      end
    end
  end
end