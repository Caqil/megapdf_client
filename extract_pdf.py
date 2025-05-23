import fitz  # PyMuPDF
import json
import os

def extract_text_with_positions(pdf_path):
    # Open the PDF
    doc = fitz.open(pdf_path)
    data = {"pages": []}

    # Iterate through each page
    for page_num in range(len(doc)):
        page = doc[page_num]
        page_data = {
            "page_number": page_num + 1,
            "width": page.rect.width,
            "height": page.rect.height,
            "texts": []
        }

        # Extract text blocks with their coordinates
        for block in page.get_text("dict")["blocks"]:
            if block["type"] == 0:  # Text block
                for line in block["lines"]:
                    for span in line["spans"]:
                        text_info = {
                            "text": span["text"],
                            "x0": span["bbox"][0],  # Left x-coordinate
                            "y0": span["bbox"][1],  # Top y-coordinate
                            "x1": span["bbox"][2],  # Right x-coordinate
                            "y1": span["bbox"][3],  # Bottom y-coordinate
                            "font": span["font"],
                            "size": span["size"],
                            "color": span["color"]
                        }
                        page_data["texts"].append(text_info)
        data["pages"].append(page_data)

    # Save to JSON
    output_path = os.path.join(os.path.dirname(pdf_path), "output.json")
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    doc.close()
    return data

if __name__ == "__main__":
    pdf_path = "test.pdf"  # Update with your PDF path if different
    if not os.path.exists(pdf_path):
        print(f"Error: {pdf_path} not found!")
    else:
        extracted_data = extract_text_with_positions(pdf_path)
        print("Extraction complete. JSON saved as output.json")
