using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace readaloud
{
    public class Dataset
    {
        public class Example
        {
            public double[] Inputs { get; set; }
            public double[] Outputs { get; set; }

            public Example(double[] inputs, double[] outputs)
            {
                Inputs = inputs;
                Outputs = outputs;
            }
        }

        private List<Example> _examples = new List<Example>();

        public void Add(double[] inputs, double[] outputs)
        {
            if (inputs == null || outputs == null)
                throw new ArgumentNullException("Входные или выходные данные не могут быть null.");

            _examples.Add(new Example(inputs, outputs));
        }

        public void Add(int number, double[] outputs)
        {
            if (number < 0 || number > 65535)
                throw new ArgumentOutOfRangeException("Число должно быть в диапазоне 0-65535.");

            double[] inputs = ConvertTo16BitArray(number);
            _examples.Add(new Example(inputs, outputs));
        }

        public void Add(char symbol, double[] outputs)
        {
            int code = (int)symbol;
            double[] inputs = ConvertTo16BitArray(code);
            _examples.Add(new Example(inputs, outputs));
        }

        public static double[] ConvertTo16BitArray(int value)
        {
            double[] bits = new double[16];
            for (int i = 0; i < 16; i++)
                bits[15 - i] = ((value >> i) & 1) == 1 ? 1.0 : 0.0;
            return bits;
        }

        public static double[] ConvertTo8BitArray(int value)
        {
            double[] bits = new double[8]; // Создаем массив из 8 элементов
            for (int i = 0; i < 8; i++)
            {
                // Проверяем i-й бит числа (смещение на i позиций вправо, &1 оставляет только младший бит)
                bits[7 - i] = ((value >> i) & 1) == 1 ? 1.0 : 0.0;
            }
            return bits;
        }

        public IEnumerable<Example> GetExamples()
        {
            return _examples;
        }

        public Example this[int index]
        {
            get
            {
                if (index < 0 || index >= _examples.Count)
                    throw new IndexOutOfRangeException("Индекс выходит за границы датасета.");
                return _examples[index];
            }
        }

        private static readonly Random _random = new Random();
        public Example GetRandomExample()
        {
            if (_examples.Count == 0)
                throw new InvalidOperationException("Датасет пуст.");

            int randomIndex = _random.Next(_examples.Count);
            return _examples[randomIndex];
        }

        public IEnumerable<IEnumerable<Example>> GetBatches(int batchSize)
        {
            if (batchSize == -1)
            {
                yield return _examples;
                yield break;
            }

            var batch = new List<Example>();
            foreach (var example in _examples)
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

        public IEnumerable<IEnumerable<Example>> ShuffleBatches(int batchSize)
        {
            if (batchSize == -1)
            {
                yield return _examples;
                yield break;
            }

            // Создаем список индексов и перемешиваем их
            var indices = Enumerable.Range(0, _examples.Count).ToList();
            for (int i = indices.Count - 1; i > 0; i--)
            {
                int j = _random.Next(i + 1);
                (indices[i], indices[j]) = (indices[j], indices[i]); // Обмен значениями
            }

            var batch = new List<Example>();
            foreach (int index in indices)
            {
                batch.Add(_examples[index]);
                if (batch.Count == batchSize)
                {
                    yield return batch;
                    batch = new List<Example>();
                }
            }
            if (batch.Count > 0)
                yield return batch;
        }
    }
}
