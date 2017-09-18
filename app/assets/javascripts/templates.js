window.templates = {};
window.templates['admin/shared/tagging/_breadcrumb_list'] = new Hogan.Template(function(c,p,i){var _=this;_.b(i=i||"");if(_.s(_.f("breadcrumbs",c,p,1),c,p,0,16,113,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("<div class=\"taxon-breadcrumb\">");_.b("\n" + i);_.b("  <ol>");_.b("\n" + i);if(_.s(_.d(".",c,p,1),c,p,0,65,91,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("      <li>");_.b(_.v(_.d(".",c,p,0)));_.b("</li>");_.b("\n");});c.pop();}_.b("  </ol>");_.b("\n" + i);_.b("</div>");_.b("\n");});c.pop();}return _.fl();;});
window.templates['documents/_filter_selections'] = new Hogan.Template(function(c,p,i){var _=this;_.b(i=i||"");_.b("<span class=\"count\">");_.b(_.v(_.f("result_count",c,p,0)));_.b("</span> <strong>");_.b(_.v(_.f("pluralized_result_type",c,p,0)));_.b("</strong>");_.b("\n" + i);_.b("<span class=\"topics-selections\">");_.b("\n" + i);if(_.s(_.f("topics",c,p,1),c,p,0,134,287,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("    about <strong>");_.b(_.v(_.f("name",c,p,0)));_.b("</strong> <a href=\"");_.b(_.v(_.f("url",c,p,0)));_.b("\" data-field=\"topics\" data-val=\"");_.b(_.v(_.f("value",c,p,0)));_.b("\" title=\"Remove ");_.b(_.v(_.f("name",c,p,0)));_.b(" filter\">&times;</a> ");_.b(_.v(_.f("joining",c,p,0)));_.b("\n");});c.pop();}_.b("</span>");_.b("\n" + i);_.b("<span class=\"departments-selections\">");_.b("\n" + i);if(_.s(_.f("departments",c,p,1),c,p,0,363,518,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("    by <strong>");_.b(_.v(_.f("name",c,p,0)));_.b("</strong> <a href=\"");_.b(_.v(_.f("url",c,p,0)));_.b("\" data-field=\"departments\" data-val=\"");_.b(_.v(_.f("value",c,p,0)));_.b("\" title=\"Remove ");_.b(_.v(_.f("name",c,p,0)));_.b(" filter\">&times;</a> ");_.b(_.v(_.f("joining",c,p,0)));_.b("\n");});c.pop();}_.b("</span>");_.b("\n" + i);_.b("<span class=\"people-selections\">");_.b("\n" + i);if(_.s(_.f("people",c,p,1),c,p,0,589,737,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("  by <strong>");_.b(_.v(_.f("name",c,p,0)));_.b("</strong> <a href=\"");_.b(_.v(_.f("url",c,p,0)));_.b("\" data-field=\"people\" data-val=\"");_.b(_.v(_.f("value",c,p,0)));_.b("\" title=\"Remove ");_.b(_.v(_.f("name",c,p,0)));_.b(" filter\">&times;</a> ");_.b(_.v(_.f("joining",c,p,0)));_.b("\n");});c.pop();}_.b("</span>");_.b("\n" + i);if(_.s(_.f("world_locations_any?",c,p,1),c,p,0,782,1031,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("from");_.b("\n" + i);_.b("<span class=\"locations-selections\">");_.b("\n" + i);if(_.s(_.f("world_locations",c,p,1),c,p,0,846,1002,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("    <strong>");_.b(_.v(_.f("name",c,p,0)));_.b("</strong> <a href=\"");_.b(_.v(_.f("url",c,p,0)));_.b("\" data-field=\"world_locations\" data-val=\"");_.b(_.v(_.f("value",c,p,0)));_.b("\" title=\"Remove ");_.b(_.v(_.f("name",c,p,0)));_.b(" filter\">&times;</a> ");_.b(_.v(_.f("joining",c,p,0)));_.b("\n");});c.pop();}_.b("</span>");_.b("\n");});c.pop();}_.b("\n" + i);if(_.s(_.f("keywords",c,p,1),c,p,0,1071,1300,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("  containing");_.b("\n" + i);_.b("  <span class=\"keyword-selections\">");_.b("\n" + i);_.b("    <strong>");_.b(_.v(_.d("keywords.name",c,p,0)));_.b("</strong> <a href=\"");_.b(_.v(_.d("keywords.url",c,p,0)));_.b("\" data-field=\"keywords\" data-val=\"");_.b(_.v(_.d("keywords.name",c,p,0)));_.b("\" title=\"Remove ");_.b(_.v(_.d("keywords.name",c,p,0)));_.b(" filter\">&times;</a>");_.b("\n" + i);_.b("  </span>");_.b("\n");});c.pop();}_.b("\n" + i);if(_.s(_.f("filtering_command_and_act_papers?",c,p,1),c,p,0,1353,1576,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("  <span class=\"official-document-status\">which are <strong>Command or Act papers <a data-field=\"official_document_status\" data-val=\"command_and_act_papers\" title=\"Remove official status filter\">&times;</a></strong></span>");_.b("\n");});c.pop();}if(_.s(_.f("filtering_command_papers_only?",c,p,1),c,p,0,1650,1863,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("  <span class=\"official-document-status\">which are <strong>Command papers <a data-field=\"official_document_status\" data-val=\"command_papers_only\" title=\"Remove official status filter\">&times;</a></strong></span>");_.b("\n");});c.pop();}if(_.s(_.f("filtering_act_papers_only?",c,p,1),c,p,0,1930,2135,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("  <span class=\"official-document-status\">which are <strong>Act papers <a data-field=\"official_document_status\" data-val=\"act_papers_only\" title=\"Remove official status filter\">&times;</a></strong></span>");_.b("\n");});c.pop();}_.b("\n" + i);if(_.s(_.f("include_world_location_news",c,p,1),c,p,0,2200,2302,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("  <span class=\"world-location-news\">");_.b("\n" + i);_.b("    <strong>including location-specific news</strong>");_.b("\n" + i);_.b("  </span>");_.b("\n");});c.pop();}_.b("\n" + i);if(_.s(_.f("date_from",c,p,1),c,p,0,2350,2403,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("published <strong>after&nbsp;");_.b(_.v(_.f("date_from",c,p,0)));_.b("</strong>");_.b("\n");});c.pop();}_.b("\n" + i);if(_.s(_.f("date_to",c,p,1),c,p,0,2431,2483,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("published <strong>before&nbsp;");_.b(_.v(_.f("date_to",c,p,0)));_.b("</strong>");_.b("\n");});c.pop();}return _.fl();;});
window.templates['documents/_filter_table'] = new Hogan.Template(function(c,p,i){var _=this;_.b(i=i||"");if(_.s(_.f("results_any?",c,p,1),c,p,0,17,2144,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("  <ol class=\"js-document-list document-list\" data-module=\"track-click\">");_.b("\n" + i);if(_.s(_.f("results",c,p,1),c,p,0,106,1459,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("      <li id=\"");_.b(_.v(_.d("result.type",c,p,0)));_.b("_");_.b(_.v(_.d("result.id",c,p,0)));_.b("\" class=\"document-row\">");_.b("\n" + i);_.b("        <h3>");_.b("\n" + i);_.b("          <a");_.b("\n" + i);_.b("            href=\"");_.b(_.v(_.d("result.url",c,p,0)));_.b("\"");_.b("\n" + i);_.b("            data-category=\"nav");_.b(_.v(_.f("category",c,p,0)));_.b("LinkClicked\"");_.b("\n" + i);_.b("            data-action=\"");_.b(_.v(_.f("index",c,p,0)));_.b("\"");_.b("\n" + i);_.b("            data-label=\"");_.b(_.v(_.d("result.url",c,p,0)));_.b("\"");_.b("\n" + i);_.b("            data-options='{\"dimension28\":\"");_.b(_.v(_.f("count",c,p,0)));_.b("\",\"dimension29\":\"");_.b(_.v(_.d("result.title",c,p,0)));_.b("\"}'");_.b("\n" + i);_.b("            >");_.b(_.v(_.d("result.title",c,p,0)));_.b("</a>");_.b("\n" + i);_.b("        </h3>");_.b("\n" + i);_.b("        <ul class=\"attributes\">");_.b("\n" + i);_.b("          <li>");_.b(_.t(_.d("result.display_date_microformat",c,p,0)));_.b("</li>");_.b("\n" + i);_.b("          <li class=\"organisations\">");_.b(_.t(_.d("result.organisations",c,p,0)));_.b("</li>");_.b("\n" + i);_.b("          <li class=\"display-type\">");_.b(_.v(_.d("result.display_type",c,p,0)));_.b("</li>");_.b("\n" + i);if(_.s(_.d("result.field_of_operation",c,p,1),c,p,0,762,853,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("            <li class=\"field-of-operation\">");_.b(_.t(_.d("result.field_of_operation",c,p,0)));_.b("</li>");_.b("\n");});c.pop();}if(_.s(_.d("result.topics",c,p,1),c,p,0,912,979,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("            <li class=\"topics\">");_.b(_.t(_.d("result.topics",c,p,0)));_.b("</li>");_.b("\n");});c.pop();}if(_.s(_.d("result.publication_collections",c,p,1),c,p,0,1043,1141,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("            <li class=\"document-collections\">");_.b(_.t(_.d("result.publication_collections",c,p,0)));_.b("</li>");_.b("\n");});c.pop();}_.b("        </ul>");_.b("\n" + i);if(_.s(_.d("result.historic?",c,p,1),c,p,0,1220,1421,"{{ }}")){_.rs(c,p,function(c,p,_){if(_.s(_.d("result.government_name",c,p,1),c,p,0,1258,1385,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("            <p class=\"historic\">");_.b("\n" + i);_.b("            First published during the ");_.b(_.v(_.d("result.government_name",c,p,0)));_.b("\n" + i);_.b("            </p>");_.b("\n");});c.pop();}});c.pop();}_.b("      </li>");_.b("\n");});c.pop();}_.b("  </ol>");_.b("\n" + i);if(_.s(_.f("more_pages?",c,p,1),c,p,0,1498,2127,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("    <nav id=\"show-more-documents\" role=\"navigation\">");_.b("\n" + i);_.b("      <ul class=\"previous-next-navigation\">");_.b("\n" + i);if(_.s(_.f("prev_page?",c,p,1),c,p,0,1619,1837,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("          <li class=\"previous\">");_.b("\n" + i);_.b("            <a href=\"");_.b(_.v(_.f("prev_page_url",c,p,0)));_.b("\">Previous <span class=\"visuallyhidden\">page</span> <span class=\"page-numbers\">");_.b(_.v(_.f("prev_page",c,p,0)));_.b(" of ");_.b(_.v(_.f("total_pages",c,p,0)));_.b("</span></a>");_.b("\n" + i);_.b("          </li>");_.b("\n");});c.pop();}if(_.s(_.f("next_page?",c,p,1),c,p,0,1876,2086,"{{ }}")){_.rs(c,p,function(c,p,_){_.b("          <li class=\"next\">");_.b("\n" + i);_.b("            <a href=\"");_.b(_.v(_.f("next_page_url",c,p,0)));_.b("\">Next <span class=\"visuallyhidden\">page</span> <span class=\"page-numbers\">");_.b(_.v(_.f("next_page",c,p,0)));_.b(" of ");_.b(_.v(_.f("total_pages",c,p,0)));_.b("</span></a>");_.b("\n" + i);_.b("          </li>");_.b("\n");});c.pop();}_.b("      </ul>");_.b("\n" + i);_.b("    </nav>");_.b("\n");});c.pop();}});c.pop();}if(!_.s(_.f("results_any?",c,p,1),c,p,1,0,0,"")){_.b("  <div class=\"no-results\">");_.b("\n" + i);_.b("    <h2>");_.b(_.v(_.f("no_results_title",c,p,0)));_.b("</h2>");_.b("\n" + i);_.b("    <p>");_.b(_.v(_.f("no_results_description",c,p,0)));_.b("</p>");_.b("\n" + i);_.b("    <h3>");_.b(_.t(_.f("no_results_tna_heading",c,p,0)));_.b("</h3>");_.b("\n" + i);_.b("    <p>");_.b(_.t(_.f("no_results_tna_link",c,p,0)));_.b("</p>");_.b("\n" + i);_.b("  </div>");_.b("\n");};return _.fl();;});