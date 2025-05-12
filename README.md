# Dawy | داوي

**Making prescriptions smarter and healthcare more accessible.**

## 🧠 Overview

Dawy is a mobile application that leverages modern computer vision and natural language processing techniques to digitize handwritten medical prescriptions. It helps users understand, manage, and schedule their medications effortlessly—especially in environments where prescriptions are written in mixed Arabic and English text.

With Dawy, patients can:

* Scan and interpret handwritten prescriptions
* Receive extracted medication names and dosage instructions
* Locate nearby pharmacies
* Manage and schedule medication intake
* Access a user-friendly, multilingual interface

---

## 📱 Features

* 🧾 **Prescription Scanner:** Detect and extract handwritten text using advanced AI models.
* 🌍 **Pharmacy Locator:** Discover and order from nearby pharmacies via geolocation services.
* 🕓 **Medication Scheduler:** Receive reminders and instructions for taking medicine.
* 🔠 **Arabic + English OCR:** Handles complex prescriptions with mixed-language content.
* 📋 **Medicine Info Database:** Find detailed info about each prescribed medicine.

---

## 🚀 Project Architecture

```
Input Image
    ↓
YOLOv11n (Handwritten Text Detection)
    ↓
TR-OCR (Text Recognition)
    ↓
Post-processing:
    - Region Sorting (Natural reading order)
    - Spell Correction (Levenshtein distance)
    - Term Matching (Pharmaceutical DB)
    - Classification (Medicine vs. Instructions)
    - Pairing (Dosages with medicines)
```

---

## 🔧 Setup Instructions

Follow these steps to set up and run the project locally:

### 1. Clone the Repository

```bash
git clone https://github.com/ismaeeelxd/stp_macathon.git
cd stp_macathon
```

### 2. Create a Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # For Linux/macOS
venv\Scripts\activate     # For Windows
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

> 📌 Make sure you have Python 3.8+ and CUDA 11.7+ (if using GPU) for compatibility with YOLO and TrOCR.

### 4. Run the Application

Depending on the module structure (e.g., mobile app and backend), run the appropriate entry script or refer to individual module READMEs if available.

---

## 📊 Performance Metrics

### YOLOv11n:

* **Precision:** 0.937
* **Recall:** 0.913

### TR-OCR Evaluation:

* **F1-Score (base):** 29%
* **F1-Score (large):** 44%

---

## 🧪 Results

* Accurately processed unseen handwritten prescriptions
* Successfully handled bilingual (Arabic-English) text
* User-friendly UI praised in initial tests
* Robust model performance despite small dataset (500 samples)
* Effective medicine-instruction pairing logic

---

## ⚙️ Tech Stack

* **YOLOv11n:** Object detection
* **TrOCR:** Text recognition
* **Python, PyTorch:** Core modeling
* **Flutter:** Mobile app development
* **Firebase / Firestore:** Backend integration
* **Roboflow, IAM, KHATT:** Data sources

---

## 👨‍💻 Authors

* [**Mazin Mahmoud**](https://github.com/MazinMahmoud)
* **Ismail** 
* **David Magdy Nagib**
* **Ahmed Wahdan**

---

## 📄 Documentation

Full technical and implementation documentation is available in the [`Dawy.pdf`](./Dawy%20%20داوي.pdf) file in this repository.

---

## 🔮 Future Vision

* **Medicine Marketplace:** A "Talabat for Medicine" for on-demand delivery
* **Privacy-Preserving Dataset Growth:** Opt-in image contribution with anonymization
* **Global Access:** Offline mode, low-end device support, NGO partnerships

---

## 🧠 Quote

> داوي - صحتك أذكى وأقرب
> *"Dawy – Smarter and Closer Healthcare."*


