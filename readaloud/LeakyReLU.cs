using System;

namespace readaloud
{
    public class LeakyReLU : Iactv
    {
        private readonly double _alpha;

        // Конструктор с параметром alpha (по умолчанию 0.01)
        public LeakyReLU(double alpha = 0.01)
        {
            _alpha = alpha;
        }

        public double func(double x)
        {
            // Leaky ReLU: x, если x > 0, иначе alpha * x
            return x > 0 ? x : _alpha * x;
        }

        public double Prov(double x)
        {
            // Производная: 1 для x > 0, alpha для x ≤ 0
            return x > 0 ? 1.0 : _alpha;
        }
    }
}