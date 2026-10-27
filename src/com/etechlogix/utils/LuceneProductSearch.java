package com.etechlogix.utils;

import java.io.IOException;
import java.util.*;

import com.etechlogix.distribution.utils.DistUtils;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.WhitespaceAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.commons.lang.StringUtils;
import org.json.*;
/**
 * LuceneProductSearch performs a Lucene search against a Lucene database of 
 * product information.  The product database is built by an external script.
 * The primary function is findByNakedSql, which takes multiple
 * parameters to define the query.<br>This search has an internal dictionary of
 * alternate terms for certain keywords.  If the user enters 'MALARKEY', for 
 * example, the search will also look for 'MLRKY' 'MLRKAY', since these are
 * common (mis)spellings of Malarkey.<br>
 * In addition to returning products that match, the results will also include
 * the amount of on-hand and available inventory for the warehouse in question.
 * This requires a database search, in addition to the Lucene search.
 * @author mdg
 *
 */
public class LuceneProductSearch {
	private static Map productSubstitutionMap = new HashMap();
	/*private static final String BASE_QUERY = "select im.companyid, im.productno, " + 
		"(im.description_1 || '; ' || im.description_2) as description, " + 
		"iw.whseno, im.oldproductno, iw.qtyonhand, im.uom_sell as uom, " +
		"(iw.qtyonhand - iw.qtycommited) as available,im.oldproductNo " +
		"from inventorymaster im, inventorywarehouse iw " +
		"where im.companyid = iw.companyid " +
		"and im.productno = iw.productno ";*/
   private static final String BASE_QUERY="select  distinct IM.COMPANYID, IM.productNo,(IM.description_1 || ' ; ' || IM.description_2) as description ,  INW.whseNo,IM.oldproductno, "+
   "IM.uom_sell AS UOM, round(INW.qtyOnHand,3) AS QTYONHAND,round((INW.qtyOnHand-INW.qtyCommited),3) as available "+
   " ,'Y' as OT from  inventorywarehouse INW,inventorymaster IM where IM.companyid=INW.companyid "+
	" and IM.productNo=INW.productNo  " ;
//	private static final String BASE_QUERY = "select im.companyid, im.productno, " + 
//		"(im.description_1 || '; ' || im.description_2) as description, " + 
//		"iw.whseno, im.oldproductno, iw.qtyonhand, im.uom_sell as uom, " +
//		"(iw.qtyonhand - iw.qtycommited) as available, " +
//		"ip.pricelevel_01, ip.pricelevel_02, ip.uom as PRICELEVEL_UOM " +
//		"from inventorymaster im, inventorywarehouse iw, inventorywhseprice ip " +
//		"where im.companyid = iw.companyid " +
//		"and im.productno = iw.productno " +
//		"and iw.companyid = ip.companyid " +
//		"and iw.productno = ip.productno " +
//		"and iw.whseno = ip.whseno " +
//		"and im.uom_price = ip.uom";

