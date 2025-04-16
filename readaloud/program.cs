using System;
using System.IO;

namespace readaloud
{
    class Program
    {
        static void Main()
        {
            // Создаем датасет
            var dataset = new Dataset();
            Random rand = new Random();

            // Генерируем 1000 примеров
            for (int i = 0; i < 1024; i++)
            {
                int number = rand.Next(0, 65536);
                double[] inputs = Dataset.ConvertTo16BitArray(number);

                double[] outputs = new double[4];

                // 1) Деление на 11
                outputs[0] = (number % 11 == 0) ? 1.0 : 0.0;

                // 2) Наличие цифры 5
                outputs[1] = (number.ToString().Contains('5')) ? 1.0 : 0.0;

                // 3) После умножения на 2 есть 4
                outputs[2] = ((number * 2).ToString().Contains('4')) ? 1.0 : 0.0;

                // 4) Делится на 3, но не на 9
                outputs[3] = (number % 3 == 0 && number % 9 != 0) ? 1.0 : 0.0;

                dataset.Add(inputs, outputs);
            }

            // Создаем нейросеть
            int[] layerSizes = { 16, 64, 32, 16, 4 };
            Iactv[] activations =
            {
                new LeakyReLU(), new LeakyReLU(), new LeakyReLU(), new Sigm()
            };
            var network = new Network(layerSizes, activations, true);

            // Обучение
            Console.WriteLine("Начинаем обучение...");
            network.Train(
                dataset,
                epochs: 1000,
                learningRate: 0.2,
                batchSize: 256,
                maxError: 0.10,
                maxTimeSeconds: 60 * 15,
                reportIntervalPercent: 1
            );

            // Сохранение модели
            network.SaveToFile("number_classifier.nn");

            // Вывод тестовых примеров
            Console.WriteLine("\n10 тестовых примеров:");
            for (int i = 0; i < 10; i++)
            {
                int testNumber = rand.Next(0, 65536);
                TestNumber(network, testNumber);
            }

            // Добавьте эту строку для остановки консоли
            Console.WriteLine("\nНажмите Enter, чтобы выйти...");
            Console.ReadLine(); // Ожидание ввода пользователя
        }

        static void TestNumber(Network network, int number)
        {
            double[] inputs = Dataset.ConvertTo16BitArray(number);
            network.SetInputs(inputs);
            network.Forward();
            double[] outputs = network.GetOutputs();

            Console.WriteLine($"Число: {number,5} (0x{number:X4})");
            Console.WriteLine($"  1) Делится на 11? {outputs[0]:F2} (Должно быть {(number % 11 == 0 ? "Да" : "Нет")})");
            Console.WriteLine($"  2) Есть 5?       {outputs[1]:F2} (Должно быть {(number.ToString().Contains('5') ? "Да" : "Нет")})");
            Console.WriteLine($"  3) *2 с 4?       {outputs[2]:F2} (Должно быть {(ContainsFour(number * 2) ? "Да" : "Нет")})");
            Console.WriteLine($"  4) 3| но не 9|? {outputs[3]:F2} (Должно быть {(number % 3 == 0 && number % 9 != 0 ? "Да" : "Нет")})");
            Console.WriteLine();
        }

        static bool ContainsFour(int number)
        {
            return number.ToString().Contains('4');
        }
    }
}
