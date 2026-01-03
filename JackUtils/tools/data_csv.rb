require 'csv'
module JackUtils
  module DataCSV
    def self.export
      sel = Sketchup.active_model.selection.grep(Sketchup::ComponentInstance)
      return if sel.empty?
      
      attrs = UI.inputbox(["Attrs (sep ,)"], ["assise,pied,plateau"], "Champs à exporter")[0].split(',')
      path = UI.savepanel("Export CSV", "", "data.csv")
      return unless path

      CSV.open(path, "wb") do |csv|
        csv << ["Nom"] + attrs
        sel.each do |c|
          vals = attrs.map { |a| c.get_attribute("dynamic_attributes", a) }
          csv << [c.definition.name] + vals
        end
      end
    end

    def self.import
      path = UI.openpanel("Import CSV", "", "data.csv")
      return unless path
      
      data = CSV.read(path, headers: true)
      model = Sketchup.active_model
      model.start_operation("Import CSV", true)
      
      sel = model.selection.grep(Sketchup::ComponentInstance)
      
      data.each do |row|
        comp = sel.find { |c| c.definition.name == row["Nom"] }
        next unless comp
        row.headers.each do |h|
          next if h == "Nom"
          comp.set_attribute("dynamic_attributes", h, row[h])
        end
        $dc_observers.get_latest_class.redraw(comp) if defined?($dc_observers)
      end
      model.commit_operation
    end

    def self.redraw
      model = Sketchup.active_model
      sel = model.selection.grep(Sketchup::ComponentInstance)
      model.start_operation("Redraw", true)
      sel.each { |c| $dc_observers.get_latest_class.redraw(c) } if defined?($dc_observers)
      model.commit_operation
    end
  end
end