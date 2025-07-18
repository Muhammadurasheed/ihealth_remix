# 📱 iHealth – Mobile AI Triage Assistant

> 🌍 **iHealth** is a mobile-first, AI-powered triage assistant for underserved communities — enabling anyone to describe their symptoms via voice or text, receive instant health guidance powered by LLM + vision AI, and connect with care nearby.  
> 🩺 Built for dignity, designed for real-world access.

---

## 📹 Demo Video

🎥 [Watch our 2-minute project video](https://youtu.be/YfbEmNFaaxs)

---

## 🚀 Live APK

📦 [Download APK (Android)](https://drive.google.com/file/d/1va33syW5iAl8xykkWnQY3lDApl3j0rFR/view?usp=drive_link)

---

## 🧑‍💻 Source Code

- 📱 **Flutter Frontend:** [ihealth_frontend (GitHub)](https://github.com/Muhammadurasheed/ihealth_frontend.git)  
- ⚙️ **Node.js Backend:** [ihealth_backend (GitHub)](https://github.com/Muhammadurasheed/ihealth_backend.git)

---

## ✨ What Can It Do?

- 🧠 Understand symptoms via **voice or text** in local languages  
- 📷 Snap or upload a skin image for **AI-driven dermatology triage**  
- 💬 Educate users about **causes, triggers, remedies, prevention**  
- 📍 Recommend **verified local clinics** using OpenStreetMap  
- 🧾 Save symptoms to history — offline + online sync  
- 🔒 100% privacy-first. Runs with edge AI + secured endpoints

---

## 📱 Mobile Stack Overview

| Layer               | Tech                             |
|---------------------|----------------------------------|
| Frontend            | Flutter (Dart)                   |
| State Management    | Riverpod                         |
| Voice Input         | `speech_to_text` SDK             |
| Camera/Image Upload | `image_picker`, `cloudinary`     |
| API Integration     | REST + secured endpoints         |
| Offline Support     | Hive + SharedPreferences         |
| Navigation          | `go_router`                      |
| Translation         | LibreTranslate (self-hosted)     |
| Location/Map        | OpenStreetMap SDK                |
| Styling             | Futura font + dark/white theme   |

---

## 📦 How to Run (Local Dev)

### 1. Prerequisites

- Flutter SDK (`>=3.10.0`)
- Android Studio or Xcode
- Access to backend URL & Cloudinary creds

### 2. Install & Launch

```bash
# Clone the frontend
git clone https://github.com/Muhammadurasheed/ihealth_frontend.git
cd ihealth_frontend

# Install packages
flutter pub get

# Run on device/emulator
flutter run
3. Configure Environment
Create .env or insert directly:
CLOUDINARY_URL=your_key
BASE_API_URL=https://your-api.com

🧱 Architecture Overview
lib/
├── main.dart                # App entry
├── ui/                      # Screens & widgets
│   ├── home/
│   ├── diagnosis/
│   ├── history/
│   └── settings/
├── services/                # API, voice, image handlers
├── models/                  # Response/data models
├── localization/            # Intl + translations
├── providers/               # Riverpod state logic
├── utils/                   # Constants & helpers

🧪 AI & Intelligence Pipeline
Skin Image Diagnosis:
Hugging Face's AutoDerm + custom fallback model trained on dark skin

Language Support:
LibreTranslate hosted in Docker container for fast, private multilingual response

LLM Symptom Explanation:
Gemini 1.5 Flash used for triage explanation, condition summaries, and personalized education

Voice Transcription:
Flutter speech-to-text SDK

Maps & Clinics:
OpenStreetMap → suggests verified clinics based on geo-location

⚙️ Features by Role
Role	Features
General Users	Speak/type symptoms, photo upload, get guidance, history, privacy-first
Medical Students	Use for symptom checking, decision support, education, image learning
Healthcare Orgs	Integration-ready; insights via anonymized, aggregated triage trends
Doctors/Clinics	Visibility on map, optional user referrals via future integration

🧠 Why iHealth?
Healthcare isn't just a human need — it's a human right.

iHealth is built for those who fall through the cracks:

The girl in rural Nigeria facing skin stigma

The boy in Kenya too shy to describe symptoms in English

The mother in India who can't afford a clinic visit without knowing if it's serious

🔐 Trust, Privacy, and Safety
iHealth is not a diagnostic tool — it's a triage assistant

Disclaimers and explainability built in for every AI output

Users stay anonymous unless they choose to sign in

No health info shared with 3rd parties

🛠 Challenges We Solved
✅ Building voice + multilingual UX for low-literacy users

✅ Skin tone fairness in AI dermatology

✅ Private AI usage without sending data to unknown clouds

✅ Fast experience in rural areas with weak internet

✅ Getting quality insights from symptoms using LLM

🙌 Built For
👩‍⚕️ Health Hackathons & NGOs

📱 Global digital health communities

🌍 Real users in Africa, Asia & beyond

👥 Contributors
Name	Role
Rasheed Yekini	Lead Engineer (Flutter)
Rasheed Yekini	AI + Backend Integrations
Rasheed Yekini	Product Designer / UX
Rasheed Yekini	API + Node.js Backend

📬 Contact Us
📧 yekinirasheed2002@gmail.com

🌐 Project Video (YouTube)

🧠 Backend GitHub

💻 Frontend GitHub

📱 APK Download

iHealth: From Africa, for the world.
Your health. Your language. Your phone.