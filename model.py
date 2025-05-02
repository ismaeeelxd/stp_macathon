import os
import torch
import gdown
from PIL import Image, ImageOps
from ultralytics import YOLO
from transformers import TrOCRProcessor, VisionEncoderDecoderModel
from huggingface_hub import hf_hub_download
import re
import pandas as pd
import numpy as np

outputt = "database.xlsx"

device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Using device: {device}")

# model_path = hf_hub_download(repo_id="wahdan2003/YOLO_handwritten_medical", filename="best.pt")
model_path = ""
yolo_model = YOLO(model_path)
processor = TrOCRProcessor.from_pretrained("microsoft/trocr-base-handwritten",use_safetensors=True)
model = VisionEncoderDecoderModel.from_pretrained("David-Magdy/TROCR_MASTER_V2",use_safetensors=True).to(device)

def resize_image(image, target_size=(640, 640)):
    """
    Resize an image to a target size (640x640) with padding if needed.

    Args:
        image_path (str): Path to the input image.
        target_size (tuple): Target size (width, height) in pixels.

    Returns:
        PIL.Image: Resized image with padding.
    """
    aspect_ratio = image.width / image.height
    if aspect_ratio > 1:
        new_width = target_size[0]
        new_height = int(new_width / aspect_ratio)
    else:
        new_height = target_size[1]
        new_width = int(new_height * aspect_ratio)
    img_resized = image.resize((new_width, new_height), Image.Resampling.LANCZOS)
    return ImageOps.pad(img_resized, target_size, color=(114, 114, 114))

def extract(images):
    """
    Processes a list of prescription images and extracts the associated text.

    Args:
        images (list of str): List of file paths to input prescription images.

    Returns:
        list of str: Extracted prescription texts corresponding to each input image.
    """
    extracted_texts = []

    for image_path in images:
        try:

            image = Image.open(image_path).convert("RGB")
            resized_image = resize_image(image, target_size=(640, 640))


            results = yolo_model.predict(
                source=resized_image,
                imgsz=640,
                device=0 if torch.cuda.is_available() else "cpu",
                save=False,
                conf=0.5,
                iou=0.6,
                max_det=50
            )


            boxes = results[0].boxes
            coords = boxes.xywhn.cpu().numpy()


            sorted_indices = coords[:, 1].argsort()
            sorted_coords = coords[sorted_indices]


            img_width, img_height = 640, 640
            crops = []
            for coord in sorted_coords:
                x_center, y_center, width, height = coord
                x_min = int((x_center - width / 2) * img_width)
                x_max = int((x_center + width / 2) * img_width)
                y_min = int((y_center - height / 2) * img_height)
                y_max = int((y_center + height / 2) * img_height)
                crop = resized_image.crop((x_min, y_min, x_max, y_max))

                crop = ImageOps.pad(crop, (384, 384), color=(255, 255, 255))
                crops.append(crop)


            extracted_text = " "
            for crop in crops:
                pixel_values = processor(crop, return_tensors="pt").pixel_values.to(device)
                generated_ids = model.generate(pixel_values)
                text = processor.batch_decode(generated_ids, skip_special_tokens=True)[0]
                extracted_text+=text+" "



            extracted_texts.append(extracted_text)

        except Exception as e:
            print(f"Error processing {image_path}: {e}")
            extracted_texts.append("")

    return extracted_texts

import re
import pandas as pd
from symspellpy import SymSpell, Verbosity


drug_file ='/content/database.xlsx'
drug_df = pd.read_excel(drug_file)


drug_dict = dict(zip(drug_df['text'].astype(str), drug_df['medicine']))


sym_spell = SymSpell(max_dictionary_edit_distance=2, prefix_length=7)


for term in drug_dict.keys():
    sym_spell.create_dictionary_entry(term, 1)

def is_entirely_arabic(word):
    """Returns True if the entire word is Arabic letters only."""
    return all('\u0600' <= ch <= '\u06FF' for ch in word if ch.isalpha())

def remove_arabic(text):
    """Remove Arabic characters from a word."""
    return re.sub(r'[\u0600-\u06FF]', '', text)

def preprocess_text(text):
    """
    1. Removes the space after 'vitamin' (e.g., "vitamin d" → "vitamind").
    2. Converts English numbers between Arabic words into Arabic numerals but keeps spacing (e.g., "كل 8 ساعات" → "كل ٨ ساعات").
    """

    english_to_arabic_numbers = str.maketrans("0123456789", "٠١٢٣٤٥٦٧٨٩")


    def convert_numbers(match):
        return f"{match.group(1)} {match.group(2).translate(english_to_arabic_numbers)} {match.group(3)}"

    text = re.sub(r'([\u0600-\u06FF])\s*([\d]+)\s*([\u0600-\u06FF])', convert_numbers, text)

    return text


def correct_term_symspell(text, sym_spell, max_distance=2):
    """Correction using SymSpell (edit distance-based)."""
    text = str(text).strip()
    suggestions = sym_spell.lookup(text, Verbosity.TOP, max_edit_distance=max_distance)

    if suggestions:

        return suggestions[0].term
    else:
        if is_entirely_arabic(text)== False:
            text = remove_arabic(text)
        print(f"no suggestion for {text}")
        return text

def process_text(text):
    """
    Tokenizes input text, applies SymSpell correction per word, and checks medicine classification.
    Then, groups medicine words together and pairs them with instructions.
    Ensures that medicine names always appear first in the final pairs.
    """
    text = preprocess_text(text)
    words = re.findall(r'\b\w+\b', text)


    corrected_words = []


    for word in words:
        corrected_word = correct_term_symspell(word, sym_spell)
        is_medicine = drug_dict.get(corrected_word, 1)
        corrected_words.append((corrected_word, is_medicine))


    grouped_pairs = []
    current_group = []
    previous_type = None

    for word, is_medicine in corrected_words:
        if is_medicine == previous_type or previous_type is None:
            current_group.append(word)
        else:

            if previous_type is not None:
                grouped_pairs.append((" ".join(current_group), previous_type))
            current_group = [word]
        previous_type = is_medicine


    if current_group:
        grouped_pairs.append((" ".join(current_group), previous_type))

    return grouped_pairs

def submit(images):
    """
    Processes the text into (word, is_medicine) pairs.
    Then groups every two consecutive items into a pair,
    placing the medicine-type word first in the pair.
    If an odd number of elements exists, the last one is paired with an empty string.
    """
    pairs_per_image = []
    text = extract(images)
    for text in text:
      items = process_text(text)
      final_pairs = []

      i = 0
      while i < len(items):
          first = items[i]
          second = items[i + 1] if i + 1 < len(items) else ("", -1)


          if first[1] == 1:
              pair = (first[0], second[0])
          elif second[1] == 1:
              pair = (second[0], first[0])
          else:
              pair = (first[0], second[0])

          final_pairs.append(pair)
          i += 2
      pairs_per_image.append(final_pairs)

    return pairs_per_image
