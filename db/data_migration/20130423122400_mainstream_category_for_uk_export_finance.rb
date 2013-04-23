puts 'Creating MainstreamCategory for UK Export Finance'
MainstreamCategory.create!( parent_title: 'Imports and exports',
                            parent_tag: 'business/imports-exports',
                            title: 'Export finance',
                            slug: 'export-finance',
                            description: 'How UK exporters can apply for loans, lines of credit, guarantees and insurance policies')
