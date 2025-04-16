using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace readaloud
{
    public class Sigm : Iactv
    {
        public double func(double x)
        {
            return 1 / (1 + Math.Exp(-x));
        }

        public double Prov(double x)
        {
            double f = func(x);
            return f * (1 - f);
        }
    }
}
