using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace readaloud
{
    public class Connection
    {
        public Neuron TargetNeuron { get; }
        public double Weight { get; set; }
        public Connection(Neuron target, double weight)
        {
            TargetNeuron = target;
            Weight = weight;
        }

        public double Gradient { get; set; }
        private readonly object _gradientLock = new object();

        public void AddGradient(double delta)
        {
            lock (_gradientLock)
            {
                Gradient += delta;
            }
        }
    }
}
