using System;

namespace readaloud
{
    public class Tanh : Iactv
    {
        public double func(double x)
        {
            // Tanh(x) = (e^x - e^(-x)) / (e^x + e^(-x))
            return Math.Tanh(x);
        }

        public double Prov(double x)
        {
            // Производная Tanh: 1 - tanh²(x)
            double tanhX = Math.Tanh(x);
            return 1 - tanhX * tanhX;
        }
    }
}