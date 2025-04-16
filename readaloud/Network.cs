using System;
using System.Collections.Generic;
using System.Diagnostics;
using static readaloud.Dataset;

namespace readaloud
{
    public class Network
    {
        public List<Layer> Layers { get; }
        public Network(int[] layerSizes, Iactv[] activations, bool isMultithreaded = false)
        {
            if (activations.Length != layerSizes.Length - 1)
                throw new ArgumentException("Количество функций активации должно быть на 1 меньше, чем слоев.");

            Layers = new List<Layer>();
            for (int i = 0; i < layerSizes.Length; i++)
            {
                var layer = new Layer(layerSizes[i])
                {
                    IsInput = i == 0,
                    IsMultithreaded = isMultithreaded // Устанавливаем флаг многопоточности
                };
                Layers.Add(layer);

                if (i > 0)
                {
                    layer.Activation = activations[i - 1];
                    Layers[i - 1].ConnectToNextLayer(layer);
                }
            }
        }

        public void SetInputs(double[] inputs) => Layers[0].SetInputs(inputs);
        public double[] GetOutputs() => Layers.Last().GetOutputs();
        public void Forward()
        {
            for (int i = 1; i < Layers.Count; i++)
                Layers[i].Reset();
            foreach (var layer in Layers)
                layer.Forward();
        }

