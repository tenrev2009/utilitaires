# Fichier: Plugins/JackUtils/tools/io_skp.rb
module JackUtils
  module IOSkp
    # Constante locale pour le chemin des composants internes (Armoire)
    PATH_COMPS = File.join(JackUtils::PATH_ROOT, 'assets', 'components')

    # --- EXPORT ---
    def self.export_components
      folder = UI.select_directory(title: "Dossier Export")
      return unless folder
      
      count = 0
      Sketchup.active_model.definitions.each do |d|
        # On ignore les groupes, images et définitions internes
        next if d.group? || d.image? || d.internal?
        # On sauvegarde le composant
        d.save_as(File.join(folder, "#{d.name}.skp"))
        count += 1
      end
      UI.messagebox("Export terminé : #{count} composants exportés.")
    end

    # --- IMPORT DOSSIER (CORRIGÉ) ---
    def self.import_folder
      folder = UI.select_directory(title: "Dossier Import")
      return unless folder
      
      model = Sketchup.active_model
      model.start_operation("Import Dossier", true)
      
      files = Dir.glob(File.join(folder, "*.skp")).sort
      if files.empty?
        UI.messagebox("Aucun fichier .skp trouvé dans ce dossier.")
        model.abort_operation
        return
      end

      x_pos = 0.0 # Position pour décaler les objets
      count = 0

      files.each do |file_path|
        begin
          # Méthode robuste : on charge la définition d'abord
          definition = model.definitions.load(file_path)
          
          if definition
            # On place une instance dans le modèle
            trans = Geom::Transformation.new([x_pos, 0, 0])
            inst = model.entities.add_instance(definition, trans)
            
            # On décale la position pour le suivant (Largeur + 20cm de marge)
            # .bounds peut être vide si le composant est vide, on sécurise
            width = inst.bounds.valid? ? inst.bounds.width : 100.cm
            x_pos += width + 20.cm
            
            count += 1
          end
        rescue => e
          puts "Erreur import fichier : #{file_path} - #{e.message}"
        end
      end
      
      model.commit_operation
      Sketchup.status_text = "Import terminé : #{count} fichiers importés."
    end

    # --- IMPORT ARMOIRE ---
    def self.import_armoire
      path = File.join(PATH_COMPS, 'armoire.skp')
      
      if File.exist?(path)
        # Pour l'armoire unique, on peut utiliser import qui permet de la placer à la souris
        # Ou definitions.load si vous préférez qu'elle arrive à l'origine direct.
        # Ici on garde import pour le placement manuel souvent préféré pour un objet seul.
        Sketchup.active_model.import(path)
      else
        UI.messagebox("Erreur : Fichier introuvable !\n\nAttendu ici : #{path}")
      end
    end
  end
end