	/**
	 * findProductByKeyword performs the query against the Lucene product database.
	 * @param companyId - The company where the product is in inventory
	 * @param keywords - The query words to search.  If multiple words are in 
	 * the string, all of them must be present.  Partial matches are allowed 
	 * but will rank lower than exact matches.  Search words are case-insensitive.
	 * @param whse - The default warehouse.  Products located in this warehouse
	 * that match the query will be prioritized higher.
	 * @param inactive - Include only active or inactive products
	 * @param classId - If not null, only includes products that have this
	 * classId as their parent class.
	 * @return An ArrayList of Strings, formatted for the JQuery auto-complete
	 * box, ordered in descending order by Lucene search score.  Products that have
	 * no available inventory will be at the bottom of the list.
	 */	
	public ArrayList findProductByKeyword(String companyId, String keywords, String whse,  
	   	boolean inactive, String classId) {
	   	ArrayList result = new ArrayList();
	   	    
	   	if (!LuceneUtils.isNull(keywords)) {
		    keywords = keywords.toUpperCase().trim();
		    IndexSearcher searcher = null;
		    String baseQuery = "";
		    try {
			    StringBuffer sb = buildLuceneProductQuery(keywords, classId);
			    Utils.logDebug("findProductByKeyword lucene search " + sb);
			    searcher = LuceneUtils.getSearcher(LuceneUtils.PRODUCT_SEARCHER_PATH);
			    TopDocs docs = generateProductDocs(sb, searcher);		
			    if (docs != null && docs.scoreDocs != null && docs.scoreDocs.length > 0) {	
				    Hashtable scores = cacheLuceneResults(docs, searcher, whse);
					baseQuery = buildDatabaseQuery(companyId, whse, inactive, scores);
				    Utils.logDebug("findProductByKeyword database search " + baseQuery);
				    DistUtils du = new DistUtils();
				    Hashtable queryTable = du.getDataFromQuery(baseQuery);
			    
				    Vector productNo = (Vector) queryTable.get("PRODUCTNO");
				    Vector description = (Vector) queryTable.get("DESCRIPTION");
				    Vector uom = (Vector) queryTable.get("UOM");
				    Vector qtyOnHand = (Vector) queryTable.get("QTYONHAND");
				    Vector available = (Vector) queryTable.get("AVAILABLE");
				    Vector oldProductNo = (Vector) queryTable.get("OLDPRODUCTNO");
				    if (productNo != null && productNo.size() > 0) {
				    	ArrayList rowList = new ArrayList();
				    	for (int i = 0; i < productNo.size(); i++) {
				    		String productNoStr = (String) productNo.get(i);
				    		String descriptionStr = (String) description.get(i);
				    		String uomStr = (String) uom.get(i);
				    		double qtyOnHandFlt = Double.parseDouble((String) qtyOnHand.get(i));
				    		double availableFlt = Double.parseDouble((String) available.get(i));
				    		String oldProductNoStr=(String) oldProductNo.get(i);
				    		LuceneProductRow row = (LuceneProductRow) scores.get(productNoStr);
				    		if (availableFlt <= 0) {
					    		row.setScore(0);
				    		}
				    		row.setDescription(descriptionStr);
				    		row.setUom(uomStr);
				    		row.setQtyOnHand(qtyOnHandFlt);
				    		row.setAvailable(availableFlt);
				    		row.setOldProductNo(oldProductNoStr);
				    		rowList.add(row);
				    	}
			    		Collections.sort(rowList);
			    		Collections.reverse(rowList);
			    		
			    		for (int i = 0; i < rowList.size(); i++) {
			    			LuceneProductRow row = (LuceneProductRow) rowList.get(i);
			    			//result.add(row.toString());
			    			result.add(row);
			    		}
			    	}
			    }
			} catch (Exception e) {
				    Utils.logError(e.getMessage() + ", query: " + baseQuery, e);
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
		return result;
	}
	public JSONObject findProductByKeywordJson(String companyId, String keywords, String whse,  
		   	boolean inactive, String classId) throws Exception{
		JSONObject json = new JSONObject();
		try{
		ArrayList searchedProduct= findProductByKeyword(companyId, keywords.trim(), whse,inactive, classId);
		for(int i = 0; i < searchedProduct.size(); i++) {
			JSONArray itemjson = new JSONArray(); 
			itemjson.put(whse);
			itemjson.put(((LuceneProductRow) searchedProduct.get(i)).getProductNo().toString());
			itemjson.put(((LuceneProductRow) searchedProduct.get(i)).getOldProductNo().toString());
			itemjson.put(((LuceneProductRow) searchedProduct.get(i)).getDescription().toString());
			itemjson.put(((LuceneProductRow) searchedProduct.get(i)).getUom().toString());	
			itemjson.put(((LuceneProductRow) searchedProduct.get(i)).getQtyOnHand());
			itemjson.put(((LuceneProductRow) searchedProduct.get(i)).getAvailable());
			itemjson.put(((LuceneProductRow) searchedProduct.get(i)).getProductNo().toString());
			itemjson.put("Y");
			json.append("aaData", itemjson);
			}
		}
		catch (Exception e) {
			Utils.logError("Error in item search", e);
			throw new Exception("Error in Jsondataquery: ", e);
		}
		return json;
	}

	/**
	 * buildDatabaseQuery  builds the query needed to find the quantities on 
	 * hand and available from the database.
	 * @param companyId - Company for the search
	 * @param whse - Warehouse where the material is in inventory
	 * @param inactive - whether the products in the query are active or inactive
	 * @param scores - Lucene score for the document
	 * @return a well-formed SQL statement that can be executed against SD
	 * @throws IOException if the passed searcher is invalid for some reason.
	 */
	private String buildDatabaseQuery(String companyId, String whse, 
			boolean inactive, Hashtable scores) {
		String baseQuery = BASE_QUERY;
		if (!LuceneUtils.isNull(companyId)) {
			baseQuery += " and im.companyId = '" + companyId + "'";
		}
		    
		if (!LuceneUtils.isNull(whse) && whse != "ALL") {
			baseQuery += " and inw.whseno = '" + whse + "'";
		}
		    
		if (inactive) {
			baseQuery += " and nvl(im.active, 'N') = 'N'";
		} else {
			baseQuery += " and nvl(im.active, 'N') = 'Y'";
		}
		
	    baseQuery += " and (";
	    boolean first = true;
	    for (Enumeration enumKeys = scores.keys(); enumKeys.hasMoreElements(); ) {
	    	String productNo = enumKeys.nextElement().toString();
		    if (!first) {
			    baseQuery += " or ";
		    }
		    first = false;
		    baseQuery += " im.productno = '" + productNo + "'";
	    }	
	    baseQuery += ")";
		
		return baseQuery;
	}

	/**
	 * cacheScores reads the scores and associated product numbers from the 
	 * Lucene database, for future use
	 * @param docs result of Lucene search, includes score and document number
	 * @param searcher link to the Lucene database, so that the document (with
	 * product number) can be retrieved
	 * @param whseNo warehouse containing the product.  whseNo is required so 
	 * that the correct pricelevels are returned.  The lucene records store all 
	 * pricelevels for all warehouses.
	 * @return Hashtable keyed on product number, with the score associated 
	 * with that product
	 * @throws IOException if the searcher is invalid
	 */
	private Hashtable cacheLuceneResults(TopDocs docs, IndexSearcher searcher, String whseNo) throws IOException {
	    Hashtable results = new Hashtable();
	    for (int i = 0; i < docs.scoreDocs.length; i++) {
	    	Document doc = searcher.doc(docs.scoreDocs[i].doc);
		    String productNo = doc.get("productno");
		    String description = "";
		    String uom = "";
		    float qtyOnHand = 0f;
		    float available = 0f;
		    float pricelevel_01 = 0f;
		    float pricelevel_02 = 0f;
		    try {
			    pricelevel_01 = Float.parseFloat(doc.get(whseNo + ":pricelevel_01"));
			    pricelevel_02 = Float.parseFloat(doc.get(whseNo + ":pricelevel_02"));
		    } catch (Exception e) {
		    	// ignore, should be 0f from above for pricelevel_01 and _02
		    }
		    String pricelevel_uom = doc.get("pricelevel_uom");
		    float score = docs.scoreDocs[i].score;
		 
		    LuceneProductRow row = new LuceneProductRow(productNo, description, uom, qtyOnHand, available, 
		    		pricelevel_01, pricelevel_02, pricelevel_uom, score);
		    results.put(productNo, row);
	    }
	    return results;
	}
	
	public StringBuffer buildLuceneProductQuery(String keywords, String classId) {
		StringBuffer sb = new StringBuffer();
		if (keywords != null && keywords.trim().length() > 0) {
			keywords = keywords.replaceAll("[\\[\\]{}()^:!\\\\]", "");
			String[] keys = keywords.split("\\s");
			for (int i = 0; i < keys.length; i++) {
	
				if (i > 0) {
					sb.append(" ");
				}
			
				String k = keys[i].trim().toLowerCase();
				sb.append(buildKeySubquery(k));
			}
			if (classId != null && classId.length() > 0) {
				sb.append(" +(classId:" + classId + "*)");
			}
		}
		return sb;
	}

	private TopDocs generateProductDocs(StringBuffer sb, IndexSearcher searcher) {
		Analyzer analyzer = new WhitespaceAnalyzer();
		QueryParser parser = new QueryParser("keyword", analyzer);
		return LuceneUtils.generateDocs(sb, searcher, parser);
	}
		
	private StringBuffer buildKeySubquery(String key) {
		StringBuffer sb = new StringBuffer();
		// "-" is the negate query function in Lucene.  If it is by itself, ignore
		if (key == null || key.trim().length() == 0) {
			return sb;
		}
		if (key == "-") {
			return sb;
		}

		if (StringUtils.isNumeric(key)) {
			key = "*" + key;
		}
		
		if (productSubstitutionMap.containsKey(key)) {
		
			String[] subs = (String[]) productSubstitutionMap.get(key);
		
			if (subs.length > 1) {
				sb.append("+(");
		
				for (int j = 0; j < subs.length; j++) {
					if (j > 0) {
						sb.append(" OR ");
					}
					sb.append(subs[j]).append("*");
				}
				sb.append(")");
			} else if (subs.length == 1) {
				sb.append("+").append(key).append("*");
			}
		
		} else {
			// exact matches count more, but include partial matches
			sb.append("+(");
			sb.append(key).append("*").append(" "); // partial
			sb.append(key); // exact
			sb.append(")");
		}
		return sb;
	}

	static {
		List subList = new ArrayList();
		subList.add(new String[] { "malarkey", "mlrky", "mlarky" });
		subList.add(new String[] { "brown", "br", "brwn", "brn" });
		subList.add(new String[] { "white", "wh", "wht" });
		subList.add(new String[] { "black", "bl", "bk", "blk" });
		subList.add(new String[] { "green", "gr", "grn" });
		subList.add(new String[] { "gray", "gr", "gry" });
		subList.add(new String[] { "yellow", "yel", "ylw" });
		subList.add(new String[] { "orange", "orng", "ornge" });
		subList.add(new String[] { "terracotta", "terra cotta", "tc", "tccta",
				"tctta" });
		subList.add(new String[] { "piece", "pc" });
		subList.add(new String[] { "box", "bx" });
		subList.add(new String[] { "roll", "rl" });
		subList.add(new String[] { "pallet", "pal" });
		subList.add(new String[] { "redland", "rdlnd", "redlnd" });
		subList.add(new String[] { "plastic", "plas", "plast" });
		subList.add(new String[] { "cement", "cmnt", "cemnt" });
		subList.add(new String[] { "roofing", "rfg" });
		subList.add(new String[] { "roof", "rf" });
		subList.add(new String[] { "shake", "sh", "shk", "shke" });
		subList.add(new String[] { "slate", "sl", "slt", "slte" });
		subList.add(new String[] { "capistrano", "capi", "capis" });
		subList.add(new String[] { "ridge", "rg", "rge" });
		subList.add(new String[] { "rake", "rk", "rke" });
		subList.add(new String[] { "mansard", "mans", "trim" });
		subList.add(new String[] { "birdstop", "brdstp", "bdstp", "bs" });
		subList.add(new String[] { "2-pc", "2pc", "pc" });
		subList.add(new String[] { "malibu", "mali" });
		subList.add(new String[] { "coating", "coat" });
		subList.add(new String[] { "aluminum", "alum", "alm" });
		subList.add(new String[] { "galvanized", "galv" });
		subList.add(new String[] { "gallon", "gal", "gl" });
		subList.add(new String[] { "fieldstone", "fldstne" });
		subList.add(new String[] { "villa", "vil" });
		subList.add(new String[] { "gafelk", "ge","elk" });
		productSubstitutionMap = new HashMap();

		for (int i = 0; i < subList.size(); i++) {

			List wordList = Arrays.asList((String[]) subList.get(i));
			Collections.sort(wordList, new Comparator() {
				public int compare(Object arg0, Object arg1) {
					return ((String) arg0).compareToIgnoreCase((String) arg1) * -1;
				}
			});

			// each word is a key
			for (int j = 0; j < wordList.size(); j++) {
				List currentWords = new ArrayList();
				for (int z = 0; z < wordList.size(); z++) {
					currentWords.add(wordList.get(z));
				}
				if (currentWords.size() != 0)
					productSubstitutionMap.put(wordList.get(j), currentWords
							.toArray(new String[currentWords.size()]));
			}
		}
	}
}
