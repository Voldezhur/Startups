using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Net;
using static readaloud.Neuron;

namespace readaloud
{
    public class Layer
    {
        public InitializationMethod LayerInitializationMethod { get; set; }

        public bool IsMultithreaded { get; set; }

        public Iactv Activation { get; set; }
        public bool IsInput { get; set; }
        public List<Neuron> Neurons { get; } = new List<Neuron>();
        public Layer? NextLayer { get; private set; }

        public Layer(int neuronCount)
        {
            for (int i = 0; i < neuronCount; i++)
                Neurons.Add(new Neuron());
        }
        public void Reset()
        {
            if (IsMultithreaded)
            {
                Parallel.ForEach(Neurons, neuron => neuron.Reset());
            }
            else
            {
                foreach (var neuron in Neurons)
                    neuron.Reset();
            }
        }

        public void ConnectToNextLayer(Layer nextLayer)
        {
            NextLayer = nextLayer;
            foreach (var currentNeuron in Neurons)
            {
                foreach (var nextNeuron in nextLayer.Neurons)
                    currentNeuron.Connections.Add(new Connection(nextNeuron, 0));
                currentNeuron.InitializeWeightsAndBiases(LayerInitializationMethod);
                if (IsInput) // Установка bias в ноль для входного слоя
                    currentNeuron.Bias = 0;
            }

            // Initialize next layer's neurons (e.g., output layer)
            nextLayer.Neurons.ForEach(n => n.InitializeWeightsAndBiases(LayerInitializationMethod));
        }

        public void SetInputs(double[] inputs)
        {
            if (!IsInput) throw new InvalidOperationException("Только входному слою могут быть назначены значения.");
            if (inputs.Length != Neurons.Count) throw new ArgumentException();
            if (IsMultithreaded)
            {
                Parallel.For(0, inputs.Length, i => Neurons[i].PrimaryValue = inputs[i]);
            }
            else
            {
                for (int i = 0; i < inputs.Length; i++)
                    Neurons[i].PrimaryValue = inputs[i];
            }
        }

        public double[] GetOutputs() => Neurons.Select(n => n.ActivatedValue).ToArray();
        public void Forward()
        {
            if (IsInput)
            {
                if (IsMultithreaded)
                {
                    Parallel.ForEach(Neurons, neuron =>
                    {
                        neuron.ActivatedValue = neuron.PrimaryValue;
                        foreach (var connection in neuron.Connections)
                            connection.TargetNeuron.AddInput(neuron.ActivatedValue * connection.Weight);
                    });
                }
                else
                {
                    foreach (var neuron in Neurons)
                    {
                        neuron.ActivatedValue = neuron.PrimaryValue;
                        foreach (var connection in neuron.Connections)
                            connection.TargetNeuron.AddInput(neuron.ActivatedValue * connection.Weight);
                    }
                }
            }
            else
            {
                if (IsMultithreaded)
                {
                    Parallel.ForEach(Neurons, neuron => neuron.Forward(Activation));
                }
                else
                {
                    foreach (var neuron in Neurons)
                        neuron.Forward(Activation);
                }
            }
        }
    }
}
