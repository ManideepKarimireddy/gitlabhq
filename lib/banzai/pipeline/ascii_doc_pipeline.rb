# frozen_string_literal: true

module Banzai
  module Pipeline
    class AsciiDocPipeline < BasePipeline
      def self.filters
        FilterArray[
          Filter::SanitizationFilter,
          Filter::SyntaxHighlightFilter,
          Filter::ExternalLinkFilter,
          Filter::PlantumlFilter,
          Filter::AsciiDocPostProcessingFilter
        ]
      end
    end
  end
end
