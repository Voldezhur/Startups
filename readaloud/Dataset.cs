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
    }
}
