module GramLab.Perceptron.IntModel ( IntModel
                                   , train
                                   , evalAll
                                   , TrainSettings(..)
                                   )

where
import qualified Data.IntSet as IntSet
import qualified Data.IntMap as IntMap
import qualified Data.Binary as B
import qualified Data.ByteString.Lazy as BS
import GramLab.Utils (padRight)
import Data.List (sortBy)
import Data.Ord (comparing)
import System.IO (stderr,hPutStrLn)
import Control.Monad (ap,liftM2)
import Data.Ix (inRange)
import Data.Array.Unboxed

import qualified GramLab.Perceptron.Multiclass as P

data TrainSettings = TrainSettings { iter      :: Int
                                   , rate      :: Double
                                   , occurTh   :: Int
                                   , entropyTh :: Double
                                   } deriving (Eq,Show,Read)

instance B.Binary TrainSettings where
    put (TrainSettings a b c d) = B.put a >> B.put b >> B.put c >> B.put d
    get = return TrainSettings `ap` B.get `ap` B.get `ap` B.get `ap` B.get

data IntModel = IntModel  { modelLabels   :: IntSet.IntSet 
                          , modelWeights  :: P.Model } 
                deriving (Show,Eq)

train :: TrainSettings -> UArray (Int,Int) Bool
      -> [(Int,[(Int,Double)])] -> IntModel 
-- For compatibility, examples have label first, feature second
train s yss examples = model
 where examples' = 
                   [ (y,[ (i,realToFrac v) | (i,v) <- x ]) | (y,x) <- examples ]
       examples'' = map swap examples'
       labels   =  map fst             examples'
       featids  =  concatMap (map fst . snd) examples'
       weights  = examples'' == examples'' `seq` P.train (realToFrac $ rate s) 
                          (iter s) 
                          (lo,hi)
                          yss
                  $ examples'' 
       model    = IntModel { modelLabels   = IntSet.fromList labels
                           , modelWeights      = weights
                           }
       (lo,hi) = ((minimum labels,minimum featids)
                 ,(maximum labels,maximum featids)) :: ((Int,Int),(Int,Int))
       swap (x,y) = (y,x)

evalAll :: IntModel -> [Int] -> [(Int,Double)] -> [(Int,Double)]
evalAll m ys fs = 
    let ((_,lo),(_,hi)) = P.bounds . modelWeights $ m
        fs' = filter (\(k,_) -> inRange (lo,hi) k) fs
    in map (\(i,v) -> (i,realToFrac v)) 
                      . P.distribution (modelWeights m) ys
                      $ [ (i,realToFrac v) | (i,v) <- fs' ]
instance B.Binary IntModel where
    put (IntModel ls ws)  = B.put ls >> B.put ws
    get  = do 
      ls <- B.get 
      ls == ls `seq` return ()
      ws <- B.get
      ws == ws `seq` return ()
      return $ IntModel ls ws
                              
