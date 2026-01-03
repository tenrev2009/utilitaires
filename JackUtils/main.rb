# Fichier: Plugins/JackUtils/main.rb
require 'sketchup.rb'

module JackUtils
  # Chemin racine du plugin
  PATH_ROOT = File.dirname(__FILE__)
  PATH_ICONS = File.join(PATH_ROOT, 'assets', 'icons')
  
  # Chargement explicite pour éviter les oublis
  Dir.glob(File.join(PATH_ROOT, 'tools', '*.rb')).each do |file|
    begin
      require file
    rescue => e
      UI.messagebox("Erreur chargement #{File.basename(file)}: #{e.message}")
    end
  end

  def self.create_cmd(title, icon_name, tooltip, &block)
    cmd = UI::Command.new(title) { block.call }
    icon_path = File.join(PATH_ICONS, icon_name)
    
    if File.exist?(icon_path)
      cmd.small_icon = icon_path
      cmd.large_icon = icon_path
    end
    cmd.tooltip = tooltip
    cmd.status_bar_text = tooltip
    cmd
  end

  unless file_loaded?(__FILE__)
    tb = UI::Toolbar.new("Jack Tools")

    # --- MODELISATION ---
    if defined?(JackUtils::Unique)
      tb.add_item(create_cmd("Rendre Unique", "unique.png", "Rendre Unique (Deep)") { JackUtils::Unique.make_selection_unique })
    end
    
    if defined?(JackUtils::SelectSimilar)
      tb.add_item(create_cmd("Select Similar", "c_similar_small.png", "Sélectionner Similaires") { JackUtils::SelectSimilar.select_similar })
    end

    if defined?(JackUtils::MatchCompo)
      tb.add_item(create_cmd("Refaire Compo", "compo.png", "Remplacer (Match)") { JackUtils::MatchCompo.start_tool })
    end
    
    tb.add_separator

    # --- VISIBILITE ---
    if defined?(JackUtils::Tags)
      tb.add_item(create_cmd("Isoler Balises", "balise_jack.png", "Isoler Balises") { JackUtils::Tags.masquer_autres })
      tb.add_item(create_cmd("Restaurer Balises", "balise_jack1.png", "Restaurer Balises") { JackUtils::Tags.restaurer })
    end

    if defined?(JackUtils::CleanHidden)
      tb.add_item(create_cmd("Purge Masqués", "remove_hidden_small.png", "Purge Masqués") { JackUtils::CleanHidden.remove })
    end

    tb.add_separator

    # --- ATTRIBUTS DC ---
    if defined?(JackUtils::CleanDC)
      tb.add_item(create_cmd("Supprimer DC", "remove_dynamic_small.png", "Supprimer DC") { JackUtils::CleanDC.remove })
    end

    if defined?(JackUtils::DataCSV)
      tb.add_item(create_cmd("Export CSV", "export.png", "Export Attributs") { JackUtils::DataCSV.export })
      tb.add_item(create_cmd("Import CSV", "import.png", "Import Attributs") { JackUtils::DataCSV.import })
      tb.add_item(create_cmd("Redraw", "redessiner.png", "Force Redraw") { JackUtils::DataCSV.redraw })
    end

    tb.add_separator

    # --- FICHIERS ---
    if defined?(JackUtils::IOSkp)
      tb.add_item(create_cmd("Export SKP", "exportc.png", "Export Composants") { JackUtils::IOSkp.export_components })
      tb.add_item(create_cmd("Import Dossier", "library_small.png", "Import Dossier") { JackUtils::IOSkp.import_folder })
      tb.add_item(create_cmd("Armoire", "armoire.png", "Armoire") { JackUtils::IOSkp.import_armoire })
    end

    tb.add_separator

    # --- SYSTEME ---
    # Ici on appelle directement les fonctions du module System
    if defined?(JackUtils::System)
      tb.add_item(create_cmd("Purge Récent", "purge.png", "Purger Fichiers Récents") { JackUtils::System.purge_recent })
      tb.add_item(create_cmd("Reload Plugins", "reload.png", "Reload UI") { JackUtils::System.show_reload_dialog })
    end

    tb.restore
    file_loaded(__FILE__)
  end
end