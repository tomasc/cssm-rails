require 'pathname'

module CSSM
  module Rails
    class Sprockets
      def self.register_processor(processor)
        @processor = processor
      end

      def self.call(input)
        filename = input[:filename]
        source = input[:data]
        run(filename, source)
      end

      def self.run(filename, css)
        result = @processor.process(css, from: filename)
        result.to_s
      end

      def self.install(env)
        env.register_mime_type('text/css-modules', extensions: %w(.cssm))
        env.register_mime_type('text/sass-modules', extensions: %w(.sassm))
        env.register_mime_type('text/scss-modules', extensions: %w(.scssm))

        if ::Sprockets::VERSION.to_f < 4
          env.register_postprocessor('text/css-modules', ::CSSM::Rails::Sprockets)
          env.register_postprocessor('text/sass-modules', ::CSSM::Rails::Sprockets)
          env.register_postprocessor('text/scss-modules', ::CSSM::Rails::Sprockets)
        else
          env.register_bundle_processor('text/css-modules', ::CSSM::Rails::Sprockets)
          env.register_bundle_processor('text/sass-modules', ::CSSM::Rails::Sprockets)
          env.register_bundle_processor('text/scss-modules', ::CSSM::Rails::Sprockets)
        end
      end

      # Register postprocessor in Sprockets depend on issues with other gems
      def self.uninstall(env)
        if ::Sprockets::VERSION.to_f < 4
          env.unregister_preprocessor('text/css-modules', ::CSSM::Rails::Sprockets)
          env.unregister_preprocessor('text/sass-modules', ::CSSM::Rails::Sprockets)
          env.unregister_preprocessor('text/scss-modules', ::CSSM::Rails::Sprockets)
        else
          env.unregister_bundle_processor('text/css-modules', ::CSSM::Rails::Sprockets)
          env.unregister_bundle_processor('text/sass-modules', ::CSSM::Rails::Sprockets)
          env.unregister_bundle_processor('text/scss-modules', ::CSSM::Rails::Sprockets)
        end
      end

      # Sprockets 2 API new and render
      def initialize(filename)
        @filename = filename
        @source = yield
      end

      # Sprockets 2 API new and render
      def render(_, _)
        self.class.run(@filename, @source)
      end
    end
  end
end
