using System;

namespace PCXLab.VideoTools.Private
{
    public static class AudioCorrelationEngine
    {
        public class CorrelationResult
        {
            public double BestOffset { get; set; }
            public double Correlation { get; set; }
            public int BestLag { get; set; }
            public int FramesCompared { get; set; }
            public double? SecondPeakCorrelation { get; set; }
            public double OverlapFraction { get; set; }
        }

        public static CorrelationResult Search(
            double[] refSignal,
            double[] compSignal,
            int minLag,
            int maxLag,
            int stepFrames,
            double frameDuration,
            double peakExclusionWindow = 1.0)
        {
            if (refSignal == null || refSignal.Length == 0)
            {
                throw new ArgumentException("refSignal must contain at least one element.");
            }

            if (compSignal == null || compSignal.Length == 0)
            {
                throw new ArgumentException("compSignal must contain at least one element.");
            }

            int refLen = refSignal.Length;
            int compLen = compSignal.Length;

            int bestLag = 0;
            double bestCorrelation = -2.0;
            int bestOverlap = 0;

            int lagRange = maxLag - minLag + 1;
            double[] lagCorrelations = new double[lagRange];

            for (int lag = minLag; lag <= maxLag; lag += stepFrames)
            {
                int refIndex = 0;
                int compIndex = 0;

                if (lag >= 0)
                {
                    compIndex = lag;
                }
                else
                {
                    refIndex = -lag;
                }

                int overlap = Math.Min(refLen - refIndex, compLen - compIndex);
                if (overlap < 1)
                {
                    continue;
                }

                double refSum = 0.0;
                double compSum = 0.0;
                double refSquares = 0.0;
                double compSquares = 0.0;
                double dotProduct = 0.0;

                for (int i = 0; i < overlap; i++)
                {
                    double rVal = refSignal[refIndex + i];
                    double cVal = compSignal[compIndex + i];

                    refSum += rVal;
                    compSum += cVal;
                    refSquares += rVal * rVal;
                    compSquares += cVal * cVal;
                    dotProduct += rVal * cVal;
                }

                double refMean = refSum / overlap;
                double compMean = compSum / overlap;

                double refVar = refSquares - (overlap * refMean * refMean);
                double compVar = compSquares - (overlap * compMean * compMean);

                double covariance = dotProduct - (overlap * refMean * compMean);

                double correlation = 0.0;
                if (refVar > 1e-12 && compVar > 1e-12)
                {
                    correlation = covariance / Math.Sqrt(refVar * compVar);
                }
                else if (refVar <= 1e-12 && compVar <= 1e-12)
                {
                    if (refMean > 1e-6 && Math.Abs(refMean - compMean) < 1e-6)
                    {
                        correlation = 1.0;
                    }
                }

                lagCorrelations[lag - minLag] = correlation;

                if (correlation > bestCorrelation || (correlation == bestCorrelation && overlap > bestOverlap))
                {
                    bestCorrelation = correlation;
                    bestLag = lag;
                    bestOverlap = overlap;
                }
            }

            if (bestCorrelation < -1.0)
            {
                bestCorrelation = 0.0;
            }

            int separationFrames = (int)Math.Max(1, Math.Round(peakExclusionWindow / frameDuration));

            double? secondPeakCorrelation = null;
            double secondBestCorrelation = -2.0;
            bool hasIndependentLag = false;

            for (int l = minLag; l <= maxLag; l += stepFrames)
            {
                if (Math.Abs(l - bestLag) >= separationFrames)
                {
                    hasIndependentLag = true;
                    double c = lagCorrelations[l - minLag];
                    if (c > secondBestCorrelation)
                    {
                        secondBestCorrelation = c;
                    }
                }
            }

            if (hasIndependentLag)
            {
                secondPeakCorrelation = Math.Round(secondBestCorrelation, 6);
            }

            double maxAchievableOverlap = Math.Min(refLen, compLen);
            double overlapFraction = Math.Round(bestOverlap / maxAchievableOverlap, 6);

            double bestOffset = Math.Round(bestLag * frameDuration, 6);
            double roundedBestCorrelation = Math.Round(bestCorrelation, 6);

            return new CorrelationResult
            {
                BestOffset = bestOffset,
                Correlation = roundedBestCorrelation,
                BestLag = bestLag,
                FramesCompared = bestOverlap,
                SecondPeakCorrelation = secondPeakCorrelation,
                OverlapFraction = overlapFraction
            };
        }
    }
}
