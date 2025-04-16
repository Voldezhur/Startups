using System;

namespace readaloud
{
    public class ReLU : Iactv
    {
        public double func(double x)
        {
            // ReLU(x) = max(0, x)
            return Math.Max(0, x);
        }

        public double Prov(double x)
        {
            // Производная ReLU: 1, если x > 0, иначе 0
            return x > 0 ? 1.0 : 0.0;
        }
    }
}