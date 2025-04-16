using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace readaloud
{
    class SoftClamp : Iactv
    {
        private readonly double _smoothness = 10.0;

        public double func(double x)
        {
            x = Math.Max(0, Math.Min(1, x));

            return 1 / (1 + Math.Exp(-_smoothness * (x - 0.5)));
        }

        public double Prov(double x)
        {
            double f = func(x);
            return _smoothness * f * (1 - f);
        }
    }
}
