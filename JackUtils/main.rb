# Fichier: Plugins/JackUtils/main.rb
require 'sketchup.rb'

module JackUtils
  PATH_ROOT = File.dirname(__FILE__)
  PATH_ICONS = File.join(PATH_ROOT, 'assets', 'icons')
  
  # Chargement de tous les outils
  Dir.glob(File.join(PATH_ROOT, 'tools', '*.rb')).each { |f| require f }

  def self.create_cmd(title, icon_name, tooltip, &block)
    cmd = UI::Command.new(title) { block.call }
    # On cherche l'icone, sinon on met une icone par defaut ou nil
    icon_path = File.join(PATH_ICONS, icon_name)
    if File.exist?(icon_path)
      cmd.small_icon = cmd.large_icon = icon_path
    else
      puts "JackUtils: Icône manquante -> #{icon_name}"
    end
    cmd.tooltip = tooltip
    cmd.status_bar_text = tooltip
    cmd
  end

  unless file_loaded?(__FILE__)
    tb = UI::Toolbar.new("Jack Tools")

    # --- 1. MODÉLISATION ---
    
    # Rendre Unique (Basé sur unique.rb)
    cmd = create_cmd("Rendre Unique", "unique.png", "Rendre sélection unique (récursif)") { JackUtils::Unique.make_selection_unique }
    tb.add_item(cmd)

    # Sélection Similaire
    cmd = create_cmd("Select Similar", "c_similar_small.png", "Sélectionner composants similaires") { JackUtils::SelectSimilar.select_similar }
    tb.add_item(cmd)

    # Match Component (Refaire Compo)
    cmd = create_cmd("Refaire Compo", "compo.png", "Remplacer définition (Match)") { JackUtils::MatchCompo.start_tool }
    tb.add_item(cmd)
    
    tb.add_separator

    # --- 2. VISIBILITÉ ---

    # Isoler Balises
    cmd = create_cmd("Isoler Balises", "balise_jack.png", "Masquer les autres balises") { JackUtils::Tags.masquer_autres }
    tb.add_item(cmd)

    # Restaurer Balises
    cmd = create_cmd("Restaurer Balises", "balise_jack1.png", "Restaurer l'état des balises") { JackUtils::Tags.restaurer }
    tb.add_item(cmd)

    # Supprimer Sous-composants Masqués
    cmd = create_cmd("Purge Masqués", "remove_hidden_small.png", "Supprimer sous-composants masqués") { JackUtils::CleanHidden.remove }
    tb.add_item(cmd)

    tb.add_separator

    # --- 3. ATTRIBUTS & DATA (DC) ---

    # Supprimer Attributs Dynamiques
    cmd = create_cmd("Supprimer DC", "remove_dynamic_small.png", "Supprimer attributs dynamiques") { JackUtils::CleanDC.remove }
    tb.add_item(cmd)

    # Data CSV - Export
    cmd = create_cmd("Data Export", "export.png", "Exporter attributs CSV") { JackUtils::DataCSV.export }
    tb.add_item(cmd)

    # Data CSV - Import
    cmd = create_cmd("Data Import", "import.png", "Importer attributs CSV") { JackUtils::DataCSV.import }
    tb.add_item(cmd)

    # Data CSV - Redraw
    cmd = create_cmd("Forcer Redraw", "redessiner.png", "Redessiner DC Sélection") { JackUtils::DataCSV.redraw }
    tb.add_item(cmd)

    tb.add_separator

    # --- 4. FICHIERS (IO) ---

    # Export Composants (.skp)
    cmd = create_cmd("Export SKP", "exportc.png", "Exporter composants en .skp") { JackUtils::IOSkp.export_components }
    tb.add_item(cmd)

    # Import Dossier
    cmd = create_cmd("Import Dossier", "library_small.png", "Importer dossier de .skp") { JackUtils::IOSkp.import_folder }
    tb.add_item(cmd)
    
    # Import Armoire (Spécifique)
    cmd = create_cmd("Armoire", "armoire.png", "Importer Armoire") { JackUtils::IOSkp.import_armoire }
    tb.add_item(cmd)

    tb.add_separator

    # --- 5. SYSTÈME ---
    
    # Purge Recent
    cmd = create_cmd("Purge Récent", "purge.png", "Purger fichiers récents") { JackUtils::System.purge_recent }
    tb.add_item(cmd)
    
    # Hot Reload (Dev)
    cmd = create_cmd("Reload Plugins", "reload.png", "Recharger Plugins (Dev)") { JackUtils::System.hot_reload_ui }
    tb.add_item(cmd)

    tb.restore
    file_loaded(__FILE__)
  end
end