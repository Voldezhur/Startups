using readaloud;
using System.Diagnostics;

namespace readaloud
{
    public class Neuron
    {
        private static readonly Random _random = new Random();
        public double PrimaryValue { get; set; }
        private double _accumulatedInput;
        public double ActivatedValue { get; set; }
        public List<Connection> Connections { get; } = new List<Connection>();
        public double Bias { get; set; }
        public double Delta { get; set; }

        private readonly object _lock = new object(); // Объект блокировки

        public double BiasGradient { get; set; }
        private readonly object _biasLock = new object();

        public void AddBiasGradient(double delta)
        {
            lock (_biasLock)
            {
                BiasGradient += delta;
            }
        }

        public void AddInput(double value)
        {
            lock (_lock) // Блокировка для безопасного обновления
            {
                _accumulatedInput += value;
            }
        }

        public void Reset()
        {
            _accumulatedInput = 0;
            PrimaryValue = 0;
            ActivatedValue = 0;
            Delta = 0; // Сбросить дельту
        }

        public void Forward(Iactv activation)
        {
            UpdatePrimaryValue();
            ActivatedValue = activation.func(PrimaryValue);
            foreach (var connection in Connections)
                connection.TargetNeuron.AddInput(ActivatedValue * connection.Weight);
        }

        public void UpdatePrimaryValue() => PrimaryValue = _accumulatedInput + Bias;

        public void InitializeWeightsAndBiases()
        {
            var inSize = Connections.Count;
            var outSize = 1; // For output layer, or get from next layer's neuron count
            var range = Math.Sqrt(6.0 / (inSize + outSize));
            foreach (var connection in Connections)
            {
                connection.Weight = _random.NextDouble() * (2 * range) - range;
            }
            Bias = _random.NextDouble() * (2 * range) - range;
        }




    }
}
