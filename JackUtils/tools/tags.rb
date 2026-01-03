module JackUtils
  module Tags
    @saved_state = []

    def self.masquer_autres
      model = Sketchup.active_model
      sel = model.selection
      return if sel.empty?

      layers = model.layers
      keep_layers = sel.map(&:layer).uniq
      
      @saved_state = layers.select(&:visible?)
      
      model.start_operation("Isoler Balises", true)
      layers.each { |l| l.visible = keep_layers.include?(l) }
      # Toujours garder le layer0 ou actif visible pour éviter les bugs
      model.active_layer.visible = true 
      model.commit_operation
    end

    def self.restaurer
      return if @saved_state.empty?
      model = Sketchup.active_model
      model.start_operation("Restaurer Balises", true)
      model.layers.each { |l| l.visible = @saved_state.include?(l) }
      model.commit_operation
    end
  end
end