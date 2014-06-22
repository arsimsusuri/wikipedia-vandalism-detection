require 'weka/classifiers/meta/one_class_classifier'

module Wikipedia
  module VandalismDetection

    require 'yaml'

    def self.configuration
      @configuration ||= Configuration.new
    end

    class Configuration

      TRAINING_DATA_BALANCED = 'balanced'
      TRAINING_DATA_UNBALANCED = 'unbalanced'
      TRAINING_DATA_OVERSAMPLED = 'oversampled'

      attr_reader :data,
                  :features,
                  :classifier_options,
                  :classifier_type,
                  :cross_validation_fold,
                  :output_base_directory,
                  :training_data_options

      def initialize
        config = DefaultConfiguration[DefaultConfiguration::DEFAULTS]
        @config_from_file ||= config.load_config_file(config.config_file)

        @data ||= (@config_from_file ? config.deep_merge(@config_from_file) : config)

        @classifier_type = @data['classifier']['type']
        @classifier_options = @data['classifier']['options']
        @cross_validation_fold = @data['classifier']['cross-validation-fold']
        @training_data_options = @data['classifier']['training-data-options']

        @features = @data['features']
        @output_base_directory = File.expand_path(@data['output']['base_directory'], __FILE__)
      end

      # Returns whether the classifier uses one class classification
      def use_occ?
        @classifier_type == Weka::Classifiers::Meta::OneClassClassifier.type
      end

      # Returns a boolean value whether a balanced data set is used for classifier training.
      # (balanced means: same number of vandalism and regular samples)
      def balanced_training_data?
        @training_data_options == TRAINING_DATA_BALANCED
      end

      # Returns a boolean value whether an unbalanced data set is used for classifier training.
      # (unbalanced means: vandalism and regular samples are used as given in arff file)
      def unbalanced_training_data?
        @training_data_options == TRAINING_DATA_UNBALANCED || @training_data_options.nil? ||
            (@training_data_options != TRAINING_DATA_BALANCED && @training_data_options != TRAINING_DATA_OVERSAMPLED)
      end

      # Returns a boolean value whether a oversampled data set is used for classifier training.
      # (oversampled means: a balanced dataset is enriched through vandalism instances
      # if vandalism number is less than regular number)
      def oversampled_training_data?
        @training_data_options == TRAINING_DATA_OVERSAMPLED
      end

      # Returns the path to the classification file.
      # Automatically sub directories for classifier and training data options are added.
      # Thus it results in <output base dir>/<classifier name>/<training data options>/<file name>
      def test_output_classification_file
        classifiction_file_name = @data['output']['test']['classification_file']
        classifier_name = @classifier_type.split('::').last.downcase

        File.join(@output_base_directory, classifier_name,
                  @training_data_options.gsub(/\s+/, '_'), classifiction_file_name)
      end

      # Returns file/path string for corpora files/directories and output files
      # after following schema: <corpus type>_<progress stage>_<file name>.
      #
      # Instead of 'corpora' the word 'corpus' is used for grammatical reasons.
      #
      # example:
      #   training_corpus_edits_file()
      #   test_output_index_file()
      #
      def method_missing(method_name, *args)
        return instance_variable_get("@#{method_name}") if instance_variable_defined?("@#{method_name}")

        file_path_parts = method_name.to_s.split('_')

        if file_path_parts.count >= 4
          corpus_type = file_path_parts[0]
          progress_stage = file_path_parts[1]
          file_path = file_path_parts[2..-1].join('_')

          if progress_stage == 'corpus'
            progress_stage = 'corpora'
            path = File.join(@data[progress_stage]['base_directory'], @data[progress_stage][corpus_type]['base_directory'])
          elsif progress_stage == 'output'
            path = @output_base_directory
          else
            return super
          end

          relative_path = File.join(path, @data[progress_stage][corpus_type][file_path])
          absolute_path = File.expand_path(relative_path, __FILE__)
          instance_variable_set "@#{method_name}", absolute_path
        else
          super
        end
      end
    end

    # This class represents the default config which is merged with the customized config from config YAML file.
    class DefaultConfiguration < Hash
      DEFAULTS = {
          "source"    => Dir.pwd,
          'features'  => [
              "anonymity",
              "anonymity previous",
              "all wordlists frequency",
              "all wordlists impact",
              "article size",
              "bad frequency",
              "bad impact",
              "biased frequency",
              "biased impact",
              "blanking",
              "character sequence",
              "character diversity",
              "comment length",
              "comment biased frequency",
              "comment pronoun frequency",
              "comment vulgarism frequency",
              "compressibility",
              "copyedit",
              "digit ratio",
              "edits per user",
              "emoticons frequency",
              "emoticons impact",
              "inserted size",
              "inserted words",
              "inserted character distribution",
              "inserted external links",
              "inserted internal links",
              "longest word",
              "markup frequency",
              "markup impact",
              "non-alphanumeric ratio",
              "personal life",
              "pronoun frequency",
              "pronoun impact",
              "removed size",
              "removed words",
              "removed all wordlists frequency",
              "removed bad frequency",
              "removed biased frequency",
              "removed character distribution",
              "removed emoticons frequency",
              "removed markup frequency",
              "removed pronoun frequency",
              "removed sex frequency",
              "removed vulgarism frequency",
              "replacement similarity",
              "reverted",
              "revisions character distribution",
              "sex frequency",
              "sex impact",
              "same editor",
              "size ratio",
              "term frequency",
              "time interval",
              "time of day",
              "upper case ratio",
              "upper case words ratio",
              "upper to lower case ratio",
              "user reputation",
              "vulgarism frequency",
              "vulgarism impact",
              "weekday"
          ],
          "corpora" => {
            "base_directory" => nil,
            "training" => {
                "base_directory"      => nil,
                "edits_file"          => nil,
                "annotations_file"    => nil,
                "revisions_directory" => nil
            },
            "test" => {
                "base_directory"      => nil,
                "edits_file"          => nil,
                "revisions_directory" => nil,
                "ground_truth_file"   => nil
            }
          },
          "output" => {
              "base_directory" => File.join(Dir.pwd, 'build'),
              "training" => {
                  "arff_file" => 'training.arff',
                  "index_file" => 'training_index.yml',
              },
              "test" => {
                  "arff_file" => 'test.arff',
                  "index_file" => 'test_index.yml',
                  "classification_file" => 'classification.txt'
              }
          },
          "classifier" => {
              "type"    => nil,
              "options" => nil,
              "cross-validation-fold" => 10,
              "training-data-options" => 'unbalanced'
          }
      }

      def source
        DEFAULTS['source']
      end

      # Looks in two places for a custom config file:
      # in <app_root>/config/ and in <app_root>/lib/config
      def config_file
        root_file = File.join(source, "config/config.yml")
        lib_file = File.join(source, "lib/config/config.yml")

        File.exist?(root_file) ? root_file : lib_file
      end

      def load_config_file(file)

        if File.exists? file
          YAML.load_file(file)
        else
          warn %Q{

            Configuration file not found in #{source}/config or #{source}/lib/config directory.
            To customize the system, create a config.yml file.

          }
        end
      end

    end
  end
end
