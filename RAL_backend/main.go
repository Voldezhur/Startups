package main

import (
	"bytes"
	//"fmt"
	"encoding/json"
	"io"
	"net/http"
	"os"
	"os/exec"

	// "path/filepath"
	"strings"
	"time"
)

func uppercaseHandler(w http.ResponseWriter, r *http.Request) {
	// Убедитесь, что метод запроса - POST
	if r.Method != http.MethodPost {
		http.Error(w, "Метод не разрешен", http.StatusMethodNotAllowed)
		return
	}

	r.ParseMultipartForm(10 << 20) // 10 MB limit

	file, _, err := r.FormFile("file") // "file" - это имя поля в форме
	if err != nil {
		http.Error(w, "Unable to retrieve file", http.StatusBadRequest)
		return
	}
	defer file.Close()

	// Читаем содержимое файла
	content, err := io.ReadAll(file)
	if err != nil {
		http.Error(w, "Unable to read file", http.StatusInternalServerError)
		return
	}

	// Преобразуем строку в верхний регистр
	output := strings.ToUpper(string(content))

	// Устанавливаем заголовок ответа
	w.Header().Set("Content-Type", "text/plain")

	// Отправляем ответ
	w.Write([]byte(output))
}

func mp3test(w http.ResponseWriter, r *http.Request) {
	filePath := "C:/Egorka/Startups/RAL_backend/smeshariki-ost.mp3"

	file, err := os.Open(filePath)
	if err != nil {
		http.Error(w, "File not found", http.StatusNotFound)
		return
	}
	defer file.Close()

	w.Header().Set("Content-Type", "audio/mpeg")
	w.Header().Set("Content-Disposition", "attachment; filename=file.mp3")
	w.WriteHeader(http.StatusOK)

	http.ServeContent(w, r, filePath, time.Now(), file)

}

type textToSpeech struct {
	Text string `json:"text"`
}

func version_alpha(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Метод не разрешен", http.StatusMethodNotAllowed)
		return
	}

	// Декодируйте JSON из тела запроса
	var data textToSpeech
	err := json.NewDecoder(r.Body).Decode(&data)
	if err != nil {
		http.Error(w, "Ошибка декодирования JSON", http.StatusBadRequest)
		return
	}
	content := data.Text
	// Выполняем C#-приложение
	cmd := exec.Command("C:/Egorka/Startups/RAL_backend/ozvuchka/readaloud.exe", string(content))
	var out bytes.Buffer
	cmd.Stdout = &out
	err = cmd.Run()
	if err != nil {
		http.Error(w, "Ошибка выполнения приложения: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Записываем полученные данные в output3.wav
	err = writeWavFile("output3.wav", out.Bytes())
	if err != nil {
		http.Error(w, "Ошибка записи файла: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Отправляем сгенерированный файл
	fileToSend, err := os.Open("debug_output.wav")
	if err != nil {
		http.Error(w, "Файл не найден", http.StatusNotFound)
		return
	}
	defer fileToSend.Close()

	w.Header().Set("Content-Type", "audio/wav")
	w.Header().Set("Content-Disposition", "attachment; filename=file.wav")
	w.WriteHeader(http.StatusOK)

	http.ServeContent(w, r, "debug_output.wav", time.Now(), fileToSend)
}

func writeWavFile(filename string, data []byte) error {
	return os.WriteFile(filename, data, 0644)
}

func main() {
	http.HandleFunc("/uppercase", uppercaseHandler)
	http.HandleFunc("/mp3_test", mp3test)
	http.HandleFunc("/test", version_alpha)

	http.ListenAndServe(":8080", nil)
}
