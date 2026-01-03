module JackUtils
  module Unique
    def self.make_unique_recursive(entity)
      if entity.is_a?(Sketchup::ComponentInstance)
        unique_entity = entity.make_unique
        unique_entity.definition.entities.each { |child| make_unique_recursive(child) }
      elsif entity.is_a?(Sketchup::Group)
        entity.entities.each { |child| make_unique_recursive(child) }
      end
    end

    def self.make_selection_unique
      Sketchup.active_model.selection.each { |e| make_unique_recursive(e) }
    end
  end
end