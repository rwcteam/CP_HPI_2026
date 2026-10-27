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

public class LuceneContactsSearch {
	private final static String SEARCHER_PATH_ROOT = "/opt/lucene/sd";
	private final static String CONTACTS_SEARCHER_PATH = SEARCHER_PATH_ROOT + "/contacts";

	public ArrayList findContactsByKeyword(String companyId, String keywords, String whseNo, String state) {
		ArrayList result = new ArrayList();
		if (whseNo != null && companyId != null && keywords != null) {
			
			StringBuffer sb = buildContactsQuery(keywords, whseNo, state);
			Utils.logDebug("sb: '" + sb.toString() + "'");
			if (!LuceneUtils.isNull(sb.toString())) {
				IndexSearcher searcher = null;
				try {
					searcher = LuceneUtils.getSearcher(CONTACTS_SEARCHER_PATH);
					TopDocs docs = generateContactsDocs(sb, searcher);
					for (int i = 0; i < docs.totalHits; i++) {
						ScoreDoc doc = docs.scoreDocs[i];
						String docContactSeq = searcher.doc(doc.doc).get("contactseq");
						String docFirstName = searcher.doc(doc.doc).get("firstname");
						String docMiddleName = searcher.doc(doc.doc).get("middlename");
						String docLastName = searcher.doc(doc.doc).get("lastname");
						String docCompanyName = searcher.doc(doc.doc).get("companyname");
						String docPhoneWork = searcher.doc(doc.doc).get("phonework");
						String docPhoneCell = searcher.doc(doc.doc).get("phonecell");
						String docPhoneHome = searcher.doc(doc.doc).get("phonehome");
						String docFax = searcher.doc(doc.doc).get("fax");
						String docEmail1 = searcher.doc(doc.doc).get("email1");
//						String docEmail2 = searcher.doc(doc.doc).get("email2");
//						String docEmail3 = searcher.doc(doc.doc).get("email3");
//						String docAddress1 = searcher.doc(doc.doc).get("address1");
//						String docAddress2 = searcher.doc(doc.doc).get("address2");
//						String docCity = searcher.doc(doc.doc).get("city");
//						String docState = searcher.doc(doc.doc).get("state");
//						String docZip = searcher.doc(doc.doc).get("zip");
//						String docWebsite = searcher.doc(doc.doc).get("website");
						float score = doc.score;
						String row = docContactSeq + "|" + docFirstName + "|" + docLastName + "|" + docCompanyName + "|" + docPhoneWork + "|" + docPhoneCell + "|" + docFax + "|" + docEmail1;
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
	public JSONObject findContactsByKeywordJson(String companyId, String keywords, String whse,  
		   	String state) throws Exception{
		JSONObject json = new JSONObject();
		if (whse != null && companyId != null && keywords != null) {
			
			StringBuffer sb = buildContactsQuery(keywords, whse, state);
			Utils.logDebug("sb: '" + sb.toString() + "'");
			if (!LuceneUtils.isNull(sb.toString())) {
				IndexSearcher searcher = null;
				try {
					searcher = LuceneUtils.getSearcher(CONTACTS_SEARCHER_PATH);
					TopDocs docs = generateContactsDocs(sb, searcher);
					for (int i = 0; i < docs.totalHits; i++) {
						JSONArray itemjson = new JSONArray(); 
						ScoreDoc doc = docs.scoreDocs[i];
						itemjson.put(searcher.doc(doc.doc).get("contactseq"));
						itemjson.put(searcher.doc(doc.doc).get("firstname"));
						itemjson.put(searcher.doc(doc.doc).get("middlename"));
						itemjson.put(searcher.doc(doc.doc).get("lastname"));
						itemjson.put(searcher.doc(doc.doc).get("companyname"));
						itemjson.put(searcher.doc(doc.doc).get("phonework"));
						itemjson.put(searcher.doc(doc.doc).get("phonecell"));
						itemjson.put(searcher.doc(doc.doc).get("phonehome"));
						itemjson.put(searcher.doc(doc.doc).get("fax"));
						itemjson.put(searcher.doc(doc.doc).get("email1"));
						itemjson.put(searcher.doc(doc.doc).get("email2"));
						itemjson.put(searcher.doc(doc.doc).get("email3"));
						itemjson.put(searcher.doc(doc.doc).get("address1"));
						itemjson.put(searcher.doc(doc.doc).get("address2"));
						itemjson.put(searcher.doc(doc.doc).get("city"));
						itemjson.put(searcher.doc(doc.doc).get("state"));
						itemjson.put(searcher.doc(doc.doc).get("zip"));
						itemjson.put(searcher.doc(doc.doc).get("website"));
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
	public StringBuffer buildContactsQuery(String keywords, String whseNo, String whseState) {
		StringBuffer sb = new StringBuffer();
		keywords = keywords.replaceAll("[\\[\\]{}()^:!&\\\\]", " ").trim();
		if (keywords.length() > 0) {
			String[] words = keywords.split("\\s");
			for (int i = 0; i < words.length; i++) {
				String keyword = words[i].trim();
				if (keyword.length() > 0 && !LuceneUtils.isStopWord(keyword)) {
					StringBuffer curQuery = new StringBuffer();
					curQuery.append("+(contactseq:" + keyword + " contactseq:" + keyword + "* ");
					curQuery.append("firstname:" + keyword + "^2 firstname:" + keyword + "* ");
					curQuery.append("middlename:" + keyword + " middlename:" + keyword + "* ");
					curQuery.append("lastname:" + keyword + " lastname:" + keyword + "* ");
					curQuery.append("companyname:" + keyword + " companyname:" + keyword + "* ");
					curQuery.append("phonework:" + keyword + " phonework:" + keyword + "* ");
					curQuery.append("phonecell:" + keyword + " phonecell:" + keyword + "* ");
					curQuery.append("phonehome:" + keyword + " phonehome:" + keyword + "* ");
					curQuery.append("fax:" + keyword + " fax:" + keyword + "* ");
					curQuery.append("email1:" + keyword + " email1:" + keyword + "*)");
	//				curQuery.append("email2:" + keyword + " email2:" + keyword + "* ");
	//				curQuery.append("email3:" + keyword + " email3:" + keyword + "* ");
	//				curQuery.append("address1:" + keyword + " address1:" + keyword + "* ");
	//				curQuery.append("address2:" + keyword + " address2:" + keyword + "* ");
	//				curQuery.append("city:" + keyword + " city:" + keyword + "* ");
	//				curQuery.append("state:" + keyword + " state:" + keyword + "* ");
	//				curQuery.append("zip:" + keyword + " zip:" + keyword + "* ");
	//				curQuery.append("website:" + keyword + " website:" + keyword + "*)");
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

	private TopDocs generateContactsDocs(StringBuffer sb, IndexSearcher searcher) {
		Analyzer analyzer = new StandardAnalyzer();
		String[] searchFields = new String[10];
		searchFields[0] = "contactseq";
		searchFields[1] = "firstname";
		searchFields[2] = "middlename";
		searchFields[3] = "lastname";
		searchFields[4] = "companyname";
		searchFields[5] = "phonework";
		searchFields[6] = "phonecell";
		searchFields[7] = "phonehome";
		searchFields[8] = "fax";
		searchFields[9] = "email1";
//		searchFields[10] = "email2";
//		searchFields[11] = "email3";
//		searchFields[12] = "address1";
//		searchFields[13] = "address2";
//		searchFields[14] = "city";
//		searchFields[15] = "state";
//		searchFields[16] = "zip";
//		searchFields[17] = "website";
		QueryParser parser = new MultiFieldQueryParser(searchFields, analyzer);
		return LuceneUtils.generateDocs(sb, searcher, parser);
	}
}
