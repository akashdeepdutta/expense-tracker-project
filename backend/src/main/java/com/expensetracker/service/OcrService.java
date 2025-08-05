package com.expensetracker.service;


import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class OcrService {

    @Value("${ocr.tesseract.data-path}")
    private String tessDataPath;

    @Value("${ocr.tesseract.language}")
    private String language;

    @Value("${ocr.tesseract.confidence-threshold}")
    private Double confidenceThreshold;



    /**
     * Extract data from receipt image
     */
    public ReceiptData extractReceiptData(String imageBase64, String imageFormat) {
        try {
            // Decode base64 image
            byte[] imageBytes = Base64.getDecoder().decode(imageBase64.replaceFirst("data:image/[^;]*;base64,", ""));
            BufferedImage image = ImageIO.read(new ByteArrayInputStream(imageBytes));

            // Perform OCR
            Tesseract tesseract = new Tesseract();
            tesseract.setDatapath(tessDataPath);
            tesseract.setLanguage(language);

            String ocrText = tesseract.doOCR(image);

            // Parse extracted data
            ReceiptData receiptData = parseReceiptText(ocrText);
            receiptData.setOcrText(ocrText);
            receiptData.setConfidence(0.8); // Default confidence level

            return receiptData;

        } catch (TesseractException | IOException e) {
            throw new RuntimeException("Error processing receipt image", e);
        }
    }

    /**
     * Parse receipt text to extract structured data
     */
    private ReceiptData parseReceiptText(String ocrText) {
        ReceiptData data = new ReceiptData();

        // Extract merchant name (usually at the top)
        String merchantName = extractMerchantName(ocrText);
        data.setMerchantName(merchantName);

        // Extract total amount
        BigDecimal totalAmount = extractTotalAmount(ocrText);
        data.setTotalAmount(totalAmount);

        // Extract tax amount
        BigDecimal taxAmount = extractTaxAmount(ocrText);
        data.setTaxAmount(taxAmount);

        // Extract date
        LocalDate date = extractDate(ocrText);
        data.setDate(date);

        // Extract line items
        List<ReceiptItem> items = extractLineItems(ocrText);
        data.setItems(items);

        return data;
    }

    /**
     * Extract merchant name from receipt text
     */
    private String extractMerchantName(String text) {
        String[] lines = text.split("\n");
        for (String line : lines) {
            line = line.trim();
            if (!line.isEmpty() && !line.matches(".*\\d+.*") && line.length() > 3) {
                return line;
            }
        }
        return "Unknown Merchant";
    }

    /**
     * Extract total amount from receipt text
     */
    private BigDecimal extractTotalAmount(String text) {
        // Look for total patterns
        Pattern[] patterns = {
            Pattern.compile("TOTAL\\s*[\\$]?([\\d,]+\\.\\d{2})", Pattern.CASE_INSENSITIVE),
            Pattern.compile("AMOUNT\\s*[\\$]?([\\d,]+\\.\\d{2})", Pattern.CASE_INSENSITIVE),
            Pattern.compile("GRAND TOTAL\\s*[\\$]?([\\d,]+\\.\\d{2})", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\$([\\d,]+\\.\\d{2})\\s*$", Pattern.MULTILINE)
        };

        for (Pattern pattern : patterns) {
            Matcher matcher = pattern.matcher(text);
            if (matcher.find()) {
                String amountStr = matcher.group(1).replace(",", "");
                return new BigDecimal(amountStr);
            }
        }

        // Fallback: look for the largest amount
        Pattern amountPattern = Pattern.compile("([\\d,]+\\.\\d{2})");
        Matcher matcher = amountPattern.matcher(text);
        BigDecimal maxAmount = BigDecimal.ZERO;

        while (matcher.find()) {
            String amountStr = matcher.group(1).replace(",", "");
            BigDecimal amount = new BigDecimal(amountStr);
            if (amount.compareTo(maxAmount) > 0) {
                maxAmount = amount;
            }
        }

        return maxAmount;
    }

    /**
     * Extract tax amount from receipt text
     */
    private BigDecimal extractTaxAmount(String text) {
        Pattern[] patterns = {
            Pattern.compile("TAX\\s*[\\$]?([\\d,]+\\.\\d{2})", Pattern.CASE_INSENSITIVE),
            Pattern.compile("SALES TAX\\s*[\\$]?([\\d,]+\\.\\d{2})", Pattern.CASE_INSENSITIVE),
            Pattern.compile("VAT\\s*[\\$]?([\\d,]+\\.\\d{2})", Pattern.CASE_INSENSITIVE)
        };

        for (Pattern pattern : patterns) {
            Matcher matcher = pattern.matcher(text);
            if (matcher.find()) {
                String amountStr = matcher.group(1).replace(",", "");
                return new BigDecimal(amountStr);
            }
        }

        return BigDecimal.ZERO;
    }

    /**
     * Extract date from receipt text
     */
    private LocalDate extractDate(String text) {
        // Common date patterns
        Pattern[] patterns = {
            Pattern.compile("(\\d{1,2})/(\\d{1,2})/(\\d{2,4})"),
            Pattern.compile("(\\d{1,2})-(\\d{1,2})-(\\d{2,4})"),
            Pattern.compile("(\\d{4})-(\\d{1,2})-(\\d{1,2})")
        };

        for (Pattern pattern : patterns) {
            Matcher matcher = pattern.matcher(text);
            if (matcher.find()) {
                try {
                    int month = Integer.parseInt(matcher.group(1));
                    int day = Integer.parseInt(matcher.group(2));
                    int year = Integer.parseInt(matcher.group(3));
                    
                    // Handle 2-digit years
                    if (year < 100) {
                        year += 2000;
                    }
                    
                    return LocalDate.of(year, month, day);
                } catch (Exception e) {
                    // Continue to next pattern
                }
            }
        }

        return LocalDate.now();
    }

    /**
     * Extract line items from receipt text
     */
    private List<ReceiptItem> extractLineItems(String text) {
        List<ReceiptItem> items = new ArrayList<>();
        String[] lines = text.split("\n");

        for (String line : lines) {
            line = line.trim();
            if (line.isEmpty()) continue;

            // Look for item patterns
            Pattern itemPattern = Pattern.compile("(.+?)\\s+([\\d,]+\\.\\d{2})\\s*x?\\s*(\\d+)?");
            Matcher matcher = itemPattern.matcher(line);

            if (matcher.find()) {
                String itemName = matcher.group(1).trim();
                String priceStr = matcher.group(2).replace(",", "");
                String quantityStr = matcher.group(3);

                if (itemName.length() > 2 && !itemName.matches(".*TOTAL.*|.*TAX.*|.*SUBTOTAL.*")) {
                    BigDecimal price = new BigDecimal(priceStr);
                    int quantity = quantityStr != null ? Integer.parseInt(quantityStr) : 1;

                    ReceiptItem item = new ReceiptItem();
                    item.setName(itemName);
                    item.setPrice(price);
                    item.setQuantity(quantity);

                    items.add(item);
                }
            }
        }

        return items;
    }

    /**
     * Receipt data model
     */
    public static class ReceiptData {
        private String merchantName;
        private BigDecimal totalAmount;
        private BigDecimal taxAmount;
        private LocalDate date;
        private List<ReceiptItem> items;
        private String ocrText;
        private double confidence;

        // Getters and Setters
        public String getMerchantName() { return merchantName; }
        public void setMerchantName(String merchantName) { this.merchantName = merchantName; }

        public BigDecimal getTotalAmount() { return totalAmount; }
        public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

        public BigDecimal getTaxAmount() { return taxAmount; }
        public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

        public LocalDate getDate() { return date; }
        public void setDate(LocalDate date) { this.date = date; }

        public List<ReceiptItem> getItems() { return items; }
        public void setItems(List<ReceiptItem> items) { this.items = items; }

        public String getOcrText() { return ocrText; }
        public void setOcrText(String ocrText) { this.ocrText = ocrText; }

        public double getConfidence() { return confidence; }
        public void setConfidence(double confidence) { this.confidence = confidence; }
    }

    /**
     * Receipt item model
     */
    public static class ReceiptItem {
        private String name;
        private BigDecimal price;
        private int quantity;

        // Getters and Setters
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public BigDecimal getPrice() { return price; }
        public void setPrice(BigDecimal price) { this.price = price; }

        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }
    }
} 