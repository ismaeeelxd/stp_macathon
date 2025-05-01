# # test_integration.py
# import os
# import torch
# from PIL import Image, ImageOps
# from ultralytics import YOLO
# from transformers import TrOCRProcessor, VisionEncoderDecoderModel
# from sentence_transformers import SentenceTransformer
# import numpy as np
# import pandas as pd
# import re
# from pyxdameraulevenshtein import damerau_levenshtein_distance

# # --- Configuration ---
# DATABASE_PATH = "database.xlsx"
# is_ismail = True
# MODEL_DIR = "models"
# if is_ismail:
#     MODEL_DIR = "/run/media/ismail/New Volume/stp_backend/models"
# YOLO_MODEL_PATH = os.path.join(MODEL_DIR, "best.pt")

# print(YOLO_MODEL_PATH)
# # Ensure the models directory exists
# os.makedirs(MODEL_DIR, exist_ok=True)
# # --- Download Models/Data (Run this part once manually or in a setup script) ---
# # You might need to manually download best.pt and place it in models/
# # You also need database.xlsx in the root directory.
# from huggingface_hub import hf_hub_download
# # import gdown


# script_dir = os.path.dirname(os.path.abspath(__file__))
# print(script_dir)
# print(YOLO_MODEL_PATH)
# print(os.path.exists)
# if not os.path.exists("/run/media/ismail/New Volume/stp_backend/models"):
#     print("Downloading YOLO model...")
#     hf_hub_download(repo_id="wahdan2003/YOLO_handwritten_medical", filename="best.pt", local_dir=MODEL_DIR)
# # if not os.path.exists(DATABASE_PATH):
# #      print("Downloading database...")
# #      file_id = "16TB9xdyX3gV-ehGwDq1p3j6Ba_3uk3Od"
# #      url = f"https://drive.google.com/uc?id={file_id}"
# #      gdown.download(url, DATABASE_PATH, quiet=False)
# # --- Global Variables / Model Loading (Load once) ---
# device = "cuda" if torch.cuda.is_available() else "cpu"
# print(f"Using device: {device}")

# print("Loading YOLO model...")
# yolo_model = YOLO(YOLO_MODEL_PATH)
# print("Loading TrOCR model...")
# processor = TrOCRProcessor.from_pretrained("wahdan2003/tr-ocr-khatt-IAM-medical",use_safetensors=True)
# model = VisionEncoderDecoderModel.from_pretrained("wahdan2003/tr-ocr-khatt-IAM-medical",use_safetensors=True).to(device)
# print("Loading Sentence Transformer model...")
# sentence_model = SentenceTransformer('sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2')

# print("Loading database...")
# df = pd.read_excel(DATABASE_PATH)
# database_terms = df['Unique Text'].astype(str).tolist()
# is_medicine_dict = dict(zip(database_terms, df['IsMedicine']))
# database_embeddings = sentence_model.encode(database_terms, convert_to_tensor=True)
# print("Models and data loaded.")

# # --- Helper Functions (Copy from test.py) ---
# def resize_image(image, target_size=(640, 640)):
#     # ... (copy function from test.py)
#     aspect_ratio = image.width / image.height
#     if aspect_ratio > 1:
#         new_width = target_size[0]
#         new_height = int(new_width / aspect_ratio)
#     else:
#         new_height = target_size[1]
#         new_width = int(new_height * aspect_ratio)
#     img_resized = image.resize((new_width, new_height), Image.Resampling.LANCZOS)
#     return ImageOps.pad(img_resized, target_size, color=(114, 114, 114))

# def correct_term_lv(text, terms, max_distance=2):
#     # ... (copy function from test.py)
#     text = str(text).strip()
#     best_match = min(terms, key=lambda term: damerau_levenshtein_distance(text, term))
#     best_distance = damerau_levenshtein_distance(text, best_match)
#     return best_match if best_distance <= max_distance else -1

# def correct_term_semantic(text, embeddings, terms, threshold=0.7):
#      # ... (copy function from test.py)
#     text_embedding = sentence_model.encode(text, convert_to_tensor=True)
#     # Ensure embeddings are on CPU for numpy operations if they aren't already
#     db_embeddings_cpu = embeddings.cpu().numpy()
#     text_embedding_cpu = text_embedding.cpu().numpy()

