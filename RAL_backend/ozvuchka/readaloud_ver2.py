import asyncio
import sys
from edge_tts import Communicate, VoicesManager

async def convert_text_to_speech(text, voice, output_file):
    communicate = Communicate(text=text, voice=voice)
    await communicate.save(output_file)

async def list_voices():
    voices = await VoicesManager.create()
    for voice in voices.voices:
        print(f"Имя: {voice['Name']}, Код: {voice['ShortName']}")

async def main(voice, text):
    output_file = "output.mp3"
    await convert_text_to_speech(text, voice, output_file)
    #print(f"Аудиофайл сохранен как {output_file}")

if __name__ == "__main__":
    try:
        choice = sys.argv[1]
        text = ' '.join(sys.argv[2:])
    except IndexError:
        print("Ошибка: необходимо указать выбор голоса (0/1) и текст")
        sys.exit(1)

    if choice not in ['0', '1']:
        print("Ошибка: выберите голос 0 или 1")
        sys.exit(1)

    selected_voice = "ru-RU-DmitryNeural" if choice == '0' else "ru-RU-SvetlanaNeural"
    asyncio.run(main(selected_voice, text))
