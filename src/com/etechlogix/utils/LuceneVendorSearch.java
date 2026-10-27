package com.etechlogix.utils;

import java.util.ArrayList;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.queryParser.MultiFieldQueryParser;
import org.json.JSONArray;
import org.json.JSONObject;

public class LuceneVendorSearch {

	public LuceneVendorSearch() {
		
	}

	/**
	 * findVendorByKeyword is a Lucene search that returns a list of Strings,
	 * ordered by Lucene score.  The Strings are formatted: 
	 * "<vendor id>|<vendor name>|<vendor address>|<vendor city>|<vendor state>"
	 * This is the format that the JQuery object that will render the results
	 * expects.
	 * @param companyId - Company ID for the search
	 * @param keywords - Search words for the query
	 * @param whseNo - Default Warehouse of the person performing the search,
	 * so that local vendors will display first
	 * @param state - State of the default warehouse, so that local vendors
	 * will display first
	 * @return a List of Strings to be displayed.  List is in Search score order.
	 */
	public ArrayList findVendorByKeyword(String companyId, String keywords, String whseNo, String state) {
		ArrayList result = new ArrayList();
		if (whseNo != null && companyId != null && keywords != null) {
			
			StringBuffer sb = buildQuery(keywords, whseNo, state);
			if (!LuceneUtils.isNull(sb.toString())) {
				IndexSearcher searcher = null;
				try {
					searcher = LuceneUtils.getSearcher(LuceneUtils.VENDOR_SEARCHER_PATH);
					TopDocs docs = generateCustomerDocs(sb, searcher);
					for (int i = 0; i < docs.totalHits; i++) {
						ScoreDoc doc = docs.scoreDocs[i];
						String docVendorId = searcher.doc(doc.doc).get("vendorid");
						String docName = searcher.doc(doc.doc).get("name");
						String docAddress = searcher.doc(doc.doc).get("address1");
						String docCity = searcher.doc(doc.doc).get("city");
						String docState = searcher.doc(doc.doc).get("state");
						float score = doc.score;
						String row = docVendorId + "|" + docName + "|" + docAddress + "|" + docCity + "|" + docState;
						result.add(row); 
					}
				} catch (Exception e) {
					Utils.logError("company: '" + companyId + "', keywords: '" + keywords + "', whseNo: '" + whseNo + "', state: '" + state + "'");
					Utils.logError("search query: '" + sb.toString() + "'");
					Utils.logError(e.getMessage(), e);
				} finally {
					if (searcher != null) {
						try {
						    searcher.close();										
						} catch (Exception e2) {
							Utils.logDebug("Unable to close searcher", e2);
						}
					}
				}
			}
		}
		return result;
	}
	public JSONObject findVendorByKeywordJson(String companyId, String keywords, String whse,  
		   	String state) throws Exception{
		JSONObject json = new JSONObject();
		if (whse != null && companyId != null && keywords != null) {
			
			StringBuffer sb = buildQuery(keywords, whse, state);
			Utils.logDebug("sb: '" + sb.toString() + "'");
			if (!LuceneUtils.isNull(sb.toString())) {
				IndexSearcher searcher = null;
				try {
					searcher = LuceneUtils.getSearcher(LuceneUtils.VENDOR_SEARCHER_PATH);
					TopDocs docs = generateCustomerDocs(sb, searcher);
					for (int i = 0; i < docs.totalHits; i++) {
						JSONArray itemjson = new JSONArray(); 
						ScoreDoc doc = docs.scoreDocs[i];
						itemjson.put(searcher.doc(doc.doc).get("vendorid"));
						itemjson.put(searcher.doc(doc.doc).get("name"));
						itemjson.put(searcher.doc(doc.doc).get("address1"));
						itemjson.put(searcher.doc(doc.doc).get("city"));
						itemjson.put(searcher.doc(doc.doc).get("state"));						
						itemjson.put(searcher.doc(doc.doc).get("phone"));
						itemjson.put(searcher.doc(doc.doc).get("alphasearch"));
						float score = doc.score;
						json.append("aaData", itemjson);}
				} catch (Exception e) {
					Utils.logError(e.getMessage(), e);
				} finally {
					if (searcher != null) {
						try {
						    searcher.close();										
						} catch (Exception e2) {
							Utils.logDebug("Unable to close searcher", e2);
						}
					}
				}
			}
		}
		
		return json;
	}
	/**
	 * buildCustomerQuery takes the inbound query and formats it for the
	 * query parser.  Special priority are added for vendors that are assigned
	 * to the Warehouse and Warehouse state.
	 * @param keywords - criteria to be used for search
	 * @param whseNo - default warehouse to be prioritized
	 * @param whseState - default warehouse state to be prioritized.
	 * @return
	 */
	public StringBuffer buildQuery(String keywords, String whseNo, String whseState) {
		StringBuffer sb = new StringBuffer();
		keywords = keywords.replaceAll("[\\[\\]{}()^:!&\\\\]", " ").trim();
		if (keywords.length() > 0) {
			String[] words = keywords.split("\\s");
			for (int i = 0; i < words.length; i++) {
				String keyword = words[i].trim();
				if (keyword.length() > 0 && !LuceneUtils.isStopWord(keyword)) {
					StringBuffer curQuery = new StringBuffer();
					curQuery.append("+(vendorid:" + keyword + "^2 vendorid:" + keyword + "* ");
					curQuery.append("name:" + keyword + " name:" + keyword + "* ");
					curQuery.append("address1:" + keyword + " address1:" + keyword + "* ");
					curQuery.append("city:" + keyword + " city:" + keyword + "* ");
					curQuery.append("state:" + keyword + " state:" + keyword + "* ");
					curQuery.append("zip:" + keyword + " zip:" + keyword + "* ");
					curQuery.append("phone:" + keyword + " phone:" + keyword + "* ");
					curQuery.append("alphasearch:" + keyword + " alphasearch:" + keyword + "*)");
					if (sb.length() > 0) {
						sb.append(" "); 
					}
					sb.append(curQuery);
				}
			}
			if (!LuceneUtils.isNull(whseNo)) {
				sb.append(" ");
				sb.append("defaultwhseno:" + whseNo);
			}
			if (!LuceneUtils.isNull(whseState)) {
				sb.append(" ");
				sb.append("defaultwhsestate:" + whseState);
			}
		}
		return sb;  
	}
	
	/**
	 * generateCustomerDocs executes a query against the selected Lucene
	 * database
	 * @param query - Query to be executed
	 * @param searcher - Database to be searched
	 * @return - List of document IDs and scores
	 */
	private TopDocs generateCustomerDocs(StringBuffer query, IndexSearcher searcher) {
		Analyzer analyzer = new StandardAnalyzer();
		String[] searchFields = new String[8];
		searchFields[0] = "vendorid";
		searchFields[1] = "name";
		searchFields[7] = "address1";
		searchFields[2] = "city";
		searchFields[3] = "state";
		searchFields[4] = "zip";
		searchFields[5] = "phone";
		searchFields[6] = "alphasearch";
		QueryParser parser = new MultiFieldQueryParser(searchFields, analyzer);
		return LuceneUtils.generateDocs(query, searcher, parser);
	}
	
}
