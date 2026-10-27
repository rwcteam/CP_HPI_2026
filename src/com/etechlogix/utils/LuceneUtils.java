package com.etechlogix.utils;

import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.queryParser.QueryParser;
import java.io.File;;

public class LuceneUtils {
	
	private final static String SEARCHER_PATH_ROOT = "/opt/lucene/sd";
	public final static String VENDOR_SEARCHER_PATH = SEARCHER_PATH_ROOT + "/vendor";
	public final static String PRODUCT_SEARCHER_PATH = SEARCHER_PATH_ROOT + "/product";
	public final static String CUSTOMER_SEARCHER_PATH = SEARCHER_PATH_ROOT + "/customer";
	public final static String CONTACTS_SEARCHER_PATH = SEARCHER_PATH_ROOT + "/contacts";
	
	/**
	 * generateDocs returns a Lucene TopDocs object, which represents a list
	 * of document IDs and scores for the match.  
	 * @param sb The query that should be run against the database.  If the query
	 * is blank, TopDocs will have no results
	 * @param searcher The IndexSearcher is the hook into the Lucene database.
	 * If the searcher is null, TopDocs will have no results and will log an error
	 * @param parser The parser will parse the query into the correct Lucene
	 * format.  If the parser is null, TopDocs will have no results and will 
	 * log an error.
	 * @return TopDocs, which is the list of document IDs and scores that match
	 * the query.
	 */
	public static TopDocs generateDocs(StringBuffer sb, IndexSearcher searcher, QueryParser parser) {
		ScoreDoc[] scoreDocs = new ScoreDoc[0];
		TopDocs docs = new TopDocs(0, scoreDocs, 0f);
		if (sb != null && sb.toString().trim().length() > 0) {
			BooleanQuery.setMaxClauseCount(65536);
			try {
				if (parser == null) {
					throw new Exception("parser is null");
				}
				if (searcher == null) {
					throw new Exception("searcher is null");
				}
				parser.setAllowLeadingWildcard(true);
				Query query = parser.parse(sb.toString());
				docs = searcher.search(query, 100000);
			} catch (Exception e) {
				Utils.logError(e.getMessage() + " sb: '" + sb.toString() + "'", e);
			}
		}
		return docs;
	}

	/**
	 * getSearcher returns a Lucene IndexSearch, which is pointed at the Lucene
	 * database, located at the searcher path
	 * @param searcherPath - directory containing the Lucene database
	 * @return IndexSearcher for the database at the path.  If no database
	 * exists at the path, returns null.
	 */
	public static IndexSearcher getSearcher(String searcherPath) {
		IndexSearcher searcher = null;
		try {
			Directory directory = FSDirectory.getDirectory(new File(
				searcherPath));	
			searcher = new IndexSearcher(directory);
		} catch (Exception e) {
			Utils.logError(e.getMessage() + " Cannot locate directory or searcher", e);
		}
		return searcher;
	}

	/**
	 * isNull evaluates a String to determine if it represents a null value.  
	 * The parameter is null if the string is null, zero-length, or equal to  
	 * the word "null"
	 * @param parm
	 * @return true if null, false if not
	 */
	public static boolean isNull(String parm) {
	    if (parm == null) {
	    	    return true;
	    } else if (parm.equalsIgnoreCase("null")) {
	    	    return true;
	    } else if (parm.length() == 0) {
	    	    return true;
	    } else {
	    	    return false;
	    }
	}
	
	/**
	 * isStopWord evaluates the inbound keyword to see if it matches any of 
	 * a list of Stop Words.  A Stop Word is a word that should be ignored
	 * by a Lucene search, since the word is so common it is not valuable to 
	 * search by.
	 * @param keyword
	 * @return true if the keyword is in a list of Stop Words, false if not
	 */
	public static boolean isStopWord(String keyword) {
		String[] stopWords = {"a", "an", "and", "or", "the", "-"};
		for (int i = 0; i < stopWords.length; i++) { 
			if (stopWords[i].equals(keyword)) {
				return true;
			}
		}
		return false;	
	}

}
