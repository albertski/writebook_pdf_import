module WritebookPdfImport
  class Engine < ::Rails::Engine
    # Add the engine's routes file to the list Rails reloads — works in dev too
    initializer "writebook_pdf_import.routes" do |app|
      app.config.paths["config/routes.rb"] << root.join("config/routes.rb")
    end

    initializer "writebook_pdf_import.view_paths" do |app|
      ActiveSupport.on_load(:action_controller) do
        prepend_view_path WritebookPdfImport::Engine.root.join("app/views")
      end
    end

    # Pin loading_controller under the host app's "controllers/" importmap namespace
    # so eagerLoadControllersFrom picks it up automatically
    initializer "writebook_pdf_import.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/assets/javascripts")
      end
    end

    # Patch pdf-reader's word-spacing threshold. The default (font_size * 0.2) is
    # too aggressive for large/bold fonts and drops spaces between words. 0.1 is
    # tight enough to preserve intra-word kerning while keeping word spaces intact.
    initializer "writebook_pdf_import.pdf_reader_patch" do
      ActiveSupport.on_load(:after_initialize) do
        require "pdf/reader"

        PDF::Reader::TextRun.prepend(Module.new do
          def +(other)
            raise ArgumentError, "#{other} cannot be merged with this run" unless mergable?(other)
            if (other.x - endx) < (font_size * 0.1)
              self.class.new(x, y, other.endx - x, font_size, text + other.text)
            else
              self.class.new(x, y, other.endx - x, font_size, "#{text} #{other.text}")
            end
          end
        end)
      end
    end
  end
end