#     scores = np.dot(db_embeddings_cpu, text_embedding_cpu) / (
#         np.linalg.norm(db_embeddings_cpu, axis=1) * np.linalg.norm(text_embedding_cpu)
#     )
#     best_match_idx = np.argmax(scores)
#     return terms[best_match_idx] if scores[best_match_idx] > threshold else text


# def correct_term_hybrid(text, terms, embeddings, max_distance=3, threshold=0.5):
#     # ... (copy function from test.py)
#     corrected_text = correct_term_lv(text, terms, max_distance)
#     # Use semantic similarity if Levenshtein fails or returns the original text unchanged
#     # and the original text wasn't already a perfect match (distance 0)
#     lv_distance = damerau_levenshtein_distance(text, corrected_text) if corrected_text != -1 else max_distance + 1

#     if corrected_text == -1 or (corrected_text == text and lv_distance > 0) :
#          corrected_text_semantic = correct_term_semantic(text, embeddings, terms, threshold)
#          # Only return semantic if it's different from the original input
#          if corrected_text_semantic != text:
#              return corrected_text_semantic
#          # If semantic also returns original text, and Levenshtein failed, return original
#          elif corrected_text == -1:
#              return text

#     # If Levenshtein returned a correction (potentially the same word if distance=0)
#     # or if semantic returned the original word back
#     return corrected_text if corrected_text != -1 else text

# def preprocess_text(text):
#      # ... (copy function from test.py)
#     english_to_arabic_numbers = str.maketrans("0123456789", "٠١٢٣٤٥٦٧٨٩")
#     text = re.sub(r'\b(vitamin)\s+', r'\1', text, flags=re.IGNORECASE)
#     def convert_numbers(match):
#         return f"{match.group(1)} {match.group(2).translate(english_to_arabic_numbers)} {match.group(3)}"
#     text = re.sub(r'([\u0600-\u06FF\s])([\d]+)([\u0600-\u06FF\s])', convert_numbers, text)
#     # Handle numbers at the beginning or end of the string or next to punctuation
#     text = re.sub(r'^([\d]+)\s*([\u0600-\u06FF])', lambda m: f"{m.group(1).translate(english_to_arabic_numbers)} {m.group(2)}", text)
#     text = re.sub(r'([\u0600-\u06FF])\s*([\d]+)$', lambda m: f"{m.group(1)} {m.group(2).translate(english_to_arabic_numbers)}", text)
#     return text


# def process_text(text):
#      # ... (copy function from test.py)
#     text = preprocess_text(text)
#     # More robust tokenization to handle various characters
#     words = re.findall(r'[\u0600-\u06FF\w]+|[\d]+|[^\s\w\u0600-\u06FF]+', text)


#     corrected_pairs = []
#     #print(f"Original words: {words}") # Debugging
#     for word in words:
#         # Skip punctuation or symbols if needed, or process them differently
#         if not re.match(r'^[\u0600-\u06FF\w\d]+$', word): # Basic check if it's a word/number
#              corrected_pairs.append((word, -2)) # Use -2 to denote non-processable tokens
#              continue

#         # Attempt correction only on potential words
#         corrected_word = correct_term_hybrid(word, database_terms, database_embeddings)
#         is_medicine = is_medicine_dict.get(corrected_word, 0) # Default to 0 if not found
#         #print(f"Word: '{word}' -> Corrected: '{corrected_word}', Is Medicine: {is_medicine}") # Debugging
#         corrected_pairs.append((corrected_word, is_medicine))

#     grouped_pairs = []
#     current_medicine = []
#     current_instruction = []

#     for word, type_flag in corrected_pairs:
#         if type_flag == 1: # Is medicine
#             if current_instruction:
#                  # Check if the previous block was actually medicine
#                  prev_med_str = " ".join(current_medicine)
#                  prev_instr_str = " ".join(current_instruction)
#                  # Basic check: if instruction part contains known medicine, flip
#                  contains_medicine_in_instr = any(is_medicine_dict.get(w, 0) == 1 for w in current_instruction)
#                  if contains_medicine_in_instr and not any(is_medicine_dict.get(w,0)==1 for w in current_medicine):
#                       grouped_pairs.append((prev_instr_str, prev_med_str))
#                  else: # Assume medicine part is correct
#                       grouped_pairs.append((prev_med_str, prev_instr_str))

#                  current_medicine = []
#                  current_instruction = []

#             current_medicine.append(word)
#         elif type_flag == 0:
#             current_instruction.append(word)
#         # else: type_flag == -2 (punctuation, etc.), optionally add to instruction or handle separately
#         elif type_flag == -2 and current_instruction: # Append punctuation to instruction if exists
#              current_instruction.append(word)


