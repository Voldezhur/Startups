package main

import (
	"io"
	"net/http"
	"strings"
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

func main() {
	http.HandleFunc("/uppercase", uppercaseHandler)
	http.ListenAndServe(":8080", nil)
}
