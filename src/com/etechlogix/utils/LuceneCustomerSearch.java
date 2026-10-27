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

public class LuceneCustomerSearch {
	private final static String SEARCHER_PATH_ROOT = "/opt/lucene/sd";
	private final static String CUSTOMER_SEARCHER_PATH = SEARCHER_PATH_ROOT + "/customer";

	public ArrayList findCustomerByKeyword(String companyId, String keywords, String whseNo, String state) {
		ArrayList result = new ArrayList();
		if (whseNo != null && companyId != null && keywords != null) {
			
			StringBuffer sb = buildCustomerQuery(keywords, whseNo, state);
			Utils.logDebug("sb: '" + sb.toString() + "'");
			if (!LuceneUtils.isNull(sb.toString())) {
				IndexSearcher searcher = null;
				try {
					searcher = LuceneUtils.getSearcher(CUSTOMER_SEARCHER_PATH);
					TopDocs docs = generateCustomerDocs(sb, searcher);
					for (int i = 0; i < docs.totalHits; i++) {
						ScoreDoc doc = docs.scoreDocs[i];
						String docCustomerId = searcher.doc(doc.doc).get("customerid");
						String docName = searcher.doc(doc.doc).get("name");
						String docAddress = searcher.doc(doc.doc).get("address1");
						String docCity = searcher.doc(doc.doc).get("city");
						String docState = searcher.doc(doc.doc).get("state");
						float score = doc.score;
						String row = docCustomerId + "|" + docName + "|" + docAddress + "|" + docCity + "|" + docState;
						result.add(row); 
					}
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
		return result;
	}
	public JSONObject findCustomerByKeywordJson(String companyId, String keywords, String whse,  
		   	String state) throws Exception{
		JSONObject json = new JSONObject();
		if (whse != null && companyId != null && keywords != null) {
			
			StringBuffer sb = buildCustomerQuery(keywords, whse, state);
			Utils.logDebug("sb: '" + sb.toString() + "'");
			if (!LuceneUtils.isNull(sb.toString())) {
				IndexSearcher searcher = null;
				try {
					searcher = LuceneUtils.getSearcher(CUSTOMER_SEARCHER_PATH);
					TopDocs docs = generateCustomerDocs(sb, searcher);
					for (int i = 0; i < docs.totalHits; i++) {
						JSONArray itemjson = new JSONArray(); 
						ScoreDoc doc = docs.scoreDocs[i];
						itemjson.put(searcher.doc(doc.doc).get("customerid"));
						itemjson.put(searcher.doc(doc.doc).get("name"));
						itemjson.put(searcher.doc(doc.doc).get("city"));
						itemjson.put(searcher.doc(doc.doc).get("state"));
						itemjson.put(searcher.doc(doc.doc).get("address1"));
						itemjson.put(searcher.doc(doc.doc).get("phone"));
						itemjson.put(searcher.doc(doc.doc).get("alphasearch"));
						itemjson.put(searcher.doc(doc.doc).get("customerclass"));
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
	 * builds a custom query for Lucene.  Note - it boosts the value of the name field (^2) so that
	 * name matches are more significant.
	 */
	public StringBuffer buildCustomerQuery(String keywords, String whseNo, String whseState) {
		StringBuffer sb = new StringBuffer();
		keywords = keywords.replaceAll("[\\[\\]{}()^:!&\\\\]", " ").trim();
		if (keywords.length() > 0) {
			String[] words = keywords.split("\\s");
			for (int i = 0; i < words.length; i++) {
				String keyword = words[i].trim();
				if (keyword.length() > 0 && !LuceneUtils.isStopWord(keyword)) {
					StringBuffer curQuery = new StringBuffer();
					curQuery.append("+(customerid:" + keyword + " customerid:" + keyword + "* ");
					curQuery.append("name:" + keyword + "^2 name:" + keyword + "* ");
					curQuery.append("city:" + keyword + " city:" + keyword + "* ");
					curQuery.append("state:" + keyword + " state:" + keyword + "* ");
					curQuery.append("zip:" + keyword + " zip:" + keyword + "* ");
					curQuery.append("phone:" + keyword + " phone:" + keyword + "* ");
					curQuery.append("alphasearch:" + keyword + " alphasearch:" + keyword + "* ");
					curQuery.append("address1:" + keyword + " address1:" + keyword + "*)");
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

	private TopDocs generateCustomerDocs(StringBuffer sb, IndexSearcher searcher) {
		Analyzer analyzer = new StandardAnalyzer();
		String[] searchFields = new String[8];
		searchFields[0] = "customerid";
		searchFields[1] = "name";
		searchFields[2] = "city";
		searchFields[3] = "state";
		searchFields[4] = "zip";
		searchFields[5] = "phone";
		searchFields[6] = "alphasearch";
		searchFields[7] = "address1";
		QueryParser parser = new MultiFieldQueryParser(searchFields, analyzer);
		return LuceneUtils.generateDocs(sb, searcher, parser);
	}
}
