module PublicationsRoutes
  DEFAULT_PUBLICATIONS_PATH = 'search/all'.freeze
  PUBLICATIONS_ROUTES = {
    'command_and_act_papers' => {
      base_path: 'official-documents',
    },
    'command_papers' => {
      base_path: 'official-documents',
      special_params: {
        content_store_document_type: 'command_papers',
      }
    },
    'act_papers' => {
      base_path: 'official-documents',
      special_params: {
        content_store_document_type: 'act_papers',
      }
    },
    'consultations' => {
      base_path: 'search/policy-papers-and-consultations',
      special_params: {
        content_store_document_type: %w[open_consultations closed_consultations],
      }
    },
    'closed-consultations' => {
      base_path: 'search/policy-papers-and-consultations',
      special_params: {
        content_store_document_type: 'closed_consultations',
      }
    },
    'open-consultations' => {
      base_path: 'search/policy-papers-and-consultations',
      special_params: {
        content_store_document_type: 'open_consultations',
      }
    },
    'foi-releases' => {
      base_path: 'search/transparency-and-freedom-of-information-releases'
    },
    'transparency-data' => {
      base_path: 'search/transparency-and-freedom-of-information-releases'
    },
    'guidance' => {
      base_path: 'search/guidance-and-regulation'
    },
    'regulations' => {
      base_path: 'search/guidance-and-regulation'
    },
    'policy-papers' => {
      base_path: 'search/policy-papers-and-consultations',
      special_params: {
        content_store_document_type: 'policy_papers'
      }
    },
    'forms' => {
      base_path: 'search/services'
    },
    'research-and-analysis' => {
      base_path: 'search/research-and-statistics',
      special_params: {
        content_store_document_type: 'research'
      }
    },
    'statistics' => {
      base_path: 'search/research-and-statistics'
    }
  }.freeze
end