        public void Backpropagate(double[] targets, double learningRate, bool accumulateGradients = true)
        {
            var outputLayer = Layers.Last();
            for (int i = 0; i < outputLayer.Neurons.Count; i++)
            {
                var neuron = outputLayer.Neurons[i];
                double error = targets[i] - neuron.ActivatedValue;
                double derivative = outputLayer.Activation.Prov(neuron.PrimaryValue);
                neuron.Delta = error * derivative;

                if (accumulateGradients)
                {
                    neuron.AddBiasGradient(neuron.Delta);
                }
                else
                {
                    neuron.Bias += learningRate * neuron.Delta;
                }

                if (Layers.Count > 1)
                {
                    var previousLayer = Layers[Layers.Count - 2];
                    foreach (var prevNeuron in previousLayer.Neurons)
                    {
                        foreach (var connection in prevNeuron.Connections)
                        {
                            if (connection.TargetNeuron == neuron)
                            {
                                if (accumulateGradients)
                                {
                                    connection.AddGradient(neuron.Delta * prevNeuron.ActivatedValue);
                                }
                                else
                                {
                                    connection.Weight += learningRate * neuron.Delta * prevNeuron.ActivatedValue;
                                }
                            }
                        }
                    }
                }
            }

            for (int layerIndex = Layers.Count - 2; layerIndex > 0; layerIndex--)
            {
                var currentLayer = Layers[layerIndex];
                var nextLayer = Layers[layerIndex + 1];
                foreach (var currentNeuron in currentLayer.Neurons)
                {
                    double sumDeltas = 0.0;
                    foreach (var connection in currentNeuron.Connections)
                        sumDeltas += connection.Weight * connection.TargetNeuron.Delta;
                    currentNeuron.Delta = sumDeltas * currentLayer.Activation.Prov(currentNeuron.PrimaryValue);

                    if (accumulateGradients)
                    {
                        currentNeuron.AddBiasGradient(currentNeuron.Delta);
                    }
                    else
                    {
                        currentNeuron.Bias += learningRate * currentNeuron.Delta;
                    }

                    if (layerIndex > 0)
                    {
                        var previousLayer = Layers[layerIndex - 1];
                        foreach (var prevNeuron in previousLayer.Neurons)
                        {
                            foreach (var connection in prevNeuron.Connections)
                            {
                                if (connection.TargetNeuron == currentNeuron)
                                {
                                    if (accumulateGradients)
                                    {
                                        connection.AddGradient(currentNeuron.Delta * prevNeuron.ActivatedValue);
                                    }
                                    else
                                    {
                                        connection.Weight += learningRate * currentNeuron.Delta * prevNeuron.ActivatedValue;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        public void ResetGradients()
        {
            foreach (var layer in Layers)
            {
                foreach (var neuron in layer.Neurons)
                {
                    neuron.BiasGradient = 0;
                    foreach (var connection in neuron.Connections)
                    {
                        connection.Gradient = 0;
                    }
                }
            }
        }

        public void ApplyGradients(double learningRate, int batchSize)
        {
            foreach (var layer in Layers)
            {
                foreach (var neuron in layer.Neurons)
                {
                    neuron.Bias += learningRate * (neuron.BiasGradient / batchSize);
                    foreach (var connection in neuron.Connections)
                    {
                        connection.Weight += learningRate * (connection.Gradient / batchSize);
                    }
                }
            }
        }

        public void PrintNetworkInfo()
        {
            for (int layerIndex = 0; layerIndex < Layers.Count; layerIndex++)
            {
                var layer = Layers[layerIndex];
                Console.WriteLine($"Слой {layerIndex} ({(layer.IsInput ? "входной" : "скрытый/выходной")}):");
                for (int neuronIndex = 0; neuronIndex < layer.Neurons.Count; neuronIndex++)
                {
                    var neuron = layer.Neurons[neuronIndex];
                    Console.WriteLine($"  Нейрон {neuronIndex}:");
                    Console.WriteLine($"    Bias = {neuron.Bias:F4}");
                    Console.WriteLine("    Веса связей:");
                    foreach (var connection in neuron.Connections)
                    {
                        Console.Write($"      {connection.Weight:F4} → ");
                    }
                    Console.WriteLine(); // Перенос строки после всех связей
                }
            }
        }

        private static IEnumerable<IEnumerable<Example>> GetBatches(IEnumerable<Example> examples, int batchSize)
        {
            if (batchSize == -1)
            {
                yield return examples.ToList();
                yield break;
            }

            var batch = new List<Example>();
            foreach (var example in examples)
            {
                batch.Add(example);
                if (batch.Count == batchSize)
                {
                    yield return batch;
                    batch = new List<Example>();
                }
            }
            if (batch.Count > 0)
                yield return batch;
        }

        public void Train(
        Dataset dataset,
        int epochs,
        double learningRate,
        int batchSize = 32,
        float reportIntervalPercent = 10.0f,
        double maxError = double.MaxValue,
        int maxTimeSeconds = -1)
        {
            var startTime = DateTime.Now;
            int inputSize = Layers[0].Neurons.Count;
            int outputSize = Layers.Last().Neurons.Count;
            // Проверка размеров входа/выхода
            foreach (var example in dataset.GetExamples())
            {
                if (example.Inputs.Length != inputSize || example.Outputs.Length != outputSize)
                {
                    throw new ArgumentException(
                        $"Размеры входа/выхода не совпадают с архитектурой сети ({inputSize} входов, {outputSize} выходов)."
                    );
                }
            }

            double averageError = 0.0;
            // Вычисление интервала вывода в количестве эпох
            int interval;
            if (reportIntervalPercent == 0)
            {
                interval = 1; // Вывод каждую эпоху
            }
            else if (reportIntervalPercent == 100)
            {
                interval = epochs + 1; // Вывод отключен
            }
            else
            {
                interval = (int)(epochs * (reportIntervalPercent / 100f));
                if (interval == 0) interval = 1;
            }

            for (int epoch = 0; epoch < epochs; epoch++)
            {
                double totalError = 0.0;
                // Разбиваем датасет на батчи
                foreach (var batch in GetBatches(dataset.GetExamples(), batchSize))
                {
                    ResetGradients();

                    // Параллельная обработка примеров в батче
                    Parallel.ForEach(batch, example =>
                    {
                        SetInputs(example.Inputs);
                        Forward();
                        Backpropagate(example.Outputs, learningRate, accumulateGradients: true);
                        // Вычисляем ошибку для текущего примера
                        var outputs = GetOutputs();
                        lock (this) // Блокировка для безопасного обновления totalError
                        {
                            for (int i = 0; i < outputs.Length; i++)
                            {
                                totalError += Math.Pow(example.Outputs[i] - outputs[i], 2);
                            }
                        }
                    });

                    ApplyGradients(learningRate, batchSize);
                }

                averageError = totalError / dataset.GetExamples().Count();
                // Проверка времени и ошибки
                if (maxTimeSeconds > 0 && (DateTime.Now - startTime).TotalSeconds > maxTimeSeconds)
                {
                    Console.WriteLine($"⏰ Превышено время {maxTimeSeconds} сек. Ошибка: {averageError:F6}");
                    return;
                }
                if (averageError <= maxError)
                {
                    Console.WriteLine($"✅ Остановка по ошибке на эпохе {epoch}. Ошибка: {averageError:F6}");
                    return;
                }
                // Вывод по указанному интервалу
                if (epoch % interval == 0 || epoch == epochs - 1)
                {
                    double elapsed = (DateTime.Now - startTime).TotalSeconds;
                    double progress = (double)epoch / epochs * 100;
                    Console.WriteLine(
                        $"Эпоха {epoch}/{epochs} ({progress:F2}%), Время: {elapsed:F1} сек, Ошибка: {averageError:F6}"
                    );
                }
            }
            // Итоговый вывод
            double totalElapsedTime = (DateTime.Now - startTime).TotalSeconds;
            Console.WriteLine($"⏰ Обучение завершено за {epochs} эпох. Всего время: {totalElapsedTime:F1} сек, Ошибка: {averageError:F6}");
        }

        public void SaveToFile(string filename)
        {
            using (StreamWriter writer = new StreamWriter(filename))
            {
                // Записываем количество слоёв
                writer.WriteLine(Layers.Count);

                // Записываем параметры каждого слоя
                foreach (var layer in Layers)
                {
                    writer.WriteLine(layer.Neurons.Count); // Количество нейронов
                    if (layer.IsInput)
                    {
                        writer.WriteLine("None"); // Входной слой не имеет активации
                    }
                    else
                    {
                        writer.WriteLine(layer.Activation.GetType().Name); // Тип активации
                    }
                }

                // Записываем биасы и веса для каждого слоя (кроме входного)
                for (int layerIndex = 1; layerIndex < Layers.Count; layerIndex++)
                {
                    var currentLayer = Layers[layerIndex];
                    var previousLayer = Layers[layerIndex - 1];

                    // Записываем биасы текущего слоя
                    foreach (var neuron in currentLayer.Neurons)
                    {
                        writer.WriteLine(neuron.Bias);
                    }

                    // Записываем веса связей между предыдущим и текущим слоем
                    foreach (var prevNeuron in previousLayer.Neurons)
                    {
                        foreach (var connection in prevNeuron.Connections)
                        {
                            writer.WriteLine(connection.Weight);
                        }
                    }
                }
            }
        }

        public static Network LoadFromFile(string filename)
        {
            List<int> layerSizes = new List<int>();
            List<Type> activationTypes = new List<Type>();
            List<double> biases = new List<double>();
            List<double> weights = new List<double>();

            using (StreamReader reader = new StreamReader(filename))
            {
                // Читаем количество слоёв
                int layerCount = int.Parse(reader.ReadLine());

                // Читаем параметры слоёв
                for (int i = 0; i < layerCount; i++)
                {
                    layerSizes.Add(int.Parse(reader.ReadLine())); // Количество нейронов
                    string activationName = reader.ReadLine();

                    Type activationType = null;
                    if (activationName != "None")
                    {
                        activationType = Type.GetType($"readaloud.{activationName}");
                        if (activationType == null)
                            throw new Exception($"Неизвестный тип активации: {activationName}");
                    }
                    activationTypes.Add(activationType);
                }

                // Читаем биасы и веса для слоёв (кроме входного)
                for (int layerIndex = 1; layerIndex < layerCount; layerIndex++)
                {
                    int currentSize = layerSizes[layerIndex];
                    int prevSize = layerSizes[layerIndex - 1];

                    // Читаем биасы
                    for (int i = 0; i < currentSize; i++)
                    {
                        biases.Add(double.Parse(reader.ReadLine()));
                    }

                    // Читаем веса
                    for (int i = 0; i < prevSize; i++)
                    {
                        for (int j = 0; j < currentSize; j++)
                        {
                            weights.Add(double.Parse(reader.ReadLine()));
                        }
                    }
                }
            }

            // Создаём массив функций активации (для слоёв, кроме входного)
            List<Iactv> activations = new List<Iactv>();
            for (int i = 1; i < layerSizes.Count; i++)
            {
                var activationType = activationTypes[i];
                if (activationType == null)
                    throw new Exception($"Не задана активация для слоя {i}");

                activations.Add((Iactv)Activator.CreateInstance(activationType));
            }

            // Создаём сеть
            Network network = new Network(layerSizes.ToArray(), activations.ToArray());

            // Устанавливаем сохранённые веса и биасы
            int biasIndex = 0;
            int weightIndex = 0;
            for (int layerIndex = 1; layerIndex < layerSizes.Count; layerIndex++)
            {
                var currentLayer = network.Layers[layerIndex];
                var prevLayer = network.Layers[layerIndex - 1];

                // Устанавливаем биасы
                for (int neuronIndex = 0; neuronIndex < currentLayer.Neurons.Count; neuronIndex++)
                {
                    currentLayer.Neurons[neuronIndex].Bias = biases[biasIndex++];
                }

                // Устанавливаем веса
                foreach (var prevNeuron in prevLayer.Neurons)
                {
                    foreach (var connection in prevNeuron.Connections)
                    {
                        connection.Weight = weights[weightIndex++];
                    }
                }
            }

            return network;
        }
    }
}
