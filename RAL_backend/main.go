package main

import (
	"io"
	"net/http"
	"os"
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

func main() {
	http.HandleFunc("/uppercase", uppercaseHandler)
	http.HandleFunc("/mp3_test", mp3test)

	http.ListenAndServe(":8080", nil)
}
