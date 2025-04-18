import os
import torch
import numpy as np
from torch.utils.data import Dataset, DataLoader
from transformers import (
    SpeechT5Processor,
    SpeechT5ForTextToSpeech,
    SpeechT5HifiGan,
    Trainer,
    TrainingArguments
)
from pydub import AudioSegment

# Параметры
DATASET_DIR = "dataset"  
OUTPUT_DIR = "trained_model"
BATCH_SIZE = 4
EPOCHS = 10  
SAMPLING_RATE = 16000  

# Загрузка предобученных моделей
processor = SpeechT5Processor.from_pretrained("microsoft/speecht5_tts")
model = SpeechT5ForTextToSpeech.from_pretrained("microsoft/speecht5_tts")
vocoder = SpeechT5HifiGan.from_pretrained("microsoft/speecht5_hifigan")

# Функция для загрузки данных (с поддержкой .mp3)
def load_data(dataset_dir):
    texts = []
    audios = []
    for filename in os.listdir(dataset_dir):
        if filename.endswith((".txt", ".TXT")):
            text_path = os.path.join(dataset_dir, filename)
            audio_filename = filename.replace(".txt", ".mp3").replace(".TXT", ".mp3")
            audio_path = os.path.join(dataset_dir, audio_filename)
            
            # Загрузка текста
            with open(text_path, "r", encoding="utf-8") as f:
                text = f.read().strip()
                texts.append(text)
            
            # Загрузка аудио (16kHz, mono)
            audio = AudioSegment.from_file(audio_path)
            audio = audio.set_frame_rate(SAMPLING_RATE).set_channels(1)
            audio_array = np.array(audio.get_array_of_samples())
            audio_array = audio_array.astype(np.float32) / np.iinfo(audio.array_type).max
            audios.append(audio_array)
    return texts, audios

# Вывод информации о датасете
def print_dataset_info(texts, audios):
    print(f"Количество примеров: {len(texts)}")
    print(f"Примеры текстов: {texts[:3]}...")
    print(f"Длины аудио (сек): {[round(len(audio)/SAMPLING_RATE, 2) for audio in audios[:3]]}")
    
    valid_channels = all(len(audio.shape) == 1 for audio in audios)
    print(f"Все аудио одноканальные: {valid_channels}")
    
    print(f"Частота дискретизации: {SAMPLING_RATE} Hz")
    
    if len(audios) > 0:
        print("\nПример первого аудио:")
        print(f"Длина: {len(audios[0])} отсчётов")
        print(f"Мин/Макс значения: {audios[0].min():.2f}, {audios[0].max():.2f}")

# Загрузка и анализ данных
texts, audios = load_data(DATASET_DIR)
print_dataset_info(texts, audios)

# Остальной код остается без изменений (класс TTSDataset и обучение)