#     # Add the last collected pair after the loop
#     if current_medicine or current_instruction:
#         prev_med_str = " ".join(current_medicine)
#         prev_instr_str = " ".join(current_instruction)
#         contains_medicine_in_instr = any(is_medicine_dict.get(w, 0) == 1 for w in current_instruction)

#         if contains_medicine_in_instr and not any(is_medicine_dict.get(w,0)==1 for w in current_medicine):
#             # Flip if instruction seems to contain medicine and medicine part doesn't
#              grouped_pairs.append((prev_instr_str, prev_med_str))
#         elif not prev_med_str and prev_instr_str: # Only instruction found
#              # Decide how to handle instruction-only text (e.g., pair with empty medicine?)
#               grouped_pairs.append(("", prev_instr_str)) # Or handle as needed
#         elif prev_med_str: # Assume medicine part is correct if it exists
#              grouped_pairs.append((prev_med_str, prev_instr_str))
#         # Implicitly handles case where both are empty or only non-word tokens existed

#     # Clean up empty strings possibly created by punctuation handling or logic
#     final_pairs = [(med.strip(), instr.strip()) for med, instr in grouped_pairs if med.strip() or instr.strip()]

#     return final_pairs


# --- Main Processing Function (modified slightly) ---
# def submit(image_path):
#     """
#     Processes a single prescription image and extracts the associated text.

#     Args:
#         image_path (str): Path to the input prescription image.

#     Returns:
#         list: Extracted and processed prescription text pairs, or None if error.
#     """
#     try:
#         image = Image.open(image_path).convert("RGB")
#         resized_image = resize_image(image, target_size=(640, 640))

#         # Use the globally loaded yolo_model
#         results = yolo_model.predict(
#             source=resized_image,
#             imgsz=640,
#             device=device, # Use global device
#             save=False,
#             conf=0.4,
#             iou=0.6,
#             max_det=50
#         )

#         boxes = results[0].boxes
#         coords = boxes.xywhn.cpu().numpy()

#         # Sort top-to-bottom
#         sorted_indices = coords[:, 1].argsort()
#         sorted_coords = coords[sorted_indices]

#         img_width, img_height = resized_image.size # Use actual resized image size
#         crops = []
#         for coord in sorted_coords:
#             x_center, y_center, width, height = coord
#             # Clamp coordinates to image bounds
#             x_min = max(0, int((x_center - width / 2) * img_width))
#             x_max = min(img_width, int((x_center + width / 2) * img_width))
#             y_min = max(0, int((y_center - height / 2) * img_height))
#             y_max = min(img_height, int((y_center + height / 2) * img_height))

#             # Ensure coordinates are valid
#             if x_min >= x_max or y_min >= y_max:
#                  continue # Skip invalid boxes

#             crop = resized_image.crop((x_min, y_min, x_max, y_max))

#             # Padding might be necessary depending on TrOCR model expectations
#             target_crop_size = (384, 384) # Example size, adjust if needed
#             crop = ImageOps.pad(crop, target_crop_size, color=(255, 255, 255))
#             crops.append(crop)

#         extracted_text = ""
#         if crops: # Only run OCR if crops were successfully extracted
#              # Process crops in batches if possible/needed for efficiency
#              pixel_values = processor(images=crops, return_tensors="pt").pixel_values.to(device)
#              generated_ids = model.generate(pixel_values)
#              decoded_text = processor.batch_decode(generated_ids, skip_special_tokens=True)
#              extracted_text = " ".join(decoded_text) # Join text from all crops
#         else:
#              print(f"No text boxes detected in {os.path.basename(image_path)}")


#         if not extracted_text.strip():
#             print(f"No text extracted from {os.path.basename(image_path)}")
#             return [] # Return empty list if no text

#         # Process the single string of extracted text
#         processed_output = process_text(extracted_text)
#         return processed_output

#     except Exception as e:
#         print(f"Error processing {os.path.basename(image_path)}: {e}")
#         # Optionally re-raise or log the exception more formally
#         # import traceback
#         # traceback.print_exc()
#         return None # Indicate error

def submit(image_path):
    return [
        ("باراسيتامول", "قرص كل ٨ ساعات"),
        ("فيتامين سي", "قرص يوميا"),
        ("أموكسيسيلين", "كبسولة كل ١٢ ساعة")
    ]
