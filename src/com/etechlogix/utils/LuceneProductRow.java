package com.etechlogix.utils;

/**
 * LuceneProductRow is a utility class, used to sort the results of the 
 * LuceneProductSearch.  Since LuceneProductSearch requires a database
 * call, in addition to the Lucene search, the results require an 
 * intermediate step.  This class holds each record of the merged data,
 * and it can then be sorted by the Lucene search score.
 * @author mdg
 *
 */
public class LuceneProductRow implements Comparable {
	private String productNo;
	private String description;
	private String uom;
	private double qtyOnHand;
	private double available;
	private float priceLevel01;
	private float priceLevel02;
	private String priceLevelUom;
	private float score;
	private String oldProductNo;
	/**
	 * LucenProductRow contains the intermediate results of the Lucene search
	 * and database query.
	 * @param productNo - Product Number returned by the search
	 */
	public LuceneProductRow(String productNo) {
		this(productNo, "", "", 0f, 0f, 0f, 0f, "", 0f);
	}
	/**
	 * LuceneProductRow contains the intermediate results of the Lucene search
	 * and database query.
	 * @param productNo - Product Number returned by the search
	 * @param description - Description of the product
	 * @param uom - Unit of measure
	 * @param qtyOnHand - Quantity on hand at the warehouse
	 * @param available - Quantity available (on hand - committed) at the
	 * warehouse
	 * @param score - Lucene search score
	 */
	public LuceneProductRow(String productNo, String description, String uom, 
			double qtyOnHand, double available, float priceLevel01, float priceLevel02,
			String priceLevelUom, float score) {
		this.productNo = productNo;
		this.description = description;
		this.uom = uom;
		this.qtyOnHand = qtyOnHand;
		this.available = available;
		this.priceLevel01 = priceLevel01;
		this.priceLevel02 = priceLevel02;
		this.priceLevelUom = priceLevelUom;
		this.score = score;
	}
	
	public int compareTo(Object obj) {
		if (obj instanceof LuceneProductRow) {
			LuceneProductRow newRow = (LuceneProductRow) obj;
			if (this.score > newRow.score) {
				return 1;
			} else if (this.score < newRow.score) {
				return -1;
			} else {
				return 0;
			}
		}
		return 1;
	}
	
	public void setProductNo(String productNo) {
		this.productNo = productNo;
	}
	public String getProductNo() {
		return this.productNo;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getDescription() {
		return this.description;
	}
	public void setUom(String uom) {
		this.uom = uom;
	}
	public String getUom() {
		return this.uom;
	}
	public void setQtyOnHand(double qtyOnHand) {
		this.qtyOnHand = qtyOnHand;
	}
	public double getQtyOnHand() {
		return this.qtyOnHand;
	}
	public void setAvailable(double available) {
		this.available = available;
	}
	public double getAvailable() {
		return this.available;
	}
	public void setPriceLevel01(float priceLevel01) {
		this.priceLevel01 = priceLevel01;
	}
	public float getPriceLevel01() {
		return this.priceLevel01;
	}
	public void setPriceLevel02(float priceLevel02) {
		this.priceLevel02 = priceLevel02;
	}
	public float getPriceLevel02() {
		return this.priceLevel02;
	}
	public void setPriceLevelUom(String priceLevelUom) {
		this.priceLevelUom = priceLevelUom;
	}
	public String getPriceLevelUom() {
		return this.priceLevelUom;
	}
	public void setScore(float score) {
		this.score = score;
	}
	public float getScore() {
		return this.score;
	}
	public void setOldProductNo(String oldProductNo) {
		this.oldProductNo = oldProductNo;
	}
	public String getOldProductNo() {
		return this.oldProductNo;
	}
	/**
	 * toString() formats the row as a String in the format needed by a 
	 * JQuery auto-complete box.
	 */
	public String toString() {
		return productNo + "|" + description + "|" + uom + "|" + qtyOnHand + "|" + available +
			"|" + priceLevel01 + "|" + priceLevel02 + "|" + priceLevelUom;
	}
}
