module JackUtils
  module CleanDC
    def self.remove
      model = Sketchup.active_model
      model.start_operation("Supprimer DC", true)
      model.selection.grep(Sketchup::ComponentInstance).each { |i| clean_rec(i) }
      model.commit_operation
    end

    def self.clean_rec(inst)
      if inst.attribute_dictionaries
        inst.attribute_dictionaries.delete('dynamic_attributes')
      end
      if inst.definition.attribute_dictionaries
        inst.definition.attribute_dictionaries.delete('dynamic_attributes')
      end
      inst.definition.entities.grep(Sketchup::ComponentInstance).each { |child| clean_rec(child) }
    end
  end
end